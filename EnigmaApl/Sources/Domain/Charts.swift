//
//  Charts.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 22/12/2025.
//

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
