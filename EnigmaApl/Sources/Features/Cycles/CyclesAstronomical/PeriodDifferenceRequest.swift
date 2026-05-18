// PeriodDifferenceRequest.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Request for a period-based calculation of the difference between pairs of celestial factors.
public struct PeriodDifferenceRequest {
    /// The pairs of celestial factors to compare.
    public let FactorPairs: [(factor1: Factors, factor2: Factors)]
    /// Interval in days between successive calculations.
    public let Interval: Double
    /// Julian Day number for the start of the period.
    public let JdStart: Double
    /// Julian Day number for the end of the period.
    public let JdEnd: Double
    /// The coordinate to calculate for both factors.
    public let Coordinate: Coordinates
    /// The ayanamsha to apply; use .tropical for no sidereal correction.
    public let Ayanamsha: Ayanamshas

    public init(
        FactorPairs: [(factor1: Factors, factor2: Factors)],
        Interval: Double,
        JdStart: Double,
        JdEnd: Double,
        Coordinate: Coordinates,
        Ayanamsha: Ayanamshas
    ) {
        self.FactorPairs = FactorPairs
        self.Interval = Interval
        self.JdStart = JdStart
        self.JdEnd = JdEnd
        self.Coordinate = Coordinate
        self.Ayanamsha = Ayanamsha
    }
}
