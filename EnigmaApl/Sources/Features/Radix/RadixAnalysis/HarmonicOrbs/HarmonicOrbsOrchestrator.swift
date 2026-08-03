// HarmonicOrbsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

struct HarmonicOrbsOrchestrator {

    private init() {}

    /// Returns all aspects found in the chart using a flat per-aspect orb (maximum orb divided by
    /// the aspect's harmonic number), considering only the selected aspect settings.
    static func calculate(
        chart: FullChart,
        factorConfig: FactorConfig,
        settings: [HarmonicOrbSetting],
        maxOrbDegrees: Double
    ) -> [FoundAspect] {
        let positions = activePositions(chart: chart, factorConfig: factorConfig)
        guard positions.count >= 2 else { return [] }

        let selected = settings.filter { $0.isSelected }
        guard !selected.isEmpty else { return [] }

        var found: [FoundAspect] = []

        for i in 0..<positions.count {
            for j in (i + 1)..<positions.count {
                let (f1, long1) = positions[i]
                let (f2, long2) = positions[j]
                let distance = shortestDistance(long1, long2)

                for setting in selected {
                    let maxOrb = maxOrbDegrees / Double(setting.harmonicNumber)
                    let deviation = abs(distance - setting.aspect.angle)
                    if deviation <= maxOrb {
                        found.append(FoundAspect(
                            factor1: f1,
                            factor2: f2,
                            aspect: setting.aspect,
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
