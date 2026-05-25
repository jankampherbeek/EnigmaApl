// TransitAspectsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates aspects between a set of transit positions and a radix chart.
/// factor1 in each FoundAspect is the transit factor; factor2 is the radix factor.
struct TransitAspectsOrchestrator {

    private init() {}

    static func calculate(
        transitPositions: [Factors: ProgressivePosition],
        radixChart: FullChart,
        factorConfig: FactorConfig,
        aspectConfig: AspectConfig,
        orbConfig: OrbConfig
    ) -> [FoundAspect] {
        let transitPairs: [(Factors, Double)] = transitPositions.map { ($0.key, $0.value.longitude) }
        guard !transitPairs.isEmpty else { return [] }

        let radixPairs = activeRadixPositions(chart: radixChart, factorConfig: factorConfig)
        guard !radixPairs.isEmpty else { return [] }

        let usedAspects = aspectConfig.aspectSettings.filter { $0.isUsed }
        guard !usedAspects.isEmpty else { return [] }

        let factorOrbPct: [Factors: Int] = Dictionary(
            uniqueKeysWithValues: factorConfig.factorSettings.map { ($0.factor, $0.orbPercentage) }
        )

        var found: [FoundAspect] = []

        for (tFactor, tLong) in transitPairs {
            for (rFactor, rLong) in radixPairs {
                let distance = shortestDistance(tLong, rLong)
                let tOrbFraction = Double(factorOrbPct[tFactor] ?? 100) / 100.0
                let rOrbFraction = Double(factorOrbPct[rFactor] ?? 100) / 100.0
                let maxFactorFraction = max(tOrbFraction, rOrbFraction)

                for aspectSetting in usedAspects {
                    let maxOrb = maxFactorFraction
                                 * (Double(aspectSetting.orbPercentage) / 100.0)
                                 * orbConfig.aspectBaseOrb
                    let deviation = abs(distance - aspectSetting.aspect.angle)
                    if deviation <= maxOrb {
                        found.append(FoundAspect(
                            factor1: tFactor,
                            factor2: rFactor,
                            aspect:  aspectSetting.aspect,
                            orb:     deviation,
                            maxOrb:  maxOrb
                        ))
                    }
                }
            }
        }

        return found.sorted { $0.orb < $1.orb }
    }

    // MARK: - Private helpers

    private static func activeRadixPositions(
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

    private static func shortestDistance(_ long1: Double, _ long2: Double) -> Double {
        let diff = abs(long1 - long2).truncatingRemainder(dividingBy: 360.0)
        return diff > 180.0 ? 360.0 - diff : diff
    }
}
