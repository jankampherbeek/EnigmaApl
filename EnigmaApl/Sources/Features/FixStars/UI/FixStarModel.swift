// FixStarModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

struct FixStarPositionEntry: Identifiable {
    let id = UUID()
    let displayName: String
    let result: FixStarResult
}

struct FixStarMatch: Identifiable {
    let id = UUID()
    let starName: String
    let factor: Factors
    let matchType: MatchType
    let orb: Double

    enum MatchType {
        case conjunction
        case parallel
    }
}

@MainActor
final class FixStarModel: ObservableObject {
    @Published var positionEntries: [FixStarPositionEntry] = []
    @Published var matches: [FixStarMatch] = []
    @Published var errorMessage: String?

    private let seWrapper = SEWrapper()

    private static let starByAstronomical: [String: StarDefinitions] = Dictionary(
        uniqueKeysWithValues: StarDefinitions.allCases.map { ($0.astronomicalName, $0) }
    )

    func calculate(chart: FullChart?, config: UserConfiguration, orbOverride: Double) {
        errorMessage = nil
        positionEntries = []
        matches = []

        guard let chart else {
            errorMessage = "No chart selected."
            return
        }

        let selectedStarSettings = config.fixStarConfig.fixStarSettings.filter { $0.isUsed }
        guard !selectedStarSettings.isEmpty else {
            errorMessage = "No fixed stars selected in the configuration."
            return
        }

        let calcConfig = config.calculationConfig
        let starNames = selectedStarSettings.map { $0.fixStar.astronomicalName }
        let results = FixStarsOrchestrator.getFixStarSet(
            starNames: starNames,
            jdUt: chart.JulianDay,
            obsPos: calcConfig.observerPosition,
            ayanamsha: calcConfig.ayanamsha,
            seWrapper: seWrapper
        )

        var displayNameByAstronomical: [String: String] = [:]
        positionEntries = results.map { result in
            let displayName: String
            if let star = Self.starByAstronomical[result.starName] {
                let parts = ([star.name] + star.aliases).joined(separator: ", ")
                displayName = "\(parts) (\(result.starName))"
            } else {
                displayName = result.starName
            }
            displayNameByAstronomical[result.starName] = displayName
            return FixStarPositionEntry(displayName: displayName, result: result)
        }
        .sorted { $0.displayName < $1.displayName }

        let selectedFactors = config.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor }
        let parallelOrb = config.orbConfig.parallelOrb

        var newMatches: [FixStarMatch] = []
        for result in results {
            let starDisplayName = displayNameByAstronomical[result.starName] ?? result.starName
            for factor in selectedFactors {
                guard let pos = chart.Coordinates[factor],
                      !pos.ecliptical.isEmpty,
                      !pos.equatorial.isEmpty else { continue }

                let lonDiff = angularDifference(result.longitude, pos.ecliptical[0].mainPos)
                if lonDiff <= orbOverride {
                    newMatches.append(FixStarMatch(
                        starName: starDisplayName,
                        factor: factor,
                        matchType: .conjunction,
                        orb: lonDiff
                    ))
                }

                let declDiff = abs(result.declination - pos.equatorial[0].deviation)
                if declDiff <= parallelOrb {
                    newMatches.append(FixStarMatch(
                        starName: starDisplayName,
                        factor: factor,
                        matchType: .parallel,
                        orb: declDiff
                    ))
                }
            }
        }
        matches = newMatches.sorted { $0.orb < $1.orb }
    }

    private func angularDifference(_ a: Double, _ b: Double) -> Double {
        var diff = abs(a - b)
        if diff > 180 { diff = 360 - diff }
        return diff
    }
}
