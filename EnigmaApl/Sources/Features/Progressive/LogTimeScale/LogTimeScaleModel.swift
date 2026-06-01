// LogTimeScaleModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

enum LogTimeScaleMode {
    case positionsForEvent
    case overview
}

@MainActor
final class LogTimeScaleModel: ObservableObject {
    @Published var positionResult: Double?
    @Published var activeMode: LogTimeScaleMode = .overview
    @Published var errorMessage: String?

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
            break
        }
    }
}
