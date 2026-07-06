// PeriodCalculatorRequest.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Request for a period-based astronomical calculation.
/// Describes which factor to calculate, the interval between steps, the time range, and the coordinate to use.
public struct PeriodCalculatorRequest {
    /// The celestial factor to calculate.
    public let Factor: Factors
    /// Interval in days between successive calculations.
    public let Interval: Double
    /// Julian Day number for the start of the period.
    public let JdStart: Double
    /// Julian Day number for the end of the period.
    public let JdEnd: Double
    /// The coordinate to calculate for the factor.
    public let Coordinate: Coordinates
    /// The ayanamsha to apply; use .tropical for no sidereal correction.
    public let Ayanamsha: Ayanamshas
    /// The observer position (geocentric, heliocentric, topocentric).
    public let ObserverPosition: ObserverPositions

    public init(
        Factor: Factors,
        Interval: Double,
        JdStart: Double,
        JdEnd: Double,
        Coordinate: Coordinates,
        Ayanamsha: Ayanamshas,
        ObserverPosition: ObserverPositions = .geoCentric
    ) {
        self.Factor = Factor
        self.Interval = Interval
        self.JdStart = JdStart
        self.JdEnd = JdEnd
        self.Coordinate = Coordinate
        self.Ayanamsha = Ayanamsha
        self.ObserverPosition = ObserverPosition
    }
}
