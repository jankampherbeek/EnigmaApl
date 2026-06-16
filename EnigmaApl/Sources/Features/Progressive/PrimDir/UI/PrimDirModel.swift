// PrimDirModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

enum PrimDirInputMode: CaseIterable {
    case dateRange
    case event
}

@MainActor
final class PrimDirModel: ObservableObject {
    @Published private(set) var hits: [PrimDirHit] = []
    @Published var errorMessage: String?
    @Published var inputErrorMessage: String?
    @Published private(set) var methodDescription: String = ""
    @Published private(set) var period: String = ""
    @Published private(set) var eventTitle: String = ""
    @Published private(set) var eventDateTxt: String = ""

    var hasResults: Bool { !hits.isEmpty }
    var isEventMode: Bool { !eventTitle.isEmpty }

    func calculate(
        startDateText: String,
        endDateText: String,
        chart: FullChart,
        geoLat: Double,
        natalJD: Double,
        config: PrimaryDirectionsConfig
    ) {
        errorMessage = nil
        inputErrorMessage = nil
        eventTitle = ""
        eventDateTxt = ""
        let seWrapper = SEWrapper()

        guard let startJD = parseDate(startDateText, seWrapper: seWrapper) else {
            inputErrorMessage = NSLocalizedString(PrimDirKeys.errorInvalidStartDate, tableName: "PrimDir", bundle: .main, comment: "")
            return
        }
        guard let endJD = parseDate(endDateText, seWrapper: seWrapper) else {
            inputErrorMessage = NSLocalizedString(PrimDirKeys.errorInvalidEndDate, tableName: "PrimDir", bundle: .main, comment: "")
            return
        }
        guard startJD > natalJD else {
            inputErrorMessage = NSLocalizedString(PrimDirKeys.errorStartBeforeBirth, tableName: "PrimDir", bundle: .main, comment: "")
            return
        }
        guard endJD > startJD else {
            inputErrorMessage = NSLocalizedString(PrimDirKeys.errorEndBeforeStart, tableName: "PrimDir", bundle: .main, comment: "")
            return
        }

        methodDescription = buildMethodDescription(config: config)
        period = "\(startDateText.trimmingCharacters(in: .whitespaces)) – \(endDateText.trimmingCharacters(in: .whitespaces))"

        let orchestrator = PrimDirOrchestrator()
        hits = orchestrator.calculate(
            chart: chart,
            geoLat: geoLat,
            natalJD: natalJD,
            startJD: startJD,
            endJD: endJD,
            config: config
        )

        if hits.isEmpty {
            errorMessage = NSLocalizedString(PrimDirKeys.noHits, tableName: "PrimDir", bundle: .main, comment: "")
        }
    }

    func calculateForEvent(
        event: EventModel,
        chart: FullChart,
        geoLat: Double,
        natalJD: Double,
        config: PrimaryDirectionsConfig
    ) {
        errorMessage = nil
        inputErrorMessage = nil
        period = ""

        let seWrapper = SEWrapper()
        let dt = seWrapper.dateFromJulianDay(event.julianDate)
        eventTitle = event.title
        eventDateTxt = String(format: "%04d/%02d/%02d", dt.Date.Year, dt.Date.Month, dt.Date.Day)

        methodDescription = buildMethodDescription(config: config)

        let orchestrator = PrimDirOrchestrator()
        hits = orchestrator.calculateForEvent(
            chart: chart,
            geoLat: geoLat,
            natalJD: natalJD,
            eventJD: event.julianDate,
            config: config
        )

        if hits.isEmpty {
            errorMessage = NSLocalizedString(PrimDirKeys.noHitsEvent, tableName: "PrimDir", bundle: .main, comment: "")
        }
    }

    func clear() {
        hits = []
        errorMessage = nil
        inputErrorMessage = nil
        methodDescription = ""
        period = ""
        eventTitle = ""
        eventDateTxt = ""
    }

    // MARK: - Helpers

    private func parseDate(_ text: String, seWrapper: SEWrapper) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let parts = trimmed.components(separatedBy: CharacterSet(charactersIn: "/-."))
        guard parts.count == 3,
              let y = Int(parts[0]), let m = Int(parts[1]), let d = Int(parts[2]),
              m >= 1 && m <= 12, d >= 1 && d <= 31 else { return nil }
        let date = AstronomicalDate(Year: y, Month: m, Day: d, Gregorian: true)
        let time = AstronomicalTime(Hour: 0, Minute: 0, Second: 0)
        return seWrapper.julianDay(date: date, time: time)
    }

    private func buildMethodDescription(config: PrimaryDirectionsConfig) -> String {
        let method = NSLocalizedString(config.method.rbKey, comment: "")
        let approach = NSLocalizedString(config.approach.rbKey, comment: "")
        let timeKey = NSLocalizedString(config.timeKey.rbKey, comment: "")
        return "\(method) · \(approach) · \(timeKey)"
    }
}
