//
//  CalculationOrchestrator.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 22/12/2025.
//

import Foundation

public struct AstronCalcOrchestrator {
    
    /// Performs a full chart calculation based on the provided request
    /// - Parameters:
    ///   - request: The CalcRequest containing calculation parameters
    ///   - seWrapper: SEWrapper instance. Must be provided to ensure thread-safety with Swiss Ephemeris.
    ///                For production, use the app-level instance. For tests, use SEWrapperTestCoordinator.shared.getSEWrapper()
    /// - Returns: A FullChart with all calculated positions and house data
    public static func PerformCalculation(_ request: CalcRequest, seWrapper: SEWrapper) -> FullChart {
        
        let julianDay = request.JulianDay
        let seFlagsEcliptical = SEFlags.defineFlags(configData: request.ConfigData, coordSystem: CoordinateSystems.ecliptical)
        let seFlagsEquatorial = SEFlags.defineFlags(configData: request.ConfigData, coordSystem: CoordinateSystems.equatorial)
        
        // check for topocentric
        if (request.ConfigData.observerPosition == ObserverPositions.topoCentric) {
            seWrapper.setTopocentric(geoLon: request.Longitude, geoLat: request.Latitude, height: request.Height)
        }
        
        // Calculate obliquity using id -1
        let obliquityPosition = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            factor: -1,
            flags: 2          // Use SE, no need for speed
        )
        let obliquity = obliquityPosition?.mainPos ?? 0.0
        
        var ayanamshaOffset = 0.0;
        if (request.ConfigData.ayanamsha != Ayanamshas.tropical) {
            seWrapper.setAyanamsha(idAyanamsha: request.ConfigData.ayanamsha)
            ayanamshaOffset = seWrapper.getAyanamshaOffset(jdUt: julianDay)
        }

        let housePositions = SECalculation.CalculateHouses(request, obliquity: obliquity, seWrapper: seWrapper)
        let siderealTime = housePositions.midheaven.rightAscension / 15.0
        
        // Group factors by calculation type
        let factorsByType = Dictionary(grouping: request.FactorsToUse) { $0.calculationType }
        
        // Calculate factors for each calculation type
        var allCoordinates: [Factors: FullFactorPosition] = [:]
        var longitudeSun = -1.0
        var longitudeMoon = -1.0
        
        // Handle CommonSe factors
        if let commonSeFactors = factorsByType[.CommonSe], !commonSeFactors.isEmpty {
            // Create a temporary request with only CommonSe factors
            let commonRequest = CalcRequest(
                JulianDay: request.JulianDay,
                FactorsToUse: commonSeFactors,
                HouseSystem: request.HouseSystem,
                Latitude: request.Latitude,
                Longitude: request.Longitude,
                Height: request.Height,
                ConfigData: request.ConfigData
            )
            let commonSeCoordinates = SECalculation.CalculateFactors(commonRequest, flagsEcliptical: seFlagsEcliptical, flagsEquatorial: seFlagsEquatorial, seWrapper: seWrapper)
            allCoordinates.merge(commonSeCoordinates) { (_, new) in new }
            longitudeSun = commonSeCoordinates[Factors.sun]?.ecliptical.first?.mainPos ?? -1.0
            longitudeMoon = commonSeCoordinates[Factors.moon]?.ecliptical.first?.mainPos ?? -1.0
        }
        if let commonElementsFactors = factorsByType[.CommonElements], !commonElementsFactors.isEmpty {
            let commonElementsRequest = CalcRequest(
                JulianDay: request.JulianDay,
                FactorsToUse: commonElementsFactors,
                HouseSystem: request.HouseSystem,
                Latitude: request.Latitude,
                Longitude: request.Longitude,
                Height: request.Height,
                ConfigData: request.ConfigData
            )
    
            let commonElementsCoordinates = ElementsCalc.calculateElementsFactors(request: commonElementsRequest, seWrapper: seWrapper, ayanamshaOffset: ayanamshaOffset)
            allCoordinates.merge(commonElementsCoordinates) { (_, new) in new }
        }
        
        if let commonFormulaLongitudeFactors = factorsByType[.CommonFormulaLongitude], !commonFormulaLongitudeFactors.isEmpty {
            let fCalc = FormulaCalc()
            let commonFormulaLongitudeRequest = CalcRequest(
                JulianDay: request.JulianDay,
                FactorsToUse: commonFormulaLongitudeFactors,
                HouseSystem: request.HouseSystem,
                Latitude: request.Latitude,
                Longitude: request.Longitude,
                Height: request.Height,
                ConfigData: request.ConfigData
            )
            let commonFormulaLongitudeCoordinates = fCalc.calculateFormulaFactors(seWrapper: seWrapper, calcRequest: commonFormulaLongitudeRequest, ayanamshaOffset: ayanamshaOffset)
            allCoordinates.merge(commonFormulaLongitudeCoordinates) { (_, new) in new }
        }
        
        if let commonFormulaFullFactors = factorsByType[.CommonFormulaFull], !commonFormulaFullFactors.isEmpty {
            let fFullCalc = FormulaFullCalc()
            let formulaFullCalcRequest = CalcRequest(
                JulianDay: request.JulianDay,
                FactorsToUse: commonFormulaFullFactors,
                HouseSystem: request.HouseSystem,
                Latitude: request.Latitude,
                Longitude: request.Longitude,
                Height: request.Height,
                ConfigData: request.ConfigData
            )
            let commonFormulaFullCoordinates = fFullCalc.CalculateFormulaFullFactors(seWrapper: seWrapper, calcRequest: formulaFullCalcRequest, obliquity: obliquity, ayanamshaOffset: ayanamshaOffset)
            allCoordinates.merge(commonFormulaFullCoordinates) { (_, new) in new }
        }
        
        if let lotsFactors = factorsByType[.Lots], !lotsFactors.isEmpty {
            // Extract required longitudes for lots calculation
            let ascendantLongitude = housePositions.ascendant.longitude
            let sunLongitude = allCoordinates[.sun]?.ecliptical.first?.mainPos ?? -1.0
            let moonLongitude = allCoordinates[.moon]?.ecliptical.first?.mainPos ?? -1.0
            let isDayChart = (allCoordinates[.sun]?.horizontal.first?.altitude ?? 0.0) >= 0.0
            if (sunLongitude > 0.0 && moonLongitude > 0.0) {
                
                let lotsCalc = LotsCalc()
                let lotsRequest = CalcRequest(
                    JulianDay: request.JulianDay,
                    FactorsToUse: lotsFactors,
                    HouseSystem: request.HouseSystem,
                    Latitude: request.Latitude,
                    Longitude: request.Longitude,
                    Height: request.Height,
                    ConfigData: request.ConfigData
                )
                let lotsCoordinates = lotsCalc.calculateLotsFactors(
                    seWrapper: seWrapper,
                    calcRequest: lotsRequest,
                    obliquity: obliquity,
                    ascendantLongitude: ascendantLongitude,
                    sunLongitude: sunLongitude,
                    moonLongitude: moonLongitude,
                    isDayChart: isDayChart,
                    ayanamshaOffset: ayanamshaOffset
                )
                allCoordinates.merge(lotsCoordinates) { (_, new) in new }
            }
        }
        
        if let zodiacFixedFactors = factorsByType[.ZodiacFixed], !zodiacFixedFactors.isEmpty {
            let zodiacFixedCalc = ZodiacFixedCalc()
            let zodiacFixedCoordinates = zodiacFixedCalc.zodiacFixedFactors(calcRequest: request, obliquity: obliquity, seWrapper: seWrapper)
            allCoordinates.merge(zodiacFixedCoordinates) { (_, new) in new }
        }
        
        if let apsidesFactors = factorsByType[.Apsides], !apsidesFactors.isEmpty {
            let apsidesCalc = ApsidesCalc()
            let apsidesRequest = CalcRequest(
                JulianDay: request.JulianDay,
                FactorsToUse: apsidesFactors,
                HouseSystem: request.HouseSystem,
                Latitude: request.Latitude,
                Longitude: request.Longitude,
                Height: request.Height,
                ConfigData: request.ConfigData
            )
            let apsidesCoordinates = apsidesCalc.calculateApsidesFactors(calcRequest: apsidesRequest, obliquity: obliquity, ayanamshaOffset: ayanamshaOffset, flags: seFlagsEcliptical, seWrapper: seWrapper)
            allCoordinates.merge(apsidesCoordinates) { (_, new) in new }
        }
        
        if (request.ConfigData.projectionType == ProjectionTypes.obliqueLongitude) {
            // exchange all longitudes with their oblique longitude equivalents
            
            let armc = housePositions.midheaven.rightAscension
            
            // Build array of NamedEclipticCoordinates from allCoordinates
            var factorCoordinates: [NamedEclipticCoordinates] = []
            for (factor, position) in allCoordinates {
                if let ecliptical = position.ecliptical.first {
                    factorCoordinates.append(NamedEclipticCoordinates(
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
                factorCoordinates: factorCoordinates,
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

