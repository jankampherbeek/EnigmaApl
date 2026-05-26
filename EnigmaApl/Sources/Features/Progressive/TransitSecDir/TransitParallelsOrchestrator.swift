// TransitParallelsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// A found parallel or contra-parallel between a transit/progressive factor and a radix factor.
struct FoundParallel {
    let factor1: Factors        // transit or progressive factor
    let factor2: Factors        // radix factor
    let isContraParallel: Bool
    let orb: Double
    let maxOrb: Double
}

/// Calculates parallels and contra-parallels between transit/progressive positions and a radix chart.
/// factor1 in each FoundParallel is the transit/progressive factor; factor2 is the radix factor.
///
/// A **parallel** occurs when |transit_decl| ≈ |radix_decl| and both are on the same hemisphere.
/// A **contra-parallel** occurs when |transit_decl| ≈ |radix_decl| but on opposite hemispheres.
struct TransitParallelsOrchestrator {

    private init() {}

    static func calculate(
        transitPositions: [Factors: ProgressivePosition],
        radixChart: FullChart,
        factorConfig: FactorConfig,
        parallelOrb: Double
    ) -> [FoundParallel] {
        let transitPairs: [(Factors, Double)] = transitPositions.map { ($0.key, $0.value.declination) }
        guard !transitPairs.isEmpty else { return [] }

        let radixPairs = activeRadixDeclinations(chart: radixChart, factorConfig: factorConfig)
        guard !radixPairs.isEmpty else { return [] }

        var found: [FoundParallel] = []

        for (tFactor, tDecl) in transitPairs {
            for (rFactor, rDecl) in radixPairs {
                let orb = abs(abs(tDecl) - abs(rDecl))
                guard orb <= parallelOrb else { continue }
                let isContra = (tDecl >= 0.0) != (rDecl >= 0.0)
                found.append(FoundParallel(
                    factor1:          tFactor,
                    factor2:          rFactor,
                    isContraParallel: isContra,
                    orb:              orb,
                    maxOrb:           parallelOrb
                ))
            }
        }

        return found.sorted { $0.orb < $1.orb }
    }

    private static func activeRadixDeclinations(
        chart: FullChart,
        factorConfig: FactorConfig
    ) -> [(Factors, Double)] {
        factorConfig.factorSettings
            .filter { $0.isUsed }
            .compactMap { settings -> (Factors, Double)? in
                guard let decl = DeclMidpointsCalculator.declination(for: settings.factor, in: chart)
                else { return nil }
                return (settings.factor, decl)
            }
    }
}
