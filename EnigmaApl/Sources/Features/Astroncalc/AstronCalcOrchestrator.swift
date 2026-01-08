//
//  CalculationOrchestrator.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 22/12/2025.
//

import Foundation

public struct AstronCalcOrchestrator {
    
    /// Performs a full chart calculation based on the provided request
    /// - Parameter request: The SERequest containing calculation parameters
    /// - Returns: A FullChart with all calculated positions and house data
    public static func PerformCalculation(_ request: SERequest) -> FullChart {
        // Create and initialize SEWrapper early to ensure Swiss Ephemeris is initialized
        // This ensures the ephemeris path is set and the library is ready
        // The init() already calls initialize(), creating the wrapper ensures initialization happens
        let seWrapper = SEWrapper()
        
        let julianDay = request.JulianDay
        
        // Calculate obliquity using id -1
        let obliquityPosition = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            planet: -1,
            flags: 2          // Use SE, no need for speed
        )
        let obliquity = obliquityPosition?.mainPos ?? 0.0
        
        let siderealTime = seWrapper.siderealTime(julianDay: julianDay)
        let housePositions = SECalculation.CalculateHouses(request, obliquity: obliquity)
        
        // Group factors by calculation type
        let factorsByType = Dictionary(grouping: request.FactorsToUse) { $0.calculationType }
        
        // Calculate factors for each calculation type
        var allCoordinates: [Factors: FullFactorPosition] = [:]
        var longitudeSun = -1.0
        var longitudeMoon = 1.0
        
        // Handle CommonSe factors first (these need to calculate obliquity)
        if let commonSeFactors = factorsByType[.CommonSe], !commonSeFactors.isEmpty {
            // Create a temporary request with only CommonSe factors
            let commonSeRequest = SERequest(
                JulianDay: request.JulianDay,
                FactorsToUse: commonSeFactors,
                HouseSystem: request.HouseSystem,
                SEFlags: request.SEFlags,
                Latitude: request.Latitude,
                Longitude: request.Longitude,
                ConfigData: request.ConfigData
            )
            let commonSeCoordinates = SECalculation.CalculateFactors(commonSeRequest)
            allCoordinates.merge(commonSeCoordinates) { (_, new) in new }
            longitudeSun = commonSeCoordinates[.sun]?.ecliptical.first?.mainPos ?? -1.0
            longitudeMoon = commonSeCoordinates[.moon]?.ecliptical.first?.mainPos ?? -1.0
        }
        if let commonElementsFactors = factorsByType[.CommonElements], !commonElementsFactors.isEmpty {
            let commonElementsCoordinates = ElementsCalc.calculateElementsFactors(request: request)
            allCoordinates.merge(commonElementsCoordinates) { (_, new) in new }
        }
        
        if let commonFormulaLongitudeFactors = factorsByType[.CommonFormulaLongitude], !commonFormulaLongitudeFactors.isEmpty {
            let fCalc = FormulaCalc()
            let commonFormulaLongitudeCoordinates = fCalc.calculateFormulaFactors(seRequest: request)
            allCoordinates.merge(commonFormulaLongitudeCoordinates) { (_, new) in new }
        }
        
        if let commonFormulaFullFactors = factorsByType[.CommonFormulaFull], !commonFormulaFullFactors.isEmpty {
            let fFullCalc = FormulaFullCalc()
            let commonFormulaFullCoordinates = fFullCalc.CalculateFormulaFullFactors(seWrapper: seWrapper, seRequest: request, obliquity: obliquity)
            allCoordinates.merge(commonFormulaFullCoordinates) { (_, new) in new }
        }
        
        if let lotsFactors = factorsByType[.Lots], !lotsFactors.isEmpty {
            // Extract required longitudes for lots calculation
            let ascendantLongitude = housePositions.ascendant.longitude
            let sunLongitude = allCoordinates[.sun]?.ecliptical.first?.mainPos ?? -1.0
            let moonLongitude = allCoordinates[.moon]?.ecliptical.first?.mainPos ?? -1.0
            if (sunLongitude > 0.0 && moonLongitude > 0.0) {
                
                let lotsCalc = LotsCalc(seWrapper: seWrapper)
                let lotsRequest = SERequest(
                    JulianDay: request.JulianDay,
                    FactorsToUse: lotsFactors,
                    HouseSystem: request.HouseSystem,
                    SEFlags: request.SEFlags,
                    Latitude: request.Latitude,
                    Longitude: request.Longitude,
                    ConfigData: request.ConfigData
                )
                let lotsCoordinates = lotsCalc.calculateLotsFactors(
                    seRequest: lotsRequest,
                    obliquity: obliquity,
                    ascendantLongitude: ascendantLongitude,
                    sunLongitude: sunLongitude,
                    moonLongitude: moonLongitude
                )
                allCoordinates.merge(lotsCoordinates) { (_, new) in new }
            }
        }
        
        if let zodiacFixedFactors = factorsByType[.ZodiacFixed], !zodiacFixedFactors.isEmpty {
            let zodiacFixedCalc = ZodiacFixedCalc()
            let zodiacFixedCoordinates = zodiacFixedCalc.zodiacFixedFactors(seRequest: request, obliquity: obliquity, seWrapper: seWrapper)
            allCoordinates.merge(zodiacFixedCoordinates) { (_, new) in new }
        }
        
        if let apsidesFactors = factorsByType[.Apsides], !apsidesFactors.isEmpty {
            let apsidesCalc = ApsidesCalc(seWrapper: seWrapper)
            let apsidesRequest = SERequest(
                JulianDay: request.JulianDay,
                FactorsToUse: apsidesFactors,
                HouseSystem: request.HouseSystem,
                SEFlags: request.SEFlags,
                Latitude: request.Latitude,
                Longitude: request.Longitude,
                ConfigData: request.ConfigData
            )
            let apsidesCoordinates = apsidesCalc.calculateApsidesFactors(seRequest: apsidesRequest)
            allCoordinates.merge(apsidesCoordinates) { (_, new) in new }
        }
        
        
        return FullChart(
            Coordinates: allCoordinates,
            HousePositions: housePositions,
            SiderealTime: siderealTime,
            JulianDay: julianDay,
            Obliquity: obliquity
        )
    }
    
  
}

