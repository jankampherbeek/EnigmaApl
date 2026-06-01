// LogTimeScaleModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

enum LogTimeScaleMode {
    case positionsForEvent
    case overview
}

struct LtsOverviewEntry {
    enum Kind {
        case month(Int)
        case age(Int)
    }
    let kind: Kind
    let longitude: Double
}

@MainActor
final class LogTimeScaleModel: ObservableObject {
    @Published var positionResult: Double?
    @Published var activeMode: LogTimeScaleMode = .overview
    @Published var errorMessage: String?
    @Published var overviewEntries: [LtsOverviewEntry] = []

    /// Wraps the calculated position as the dictionary format expected by aspect and midpoint orchestrators.
    var progressivePositions: [Factors: ProgressivePosition] {
        guard let pos = positionResult else { return [:] }
        return [.logTimeScale: ProgressivePosition(longitude: pos, declination: 0)]
    }

    private let tropicalYear = 365.242199074
    private let orchestrator = LogTimeScaleOrchestrator()

    func calculate(mode: LogTimeScaleMode, chart: FullChart?, event: EventModel?) {
        activeMode = mode
        errorMessage = nil
        positionResult = nil
        overviewEntries = []

        switch mode {
        case .positionsForEvent:
            guard let chart, let event else {
                errorMessage = "No chart or event selected."
                return
            }
            let age = (event.julianDate - chart.JulianDay) / tropicalYear
            positionResult = orchestrator.mannPositionFromAge(
                age: age,
                ascendant: chart.HousePositions.ascendant.longitude
            )

        case .overview:
            guard let chart else {
                errorMessage = "No chart selected."
                return
            }
            let asc = chart.HousePositions.ascendant.longitude
            var entries: [LtsOverviewEntry] = []
            // Prenatal months 0–8: month 0 = conception (120° before ASC), month 8 = just before ASC.
            // age = -(9 - m) * Z uses Mann's lunar-month unit Z.
            let Z = 0.0766835
            for m in 0...8 {
                let lon = orchestrator.mannPositionFromAge(age: -Double(9 - m) * Z, ascendant: asc)
                entries.append(LtsOverviewEntry(kind: .month(m), longitude: lon))
            }
            // Age 0 = birth at the ascendant, listed directly after the prenatal months.
            entries.append(LtsOverviewEntry(kind: .age(0), longitude: asc))
            for y in stride(from: 1, through: 40, by: 1) {
                let lon = orchestrator.mannPositionFromAge(age: Double(y), ascendant: asc)
                entries.append(LtsOverviewEntry(kind: .age(y), longitude: lon))
            }
            for y in stride(from: 42, through: 50, by: 2) {
                let lon = orchestrator.mannPositionFromAge(age: Double(y), ascendant: asc)
                entries.append(LtsOverviewEntry(kind: .age(y), longitude: lon))
            }
            for y in stride(from: 55, through: 70, by: 5) {
                let lon = orchestrator.mannPositionFromAge(age: Double(y), ascendant: asc)
                entries.append(LtsOverviewEntry(kind: .age(y), longitude: lon))
            }
            overviewEntries = entries
        }
    }
}
