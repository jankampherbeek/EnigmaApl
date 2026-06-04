// AgePointModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

enum AgePointMode {
    case positionsForEvent
    case overview
}

struct AgePointOverviewEntry {
    let age: Int
    let longitude: Double
}

@MainActor
final class AgePointModel: ObservableObject {
    @Published var positionResult: Double?
    @Published var activeMode: AgePointMode = .overview
    @Published var selectedHouseSystem: HouseSystems = .koch
    @Published var errorMessage: String?
    @Published var overviewEntries: [AgePointOverviewEntry] = []

    /// Wraps the calculated position as the dictionary format expected by aspect and midpoint orchestrators.
    var progressivePositions: [Factors: ProgressivePosition] {
        guard let pos = positionResult else { return [:] }
        return [.agePoint: ProgressivePosition(longitude: pos, declination: 0)]
    }

    private let tropicalYear = 365.242199074
    private let orchestrator = AgePointOrchestrator()

    /// - Parameters:
    ///   - cusps: 12-element array of house-cusp ecliptic longitudes (0-based: index 0 = house 1 = ASC).
    ///            Provided by the caller (typically from ChartSession.houseCuspLongitudes) to avoid
    ///            creating a second SEWrapper instance.
    func calculate(mode: AgePointMode, chart: FullChart?, cusps: [Double]?, event: EventModel?) {
        activeMode      = mode
        errorMessage    = nil
        positionResult  = nil
        overviewEntries = []

        guard let chart else {
            errorMessage = "No chart selected."
            return
        }
        guard let cusps, cusps.count == 12 else {
            errorMessage = "House calculation failed."
            return
        }

        switch mode {
        case .positionsForEvent:
            guard let event else {
                errorMessage = "No event selected."
                return
            }
            let age = (event.julianDate - chart.JulianDay) / tropicalYear
            positionResult = orchestrator.agePointLongitude(age: age, cusps: cusps)

        case .overview:
            overviewEntries = (0...71).map { y in
                let lon = orchestrator.agePointLongitude(age: Double(y), cusps: cusps)
                return AgePointOverviewEntry(age: y, longitude: lon)
            }
        }
    }
}
