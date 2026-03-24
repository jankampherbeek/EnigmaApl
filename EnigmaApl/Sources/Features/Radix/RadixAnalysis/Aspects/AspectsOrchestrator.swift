// AspectsOrchestrator.swift
// EnigmaApl
//
// Calculates all aspects present in a FullChart.
//
// Orb formula (weighted):
//   maxOrb = max(factorOrbFraction1, factorOrbFraction2) × aspectOrbFraction × baseOrb
// where fractions are orbPercentage / 100 from FactorConfig and AspectConfig.
//
// Only factors with isUsed = true in FactorConfig and a valid ecliptic position
// in chart.Coordinates participate. Only aspects with isUsed = true in AspectConfig
// are checked.

import Foundation

struct AspectsOrchestrator {

    private init() {}

    /// Returns all aspects found in the chart, sorted by orb (most exact first).
    static func calculate(
        chart: FullChart,
        factorConfig: FactorConfig,
        aspectConfig: AspectConfig,
        orbConfig: OrbConfig
    ) -> [FoundAspect] {
        let positions = activePositions(chart: chart, factorConfig: factorConfig)
        guard positions.count >= 2 else { return [] }

        let usedAspects = aspectConfig.aspectSettings.filter { $0.isUsed }
        guard !usedAspects.isEmpty else { return [] }

        // Build lookup tables for orb percentages
        let factorOrbPct: [Factors: Int] = Dictionary(
            uniqueKeysWithValues: factorConfig.factorSettings.map { ($0.factor, $0.orbPercentage) }
        )

        var found: [FoundAspect] = []

        for i in 0..<positions.count {
            for j in (i + 1)..<positions.count {
                let (f1, long1) = positions[i]
                let (f2, long2) = positions[j]
                let distance = shortestDistance(long1, long2)

                let orbFraction1 = Double(factorOrbPct[f1] ?? 100) / 100.0
                let orbFraction2 = Double(factorOrbPct[f2] ?? 100) / 100.0
                let maxFactorFraction = max(orbFraction1, orbFraction2)

                for aspectSetting in usedAspects {
                    let maxOrb = maxFactorFraction
                                 * (Double(aspectSetting.orbPercentage) / 100.0)
                                 * orbConfig.aspectBaseOrb
                    let deviation = abs(distance - aspectSetting.aspect.angle)
                    if deviation <= maxOrb {
                        found.append(FoundAspect(
                            factor1: f1,
                            factor2: f2,
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

    /// Shortest angular distance between two ecliptic longitudes, in the range 0–180°.
    private static func shortestDistance(_ long1: Double, _ long2: Double) -> Double {
        let diff = abs(long1 - long2).truncatingRemainder(dividingBy: 360.0)
        return diff > 180.0 ? 360.0 - diff : diff
    }
}
