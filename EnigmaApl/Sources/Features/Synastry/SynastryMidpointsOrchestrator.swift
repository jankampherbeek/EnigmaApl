// SynastryMidpointsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates cross-chart midpoints for a synastry comparison: midpoints formed by
/// one chart's own factor pairs, occupied by the other chart's factors. Mirrors
/// `MidpointsOrchestrator.radixMidpointsOccupiedByProgressive` / `progressiveMidpointsOccupiedByRadix`,
/// generalized to two full charts.
struct SynastryMidpointsOrchestrator {

    private init() {}

    /// Returns midpoint matches where `midpointChart`'s own factor pairs form the midpoint
    /// and `occupantChart`'s factors are checked against it, sorted by orb (most exact first).
    static func midpoints(
        occupiedBy occupantChart: FullChart,
        formedBy midpointChart: FullChart,
        factorConfig: FactorConfig,
        orbConfig: OrbConfig,
        dialType: MidpointDialType
    ) -> [MidpointMatch] {
        let midpointPositions = activePositions(chart: midpointChart, factorConfig: factorConfig)
        guard midpointPositions.count >= 2 else { return [] }
        let occupantPositions = activePositions(chart: occupantChart, factorConfig: factorConfig)
        guard !occupantPositions.isEmpty else { return [] }

        let mids = MidpointsCalculator.calculate(positions: midpointPositions)
        return MidpointMatchFinder.find(
            baseMidpoints: mids,
            positions: occupantPositions,
            dialType: dialType,
            orb: orb(for: dialType, orbConfig: orbConfig)
        )
    }

    // MARK: - Private helpers

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

    private static func orb(for dialType: MidpointDialType, orbConfig: OrbConfig) -> Double {
        switch dialType {
        case .dial360: return orbConfig.midpoint360DialOrb
        case .dial90:  return orbConfig.midpoint90DialOrb
        case .dial45:  return orbConfig.midpoint45DialOrb
        }
    }
}
