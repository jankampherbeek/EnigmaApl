// SynastryAspectsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates aspects formed between the factors of two charts (synastry).
/// factor1 in each FoundAspect is from chartA; factor2 is from chartB.
struct SynastryAspectsOrchestrator {

    private init() {}

    static func calculate(
        chartA: FullChart,
        chartB: FullChart,
        factorConfig: FactorConfig,
        aspectConfig: AspectConfig,
        orbConfig: OrbConfig
    ) -> [FoundAspect] {
        let positionsA = activePositions(chart: chartA, factorConfig: factorConfig)
        let positionsB = activePositions(chart: chartB, factorConfig: factorConfig)
        guard !positionsA.isEmpty, !positionsB.isEmpty else { return [] }

        let usedAspects = aspectConfig.aspectSettings.filter { $0.isUsed }
        guard !usedAspects.isEmpty else { return [] }

        let factorOrbPct: [Factors: Int] = Dictionary(
            uniqueKeysWithValues: factorConfig.factorSettings.map { ($0.factor, $0.orbPercentage) }
        )

        var found: [FoundAspect] = []

        for (fA, longA) in positionsA {
            for (fB, longB) in positionsB {
                let distance = shortestDistance(longA, longB)

                let orbFractionA = Double(factorOrbPct[fA] ?? 100) / 100.0
                let orbFractionB = Double(factorOrbPct[fB] ?? 100) / 100.0
                let maxFactorFraction = max(orbFractionA, orbFractionB)

                for aspectSetting in usedAspects {
                    let maxOrb = maxFactorFraction
                                 * (Double(aspectSetting.orbPercentage) / 100.0)
                                 * orbConfig.aspectBaseOrb
                    let deviation = abs(distance - aspectSetting.aspect.angle)
                    if deviation <= maxOrb {
                        found.append(FoundAspect(
                            factor1: fA,
                            factor2: fB,
                            aspect: aspectSetting.aspect,
                            orb: deviation,
                            maxOrb: maxOrb
                        ))
                    }
                }
            }
        }

        return found.sorted { $0.orb < $1.orb }
    }

    // MARK: - Private helpers

    /// Returns (factor, ecliptic longitude) for all used factors that have a position in the chart.
    /// Ascendant and MC are always included, since they're always relevant to a synastry
    /// comparison regardless of whether they were part of the chart's original calculation.
    private static func activePositions(
        chart: FullChart,
        factorConfig: FactorConfig
    ) -> [(Factors, Double)] {
        let usedFactors = Set(factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor })
        var positions: [(Factors, Double)] = chart.Coordinates.compactMap { factor, position in
            guard usedFactors.contains(factor),
                  let longitude = position.ecliptical.first?.mainPos else { return nil }
            return (factor, longitude)
        }

        let included = Set(positions.map { $0.0 })
        let angles: [(Factors, Double)] = [
            (.ascendant, chart.HousePositions.ascendant.longitude),
            (.mc, chart.HousePositions.midheaven.longitude)
        ]
        for (factor, longitude) in angles where !included.contains(factor) {
            positions.append((factor, longitude))
        }

        return positions
    }

    /// Shortest angular distance between two ecliptic longitudes, in the range 0–180°.
    private static func shortestDistance(_ long1: Double, _ long2: Double) -> Double {
        let diff = abs(long1 - long2).truncatingRemainder(dividingBy: 360.0)
        return diff > 180.0 ? 360.0 - diff : diff
    }
}
