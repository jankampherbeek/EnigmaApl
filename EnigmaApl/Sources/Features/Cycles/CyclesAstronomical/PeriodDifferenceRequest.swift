// PeriodDifferenceRequest.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Request for a period-based calculation of the difference between two celestial factors.
public struct PeriodDifferenceRequest {
    /// The first celestial factor.
    public let Factor1: Factors
    /// The second celestial factor.
    public let Factor2: Factors
    /// Interval in days between successive calculations.
    public let Interval: Double
    /// Julian Day number for the start of the period.
    public let JdStart: Double
    /// Julian Day number for the end of the period.
    public let JdEnd: Double
    /// The coordinate to calculate for both factors.
    public let Coordinate: Coordinates

    public init(
        Factor1: Factors,
        Factor2: Factors,
        Interval: Double,
        JdStart: Double,
        JdEnd: Double,
        Coordinate: Coordinates
    ) {
        self.Factor1 = Factor1
        self.Factor2 = Factor2
        self.Interval = Interval
        self.JdStart = JdStart
        self.JdEnd = JdEnd
        self.Coordinate = Coordinate
    }
}
