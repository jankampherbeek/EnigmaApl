// CalcRequest.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

public struct CalcRequest {
    public let JulianDay: Double
    public let FactorsToUse: [Factors]
    public let HouseSystem: Int
    public let Latitude: Double
    public let Longitude: Double
    public let Height: Double
    public let calculationConfig: CalculationConfig

    public init(JulianDay: Double, FactorsToUse: [Factors], HouseSystem: Int, Latitude: Double, Longitude: Double, Height: Double, calculationConfig: CalculationConfig) {
        self.JulianDay = JulianDay
        self.FactorsToUse = FactorsToUse
        self.HouseSystem = HouseSystem
        self.Latitude = Latitude
        self.Longitude = Longitude
        self.Height = Height
        self.calculationConfig = calculationConfig
    }
}

