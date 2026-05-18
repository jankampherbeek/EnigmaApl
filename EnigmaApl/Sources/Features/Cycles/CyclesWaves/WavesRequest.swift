// WavesRequest.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Request for a waves calculation across a time period.
/// Describes the cycle type, interval between steps, time range, and coordinate to use.
public struct WavesRequest {
    /// The cycle type that defines the set of planets to include.
    /// Must be `.jupiter`, `.saturn`, or `.uranus`.
    public let CycleType: Factors
    /// Interval in days between successive calculations.
    public let Interval: Int
    /// Julian Day number for the start of the period.
    public let JdStart: Double
    /// Julian Day number for the end of the period.
    public let JdEnd: Double
    /// The coordinate to calculate for each planet.
    public let Coordinate: Coordinates

    public init(
        CycleType: Factors,
        Interval: Int,
        JdStart: Double,
        JdEnd: Double,
        Coordinate: Coordinates
    ) {
        self.CycleType = CycleType
        self.Interval = Interval
        self.JdStart = JdStart
        self.JdEnd = JdEnd
        self.Coordinate = Coordinate
    }
}
