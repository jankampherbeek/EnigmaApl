//
//  SERequest.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 22/12/2025.
//

import Foundation

public struct SERequest {
    public let JulianDay: Double
    public let FactorsToUse: [Factors]
    public let HouseSystem: Int
    public let SEFlags: Int
    public let Latitude: Double
    public let Longitude: Double
    
    public init(JulianDay: Double, FactorsToUse: [Factors], HouseSystem: Int, SEFlags: Int, Latitude: Double, Longitude: Double) {
        self.JulianDay = JulianDay
        self.FactorsToUse = FactorsToUse
        self.HouseSystem = HouseSystem
        self.SEFlags = SEFlags
        self.Latitude = Latitude
        self.Longitude = Longitude
    }
}

