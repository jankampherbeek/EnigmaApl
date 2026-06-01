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
            // Month 0 = birth at the ascendant (age 0).
            entries.append(LtsOverviewEntry(kind: .month(0), longitude: asc))
            // Prenatal months 1–9: age = -(10 - m) * Z maps month 1 to exactly 120° before ASC
            // (9th cusp = conception) and month 9 to just before ASC. Uses Mann's lunar-month unit Z.
            let Z = 0.0766835
            for m in 1...9 {
                let lon = orchestrator.mannPositionFromAge(age: -Double(10 - m) * Z, ascendant: asc)
                entries.append(LtsOverviewEntry(kind: .month(m), longitude: lon))
            }
            for y in stride(from: 0, through: 40, by: 1) {
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
