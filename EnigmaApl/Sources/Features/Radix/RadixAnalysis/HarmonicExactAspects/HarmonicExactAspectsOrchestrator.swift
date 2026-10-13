// HarmonicExactAspectsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Orchestrates the search for the most exact aspect in a range of harmonics.
/// Intended to be called directly from the UI layer with sub-configs from `UserConfiguration`.
struct HarmonicExactAspectsOrchestrator {

    private init() {}

    static let minHarmonic = 2

    /// Returns, for each harmonic from 2 up to and including `maxHarmonic`, the aspect(s) with the smallest orb.
    /// - Parameters:
    ///   - chart: The full chart with all factor positions.
    ///   - factorConfig: Determines which factors are included (Ascendant and MC excepted).
    ///   - aspectConfig: Provides the used aspects when `aspectSelection` is `.configured`.
    ///   - includeAscendant: Include the Ascendant, regardless of the factor config.
    ///   - includeMc: Include the MC, regardless of the factor config.
    ///   - aspectSelection: Configured aspects or the major aspects.
    ///   - maxHarmonic: Highest harmonic to examine.
    /// - Returns: Results sorted by harmonic; empty if there are fewer than two factors or no aspects.
    static func exactAspects(
        chart: FullChart,
        factorConfig: FactorConfig,
        aspectConfig: AspectConfig,
        includeAscendant: Bool,
        includeMc: Bool,
        aspectSelection: HarmonicAspectSelection,
        maxHarmonic: Int
    ) -> [HarmonicExactAspect] {
        guard maxHarmonic >= minHarmonic else { return [] }
        let positions = radixPositions(chart: chart, factorConfig: factorConfig,
                                       includeAscendant: includeAscendant, includeMc: includeMc)
        let aspects = selectedAspects(aspectSelection, aspectConfig: aspectConfig)
        guard positions.count >= 2, !aspects.isEmpty else { return [] }

        return (minHarmonic...maxHarmonic).flatMap { harmonic in
            let harmonicPositions = HarmonicsCalculator.calculate(positions: positions, harmonic: Double(harmonic))
            return HarmonicExactAspectsFinder.find(positions: harmonicPositions, aspects: aspects, harmonic: harmonic)
        }
    }

    // MARK: - Private helpers

    private static func selectedAspects(_ selection: HarmonicAspectSelection,
                                        aspectConfig: AspectConfig) -> [Aspects] {
        switch selection {
        case .configured: return aspectConfig.aspectSettings.filter { $0.isUsed }.map { $0.aspect }
        case .major:      return HarmonicAspectSelection.majorAspects
        }
    }

    /// Returns (factor, ecliptic longitude) for all used factors in the chart.
    /// ASC and MC are sourced from HousePositions, depending on the include flags.
    private static func radixPositions(
        chart: FullChart,
        factorConfig: FactorConfig,
        includeAscendant: Bool,
        includeMc: Bool
    ) -> [(Factors, Double)] {
        let usedFactors = Set(factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor })
        var positions = chart.Coordinates.compactMap { factor, position -> (Factors, Double)? in
            guard usedFactors.contains(factor), factor != .ascendant, factor != .mc,
                  let longitude = position.ecliptical.first?.mainPos else { return nil }
            return (factor, longitude)
        }
        if includeAscendant {
            positions.append((.ascendant, chart.HousePositions.ascendant.longitude))
        }
        if includeMc {
            positions.append((.mc, chart.HousePositions.midheaven.longitude))
        }
        return positions
    }
}
