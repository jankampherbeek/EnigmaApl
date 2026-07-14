// SynastryDeclinationOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates parallels and contra-parallels formed between the factors of two charts (synastry).
/// factor1 in each DefinedParallel is from chartA; factor2 is from chartB.
struct SynastryDeclinationOrchestrator {

    private init() {}

    static func calculate(
        chartA: FullChart,
        chartB: FullChart,
        factorConfig: FactorConfig,
        orbConfig: OrbConfig
    ) -> [DefinedParallel] {
        let positionsA = DeclMidpointsCalculator.activePairs(chart: chartA, factorConfig: factorConfig)
        let positionsB = DeclMidpointsCalculator.activePairs(chart: chartB, factorConfig: factorConfig)
        guard !positionsA.isEmpty, !positionsB.isEmpty else { return [] }

        let maxOrb = orbConfig.parallelOrb
        var found: [DefinedParallel] = []

        for (fA, declA) in positionsA {
            for (fB, declB) in positionsB {
                let actualOrb = abs(abs(declA) - abs(declB))
                guard actualOrb <= maxOrb else { continue }
                let isContra = (declA >= 0.0) != (declB >= 0.0)
                found.append(DefinedParallel(
                    factor1: fA,
                    factor2: fB,
                    isContraParallel: isContra,
                    maxOrb: maxOrb,
                    actualOrb: actualOrb
                ))
            }
        }

        return found.sorted { $0.actualOrb < $1.actualOrb }
    }
}
