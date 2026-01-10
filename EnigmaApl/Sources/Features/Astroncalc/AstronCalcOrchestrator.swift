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
        let housePositions = SECalculation.CalculateHouses(request, obliquity: obliquity, seWrapper: seWrapper)
        
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
            let commonSeCoordinates = SECalculation.CalculateFactors(commonSeRequest, seWrapper: seWrapper)
            allCoordinates.merge(commonSeCoordinates) { (_, new) in new }
            longitudeSun = commonSeCoordinates[.sun]?.ecliptical.first?.mainPos ?? -1.0
            longitudeMoon = commonSeCoordinates[.moon]?.ecliptical.first?.mainPos ?? -1.0
        }
        if let commonElementsFactors = factorsByType[.CommonElements], !commonElementsFactors.isEmpty {
            let commonElementsCoordinates = ElementsCalc.calculateElementsFactors(request: request, seWrapper: seWrapper)
            allCoordinates.merge(commonElementsCoordinates) { (_, new) in new }
        }
        
        if let commonFormulaLongitudeFactors = factorsByType[.CommonFormulaLongitude], !commonFormulaLongitudeFactors.isEmpty {
            let fCalc = FormulaCalc(seWrapper: seWrapper)
            let commonFormulaLongitudeCoordinates = fCalc.calculateFormulaFactors(seRequest: request)
            allCoordinates.merge(commonFormulaLongitudeCoordinates) { (_, new) in new }
        }
        
        if let commonFormulaFullFactors = factorsByType[.CommonFormulaFull], !commonFormulaFullFactors.isEmpty {
            let fFullCalc = FormulaFullCalc(seWrapper: seWrapper)
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
        
        if (request.ConfigData.projectionType == ProjectionTypes.obliqueLongitude) {
            // exchange all longitudes with their oblique longitude equivalents
            
            let armc = housePositions.midheaven.rightAscension
            
            let ayanamshaOffset: Double
            if request.ConfigData.ayanamsha == .tropical {
                ayanamshaOffset = 0.0
            } else {
                // TODO: Calculate ayanamsha offset using SEWrapper
                // For now, using 0.0 as placeholder - this may need to be calculated
                ayanamshaOffset = 0.0
            }
            
            // Build array of NamedEclipticCoordinates from allCoordinates
            var celPointCoordinates: [NamedEclipticCoordinates] = []
            for (factor, position) in allCoordinates {
                if let ecliptical = position.ecliptical.first {
                    celPointCoordinates.append(NamedEclipticCoordinates(
                        factor: factor,
                        longitude: ecliptical.mainPos,
                        latitude: ecliptical.deviation
                    ))
                }
            }
            
            // Calculate oblique longitudes
            let obliqueLongitudeCalc = ObliqueLongitudeCalc()
            let obliqueLongitudes = obliqueLongitudeCalc.ObliqueLongitudeForFactor(
                armc: armc,
                obliquity: obliquity,
                geoLat: request.Latitude,
                celPointCoordinates: celPointCoordinates,
                ayanamshaOffset: ayanamshaOffset
            )
            
            // Create a dictionary mapping factors to their oblique longitudes
            let obliqueLongitudeMap = Dictionary(uniqueKeysWithValues: obliqueLongitudes.map { ($0.factor, $0.obliqueLongitude) })
            
            // Create a copy of allCoordinates with oblique longitudes replacing ecliptical longitudes
            var updatedCoordinates: [Factors: FullFactorPosition] = [:]
            for (factor, position) in allCoordinates {
                if let obliqueLongitude = obliqueLongitudeMap[factor],
                   let originalEcliptical = position.ecliptical.first {
                    // Create new ecliptical positions array, updating the first position with oblique longitude
                    var updatedEclipticalPositions: [MainAstronomicalPosition] = []
                    for (index, eclipticalPos) in position.ecliptical.enumerated() {
                        if index == 0 {
                            // Replace longitude with oblique longitude for the first position
                            updatedEclipticalPositions.append(MainAstronomicalPosition(
                                mainPos: obliqueLongitude,
                                deviation: eclipticalPos.deviation,
                                distance: eclipticalPos.distance,
                                mainPosSpeed: eclipticalPos.mainPosSpeed,
                                deviationSpeed: eclipticalPos.deviationSpeed,
                                distanceSpeed: eclipticalPos.distanceSpeed
                            ))
                        } else {
                            // Keep other ecliptical positions unchanged
                            updatedEclipticalPositions.append(eclipticalPos)
                        }
                    }
                    // Create new FullFactorPosition with updated ecliptical positions
                    let updatedPosition = FullFactorPosition(
                        ecliptical: updatedEclipticalPositions,
                        equatorial: position.equatorial,
                        horizontal: position.horizontal
                    )
                    updatedCoordinates[factor] = updatedPosition
                } else {
                    // Keep original position if no oblique longitude was calculated
                    updatedCoordinates[factor] = position
                }
            }
            
            // Replace allCoordinates with the updated version
            allCoordinates = updatedCoordinates
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

