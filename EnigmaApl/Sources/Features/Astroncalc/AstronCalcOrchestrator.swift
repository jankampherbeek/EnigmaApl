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
        
        // Group factors by calculation type
        let factorsByType = Dictionary(grouping: request.FactorsToUse) { $0.calculationType }
        
        // Calculate factors for each calculation type
        var allCoordinates: [Factors: FullFactorPosition] = [:]
        var obliquity: Double = 0.0
        
        // Handle CommonSe factors first (these need to calculate obliquity)
        if let commonSeFactors = factorsByType[.CommonSe], !commonSeFactors.isEmpty {
            // Create a temporary request with only CommonSe factors
            let commonSeRequest = SERequest(
                JulianDay: request.JulianDay,
                FactorsToUse: commonSeFactors,
                HouseSystem: request.HouseSystem,
                SEFlags: request.SEFlags,
                Latitude: request.Latitude,
                Longitude: request.Longitude
            )
            let (commonSeCoordinates, calculatedObliquity) = SECalculation.CalculateFactors(commonSeRequest)
            allCoordinates.merge(commonSeCoordinates) { (_, new) in new }
            obliquity = calculatedObliquity
        }
        
        if let commonElementsFactors = factorsByType[.CommonElements], !commonElementsFactors.isEmpty {
            let commonElementsCoordinates = ElementsCalc.calculateElementsFactors(
                request: request
            )
            allCoordinates.merge(commonElementsCoordinates) { (_, new) in new }
        }
        
        if let commonFormulaLongitudeFactors = factorsByType[.CommonFormulaLongitude], !commonFormulaLongitudeFactors.isEmpty {
            let fCalc = FormulaCalc()
            let commonFormulaLongitudeCoordinates = fCalc.calculateFormulaFactors(seRequest: request)
            allCoordinates.merge(commonFormulaLongitudeCoordinates) { (_, new) in new }
        }
        
        if let commonFormulaFullFactors = factorsByType[.CommonFormulaFull], !commonFormulaFullFactors.isEmpty {
            let commonFormulaFullCoordinates = calculateCommonFormulaFullFactors(
                factors: commonFormulaFullFactors,
                request: request
            )
            allCoordinates.merge(commonFormulaFullCoordinates) { (_, new) in new }
        }
        
        if let mundaneFactors = factorsByType[.Mundane], !mundaneFactors.isEmpty {
            let mundaneCoordinates = calculateMundaneFactors(
                factors: mundaneFactors,
                request: request
            )
            allCoordinates.merge(mundaneCoordinates) { (_, new) in new }
        }
        
        if let lotsFactors = factorsByType[.Lots], !lotsFactors.isEmpty {
            let lotsCoordinates = calculateLotsFactors(
                factors: lotsFactors,
                request: request
            )
            allCoordinates.merge(lotsCoordinates) { (_, new) in new }
        }
        
        if let zodiacFixedFactors = factorsByType[.ZodiacFixed], !zodiacFixedFactors.isEmpty {
            let zodiacFixedCoordinates = calculateZodiacFixedFactors(
                factors: zodiacFixedFactors,
                request: request
            )
            allCoordinates.merge(zodiacFixedCoordinates) { (_, new) in new }
        }
        
        if let apsidesFactors = factorsByType[.Apsides], !apsidesFactors.isEmpty {
            let apsidesCoordinates = calculateApsidesFactors(
                factors: apsidesFactors,
                request: request
            )
            allCoordinates.merge(apsidesCoordinates) { (_, new) in new }
        }
        
        if let unknownFactors = factorsByType[.Unknown], !unknownFactors.isEmpty {
            let unknownCoordinates = calculateUnknownFactors(
                factors: unknownFactors,
                request: request
            )
            allCoordinates.merge(unknownCoordinates) { (_, new) in new }
        }
        
        // Always calculate houses
        let housePositions = SECalculation.CalculateHouses(request, obliquity: obliquity)
        
        // Calculate sidereal time
        let siderealTime = seWrapper.siderealTime(julianDay: julianDay)
        
        return FullChart(
            Coordinates: allCoordinates,
            HousePositions: housePositions,
            SiderealTime: siderealTime,
            JulianDay: julianDay,
            Obliquity: obliquity
        )
    }
    
    // MARK: - Placeholder calculation methods
    

    
    /// Placeholder for CommonFormulaLongitude calculation
    private static func calculateCommonFormulaLongitudeFactors(
        factors: [Factors],
        request: SERequest
    ) -> [Factors: FullFactorPosition] {
        // TODO: Implement CommonFormulaLongitude calculation
        var coordinates: [Factors: FullFactorPosition] = [:]
        for factor in factors {
            // Placeholder: return zero positions
            let zeroPosition = FullFactorPosition(
                ecliptical: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                equatorial: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                horizontal: [HorizontalPosition(azimuth: 0.0, altitude: 0.0)]
            )
            coordinates[factor] = zeroPosition
        }
        return coordinates
    }
    
    /// Placeholder for CommonFormulaFull calculation
    private static func calculateCommonFormulaFullFactors(
        factors: [Factors],
        request: SERequest
    ) -> [Factors: FullFactorPosition] {
        // TODO: Implement CommonFormulaFull calculation
        var coordinates: [Factors: FullFactorPosition] = [:]
        for factor in factors {
            // Placeholder: return zero positions
            let zeroPosition = FullFactorPosition(
                ecliptical: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                equatorial: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                horizontal: [HorizontalPosition(azimuth: 0.0, altitude: 0.0)]
            )
            coordinates[factor] = zeroPosition
        }
        return coordinates
    }
    
    /// Placeholder for Mundane calculation
    private static func calculateMundaneFactors(
        factors: [Factors],
        request: SERequest
    ) -> [Factors: FullFactorPosition] {
        // TODO: Implement Mundane calculation
        var coordinates: [Factors: FullFactorPosition] = [:]
        for factor in factors {
            // Placeholder: return zero positions
            let zeroPosition = FullFactorPosition(
                ecliptical: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                equatorial: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                horizontal: [HorizontalPosition(azimuth: 0.0, altitude: 0.0)]
            )
            coordinates[factor] = zeroPosition
        }
        return coordinates
    }
    
    /// Placeholder for Lots calculation
    private static func calculateLotsFactors(
        factors: [Factors],
        request: SERequest
    ) -> [Factors: FullFactorPosition] {
        // TODO: Implement Lots calculation
        var coordinates: [Factors: FullFactorPosition] = [:]
        for factor in factors {
            // Placeholder: return zero positions
            let zeroPosition = FullFactorPosition(
                ecliptical: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                equatorial: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                horizontal: [HorizontalPosition(azimuth: 0.0, altitude: 0.0)]
            )
            coordinates[factor] = zeroPosition
        }
        return coordinates
    }
    
    /// Placeholder for ZodiacFixed calculation
    private static func calculateZodiacFixedFactors(
        factors: [Factors],
        request: SERequest
    ) -> [Factors: FullFactorPosition] {
        // TODO: Implement ZodiacFixed calculation
        var coordinates: [Factors: FullFactorPosition] = [:]
        for factor in factors {
            // Placeholder: return zero positions
            let zeroPosition = FullFactorPosition(
                ecliptical: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                equatorial: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                horizontal: [HorizontalPosition(azimuth: 0.0, altitude: 0.0)]
            )
            coordinates[factor] = zeroPosition
        }
        return coordinates
    }
    
    /// Placeholder for Apsides calculation
    private static func calculateApsidesFactors(
        factors: [Factors],
        request: SERequest
    ) -> [Factors: FullFactorPosition] {
        // TODO: Implement Apsides calculation
        var coordinates: [Factors: FullFactorPosition] = [:]
        for factor in factors {
            // Placeholder: return zero positions
            let zeroPosition = FullFactorPosition(
                ecliptical: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                equatorial: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                horizontal: [HorizontalPosition(azimuth: 0.0, altitude: 0.0)]
            )
            coordinates[factor] = zeroPosition
        }
        return coordinates
    }
    
    /// Placeholder for Unknown calculation
    private static func calculateUnknownFactors(
        factors: [Factors],
        request: SERequest
    ) -> [Factors: FullFactorPosition] {
        // TODO: Handle Unknown calculation type
        var coordinates: [Factors: FullFactorPosition] = [:]
        for factor in factors {
            // Placeholder: return zero positions
            let zeroPosition = FullFactorPosition(
                ecliptical: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                equatorial: [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)],
                horizontal: [HorizontalPosition(azimuth: 0.0, altitude: 0.0)]
            )
            coordinates[factor] = zeroPosition
        }
        return coordinates
    }
}

