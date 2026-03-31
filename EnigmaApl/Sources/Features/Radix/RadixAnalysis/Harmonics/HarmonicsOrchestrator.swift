// HarmonicsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Orchestrates harmonic calculations for a chart.
/// Intended to be called directly from the UI layer with sub-configs from `UserConfiguration`.
struct HarmonicsOrchestrator {

    private init() {}

    /// Returns the harmonic positions for all active factors in the chart, sorted by harmonic longitude.
    /// - Parameters:
    ///   - chart: The full chart with all factor positions.
    ///   - factorConfig: Determines which factors are included.
    ///   - harmonic: The harmonic number to apply.
    /// - Returns: Sorted list of `HarmonicPosition`, or empty if no active factors are found.
    static func harmonicPositions(
        chart: FullChart,
        factorConfig: FactorConfig,
        harmonic: Double
    ) -> [HarmonicPosition] {
        let positions = activePositions(chart: chart, factorConfig: factorConfig)
        guard !positions.isEmpty else { return [] }
        return HarmonicsCalculator.calculate(positions: positions, harmonic: harmonic)
    }

    /// Returns all matches between harmonic positions and radix positions, sorted by orb (most exact first).
    /// - Parameters:
    ///   - chart: The full chart with all factor positions.
    ///   - factorConfig: Determines which factors are included.
    ///   - orbConfig: Provides the harmonic orb.
    ///   - harmonic: The harmonic number to apply.
    /// - Returns: Sorted list of `HarmonicMatch`, or empty if no active factors are found.
    static func matches(
        chart: FullChart,
        factorConfig: FactorConfig,
        orbConfig: OrbConfig,
        harmonic: Double
    ) -> [HarmonicMatch] {
        let positions = activePositions(chart: chart, factorConfig: factorConfig)
        guard !positions.isEmpty else { return [] }
        let harmonics = HarmonicsCalculator.calculate(positions: positions, harmonic: harmonic)
        return HarmonicsMatchFinder.find(
            harmonics: harmonics,
            radixPositions: positions,
            orb: orbConfig.harmonicOrb
        )
    }

    // MARK: - Private helpers

    /// Returns (factor, ecliptic longitude) for all used factors that have a position in the chart.
    private static func activePositions(
        chart: FullChart,
        factorConfig: FactorConfig
    ) -> [(Factors, Double)] {
        let usedFactors = Set(factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor })
        return chart.Coordinates.compactMap { factor, position in
            guard usedFactors.contains(factor),
                  let longitude = position.ecliptical.first?.mainPos else { return nil }
            return (factor, longitude)
        }
    }
}
