// DeclinationsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Orchestrates declination calculations for a chart.
/// Intended to be called directly from the UI layer with sub-configs from `UserConfiguration`.
struct DeclinationsOrchestrator {

    private init() {}

    /// Returns all parallels and contra-parallels for the active factors in the chart.
    ///
    /// - Parameters:
    ///   - chart: The full chart with all factor positions.
    ///   - factorConfig: Determines which factors are included (`isUsed == true`).
    ///   - orbConfig: Supplies `parallelOrb`.
    /// - Returns: All `DefinedParallel` instances whose actual orb ≤ `parallelOrb`.
    static func parallels(
        chart: FullChart,
        factorConfig: FactorConfig,
        orbConfig: OrbConfig
    ) -> [DefinedParallel] {
        ParallelsCalculator.parallels(
            chart: chart,
            factorConfig: factorConfig,
            orbConfig: orbConfig
        )
    }

    /// Returns all occupied midpoints in declination for the active factors in the chart,
    /// sorted by `actualOrb` ascending (most exact first).
    ///
    /// - Parameters:
    ///   - chart: The full chart with all factor positions.
    ///   - factorConfig: Determines which factors are included (`isUsed == true`).
    ///   - orbConfig: Supplies `declinationMidpointOrb` as the orb for declination midpoints.
    /// - Returns: All `DeclOccupiedMidpoint` instances whose actual orb ≤ `declinationMidpointOrb`.
    static func occupiedMidpoints(
        chart: FullChart,
        factorConfig: FactorConfig,
        orbConfig: OrbConfig
    ) -> [DeclOccupiedMidpoint] {
        let baseMidpoints = DeclMidpointsCalculator.baseMidpoints(
            chart: chart,
            factorConfig: factorConfig
        )
        let positions = DeclMidpointsCalculator.activePairs(
            chart: chart,
            factorConfig: factorConfig
        )
        return DeclinationMidpointsMatchFinder.find(
            baseMidpoints: baseMidpoints,
            positions: positions,
            orb: orbConfig.declinationMidpointOrb
        )
    }

    /// Returns longitude equivalents for all active factors in the chart.
    ///
    /// - Parameters:
    ///   - chart: The full chart with all factor positions; `Obliquity` is read directly.
    ///   - factorConfig: Determines which factors are included (`isUsed == true`).
    /// - Returns: One `LongEquivalentResult` per active factor present in the chart.
    static func longitudeEquivalents(
        chart: FullChart,
        factorConfig: FactorConfig
    ) -> [LongEquivalentResult] {
        LongEquivalentsCalculator.equivalents(
            chart: chart,
            factorConfig: factorConfig
        )
    }
}
