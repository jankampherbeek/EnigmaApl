// MidpointsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Orchestrates midpoint calculations for a chart.
/// Intended to be called directly from the UI layer with sub-configs from `UserConfiguration`.
struct MidpointsOrchestrator {

    private init() {}

    /// Returns all base midpoints for the active factors in the chart, sorted by position (0–360°).
    /// - Parameters:
    ///   - chart: The full chart with all factor positions.
    ///   - factorConfig: Determines which factors are included.
    /// - Returns: Sorted list of `BaseMidpoint`, or empty if fewer than two active factors are found.
    static func baseMidpoints(
        chart: FullChart,
        factorConfig: FactorConfig
    ) -> [BaseMidpoint] {
        let positions = activePositions(chart: chart, factorConfig: factorConfig)
        guard positions.count >= 2 else { return [] }
        return MidpointsCalculator.calculate(positions: positions)
    }

    /// Returns all midpoint matches for the active factors in the chart, sorted by orb (most exact first).
    /// - Parameters:
    ///   - chart: The full chart with all factor positions.
    ///   - factorConfig: Determines which factors are included.
    ///   - orbConfig: Provides the midpoint orb for the given dial type.
    ///   - dialType: Determines which angular separations count as a match.
    /// - Returns: Sorted list of `MidpointMatch`, or empty if fewer than two active factors are found.
    static func matches(
        chart: FullChart,
        factorConfig: FactorConfig,
        orbConfig: OrbConfig,
        dialType: MidpointDialType
    ) -> [MidpointMatch] {
        let positions = activePositions(chart: chart, factorConfig: factorConfig)
        guard positions.count >= 2 else { return [] }
        let mids = MidpointsCalculator.calculate(positions: positions)
        let orb: Double
        switch dialType {
        case .dial360: orb = orbConfig.midpoint360DialOrb
        case .dial90:  orb = orbConfig.midpoint90DialOrb
        case .dial45:  orb = orbConfig.midpoint45DialOrb
        }
        return MidpointMatchFinder.find(
            baseMidpoints: mids,
            positions: positions,
            dialType: dialType,
            orb: orb
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
