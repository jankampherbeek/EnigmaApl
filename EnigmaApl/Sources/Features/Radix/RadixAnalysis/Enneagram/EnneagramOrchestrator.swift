// EnneagramOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Coordinates the enneagram calculation from a FullChart and user options.
struct EnneagramOrchestrator {

    private init() {}

    struct Options {
        var useHouses: Bool = true
        var doublePluto: Bool = false
        var useUpdatedVersion: Bool = true
    }

    /// Returns the 9 type strengths, sorted highest-first.
    static func strengths(chart: FullChart, options: Options) -> [EnneagramTypeResult] {
        let signsData  = EnneagramDataLoader.signs(updated: options.useUpdatedVersion)
        let housesData = EnneagramDataLoader.houses(updated: options.useUpdatedVersion)
        let positions  = activePositions(chart: chart)
        let cusps      = buildCuspArray(chart: chart)
        return EnneagramCalculator.calculateStrengths(
            signs: signsData,
            houses: housesData,
            factorPositions: positions,
            cuspLongitudes: cusps,
            useHouses: options.useHouses,
            doublePluto: options.doublePluto
        )
    }

    /// Returns per-factor detail lines.
    static func details(chart: FullChart, options: Options) -> [EnneagramDetailLine] {
        let signsData  = EnneagramDataLoader.signs(updated: options.useUpdatedVersion)
        let housesData = EnneagramDataLoader.houses(updated: options.useUpdatedVersion)
        let positions  = activePositions(chart: chart)
        let cusps      = buildCuspArray(chart: chart)
        return EnneagramCalculator.calculateDetails(
            signs: signsData,
            houses: housesData,
            factorPositions: positions,
            cuspLongitudes: cusps,
            useHouses: options.useHouses,
            doublePluto: options.doublePluto
        )
    }

    // MARK: - Helpers

    private static func activePositions(chart: FullChart) -> [(Factors, Double)] {
        EnneagramCalculator.factorToPointId.keys.compactMap { factor -> (Factors, Double)? in
            guard let pos = chart.Coordinates[factor],
                  let longitude = pos.ecliptical.first?.mainPos else { return nil }
            return (factor, longitude)
        }
    }

    /// Builds a [Double] where index 0 is unused and [1..12] are the cusp longitudes.
    private static func buildCuspArray(chart: FullChart) -> [Double] {
        var arr = [Double](repeating: 0.0, count: 13)
        let cusps = chart.HousePositions.cusps
        for i in 0..<min(12, cusps.count) {
            arr[i + 1] = cusps[i].longitude
        }
        return arr
    }
}
