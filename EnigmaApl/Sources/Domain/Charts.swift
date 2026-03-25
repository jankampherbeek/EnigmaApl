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
    
    public init(
        Coordinates: [Factors: FullFactorPosition],
        HousePositions: HousePositions,
        SiderealTime: Double,
        JulianDay: Double,
        Obliquity: Double
    ) {
        self.Coordinates = Coordinates
        self.HousePositions = HousePositions
        self.SiderealTime = SiderealTime
        self.JulianDay = JulianDay
        self.Obliquity = Obliquity
    }
}
