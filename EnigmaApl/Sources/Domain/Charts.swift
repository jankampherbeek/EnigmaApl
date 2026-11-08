// Charts.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

public struct FullChart {
    public let Coordinates: [Factors: FullFactorPosition]
    public let HousePositions: HousePositions
    public let SiderealTime: Double
    public let JulianDay: Double
    public let Obliquity: Double
    /// Factors that could not be calculated, e.g. because the date is outside the range of the ephemeris.
    public let omittedFactors: [Factors]
    /// Factors that were requested but have no meaning for the observer position,
    /// e.g. Sun, Moon and lunar nodes in a heliocentric chart. They are not calculated.
    public let skippedFactors: [Factors]

    public init(
        Coordinates: [Factors: FullFactorPosition],
        HousePositions: HousePositions,
        SiderealTime: Double,
        JulianDay: Double,
        Obliquity: Double,
        omittedFactors: [Factors] = [],
        skippedFactors: [Factors] = []
    ) {
        self.Coordinates = Coordinates
        self.HousePositions = HousePositions
        self.SiderealTime = SiderealTime
        self.JulianDay = JulianDay
        self.Obliquity = Obliquity
        self.omittedFactors = omittedFactors
        self.skippedFactors = skippedFactors
    }
}
