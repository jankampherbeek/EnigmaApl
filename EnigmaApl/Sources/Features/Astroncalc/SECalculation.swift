//
//  SECalculation.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 22/12/2025.
//

import Foundation

public struct SECalculation {
    
    /// Calculates the positions for all factors in the request
    /// - Parameter request: The SERequest containing calculation parameters
    /// - Returns: A tuple containing a dictionary of factor positions and the obliquity value
    public static func CalculateFactors(_ request: SERequest) -> ([Factors: FullFactorPosition], Double) {
        let seWrapper = SEWrapper()
        let julianDay = request.JulianDay
        
        // Flags: 258 = SEFLG_SWIEPH (2) + SEFLG_SPEED (256)
        let eclipticalFlags = 258
        let equatorialFlags = 258 + 2048  // Add equatorial flag (2048)
        
        // Calculate positions for each factor
        var coordinates: [Factors: FullFactorPosition] = [:]
        
        for factor in request.FactorsToUse {
            let factorId = factor.seId
            
            // Calculate ecliptical position
            let eclipticalPos = seWrapper.calculateFactorPosition(
                julianDay: julianDay,
                planet: factorId,
                flags: eclipticalFlags
            )
            
            // Calculate equatorial position
            let equatorialPos = seWrapper.calculateFactorPosition(
                julianDay: julianDay,
                planet: factorId,
                flags: equatorialFlags
            )
            
            // Create arrays for FullPosition
            // Each FullPosition contains arrays, so we wrap single positions in arrays
            let eclipticalArray: [MainAstronomicalPosition]
            if let pos = eclipticalPos {
                eclipticalArray = [pos]
            } else {
                // If calculation failed, use zero values
                eclipticalArray = [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)]
            }
            
            let equatorialArray: [MainAstronomicalPosition]
            var horizontalArray: [HorizontalPosition]
            
            if let pos = equatorialPos {
                equatorialArray = [pos]
                
                // Calculate horizontal position using equatorial coordinates
                let (azimuth, altitude) = seWrapper.azimuthAndAltitude(
                    julianDay: julianDay,
                    rightAscension: pos.mainPos,
                    declination: pos.deviation,
                    observerLatitude: request.Latitude,
                    observerLongitude: request.Longitude,
                    height: 0.0  // Using sea level
                )
                horizontalArray = [HorizontalPosition(azimuth: azimuth, altitude: altitude)]
            } else {
                // If calculation failed, use zero values
                equatorialArray = [MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)]
                horizontalArray = [HorizontalPosition(azimuth: 0.0, altitude: 0.0)]
            }
            
            let fullPosition = FullFactorPosition(
                ecliptical: eclipticalArray,
                equatorial: equatorialArray,
                horizontal: horizontalArray
            )
            
            coordinates[factor] = fullPosition
        }
        
        // Calculate obliquity using id -1
        let obliquityPosition = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            planet: -1,
            flags: eclipticalFlags
        )
        let obliquity = obliquityPosition?.mainPos ?? 0.0
        
        return (coordinates, obliquity)
    }
    
    /// Calculates house positions (cusps, ascendant, MC, vertex, and eastpoint)
    /// - Parameters:
    ///   - request: The SERequest containing calculation parameters
    ///   - obliquity: The obliquity value needed for coordinate conversions
    /// - Returns: A HousePositions struct with all calculated house data
    public static func CalculateHouses(_ request: SERequest, obliquity: Double) -> HousePositions {
        let seWrapper = SEWrapper()
        let julianDay = request.JulianDay
        
        // Calculate ecliptical positions of houses
        var cusps: [Int: Double] = [:]
        var mc = 0.0
        var ascendant = 0.0
        var vertex = 0.0
        var eastpoint = 0.0
        
        do {
            let (houseCusps, ascmc) = try seWrapper.calculateHouses(
                julianDay: julianDay,
                latitude: request.Latitude,
                longitude: request.Longitude,
                houseSystem: request.HouseSystem
            )
            
            // Determine number of houses (cusps array includes index 0, so actual houses start at index 1)
            let gauquelinIndex = 71
            let nrOfHouses = request.HouseSystem == gauquelinIndex ? 36 : 12
            
            // Convert cusps array to dictionary with cusp numbers as keys (indices 1-12 or 1-36)
            for index in 1...nrOfHouses {
                if index < houseCusps.count {
                    cusps[index] = houseCusps[index]
                }
            }
            
            // Extract ascendant, midheaven, vertex, and eastpoint from ascmc array
            if ascmc.count > 0 { ascendant = ascmc[0] }
            if ascmc.count > 1 { mc = ascmc[1] }
            if ascmc.count > 3 { vertex = ascmc[3] }
            if ascmc.count > 4 { eastpoint = ascmc[4] }
        } catch {
            // If house calculation fails, use default values (already set above)
            Logger.log.warning("House calculation failed: \(error)")
        }
        
        // Convert longitude of houses to full housepositions
        func createFullCuspPosition(eclipticLongitude: Double) -> FullCuspPosition {
            // Latitude for houses is always zero
            let eclipticCoords = [eclipticLongitude, 0.0]
            let (ra, dec) = seWrapper.eclipticToEquatorial(eclipticCoordinates: eclipticCoords, obliquity: obliquity)
            
            // Calculate horizontal position using equatorial coordinates
            let (azimuth, altitude) = seWrapper.azimuthAndAltitude(
                julianDay: julianDay,
                rightAscension: ra,
                declination: dec,
                observerLatitude: request.Latitude,
                observerLongitude: request.Longitude,
                height: 0.0  // Using sea level for house positions
            )
            
            return FullCuspPosition(
                longitude: eclipticLongitude,
                rightAscension: ra,
                declination: dec,
                horizontal: HorizontalPosition(azimuth: azimuth, altitude: altitude)
            )
        }
        
        // Create FullCuspPosition for all cusps
        var fullCusps: [FullCuspPosition] = []
        let sortedCuspIndices = cusps.keys.sorted()
        for index in sortedCuspIndices {
            if let longitude = cusps[index] {
                fullCusps.append(createFullCuspPosition(eclipticLongitude: longitude))
            }
        }
        
        // Create FullCuspPosition for ascendant, midheaven, vertex, and eastpoint
        let fullAscendant = createFullCuspPosition(eclipticLongitude: ascendant)
        let fullMidheaven = createFullCuspPosition(eclipticLongitude: mc)
        let fullVertex = createFullCuspPosition(eclipticLongitude: vertex)
        let fullEastpoint = createFullCuspPosition(eclipticLongitude: eastpoint)
        
        // Create HousePositions struct
        return HousePositions(
            cusps: fullCusps,
            ascendant: fullAscendant,
            midheaven: fullMidheaven,
            eastpoint: fullEastpoint,
            vertex: fullVertex
        )
    }
    
}

