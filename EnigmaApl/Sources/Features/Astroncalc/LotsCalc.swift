//
//  LotsCalc.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 05/01/2026.
//

import Foundation

// MARK: - Lots Calculator

/// Calculate Hellenistic lots (e.g., Pars Fortuna)
/// For now only the calculation of Pars Fortunae (with and without sect).
/// Should augment this to include the standard Greek lots
public struct LotsCalc {
    private let seWrapper: SEWrapper
    
    public init(seWrapper: SEWrapper = SEWrapper()) {
        self.seWrapper = seWrapper
    }
    
    /// Calculate lots factors
    /// - Parameters:
    ///   - seRequest: The SERequest containing calculation parameters
    ///   - ascendantLongitude: The ecliptical longitude of the Ascendant in degrees
    ///   - sunLongitude: The ecliptical longitude of the Sun in degrees
    ///   - moonLongitude: The ecliptical longitude of the Moon in degrees
    /// - Returns: A dictionary of factor positions
    public func calculateLotsFactors(
        seRequest: SERequest,
        obliquity: Double,
        ascendantLongitude: Double,
        sunLongitude: Double,
        moonLongitude: Double
    ) -> [Factors: FullFactorPosition] {
        var coordinates: [Factors: FullFactorPosition] = [:]
        let julianDay = seRequest.JulianDay
        let configData = seRequest.ConfigData
        
        for factor in seRequest.FactorsToUse {
            switch factor {
            case .parsfortuna:
                // Calculate Pars Fortuna
                // Formula: With sect (day chart): Ascendant + Moon - Sun
                //          Without sect (night chart): Ascendant + Sun - Moon
                
                let parsFortunaLongitude: Double
                if configData.lotsType == .sect {
                    // With sect: Ascendant + Moon - Sun
                    parsFortunaLongitude = RangeUtil.valueToRange(
                        ascendantLongitude + moonLongitude - sunLongitude,
                        lowerLimit: 0.0,
                        upperLimit: 360.0
                    )
                } else {
                    // Without sect: Ascendant + Sun - Moon
                    parsFortunaLongitude = RangeUtil.valueToRange(
                        ascendantLongitude + sunLongitude - moonLongitude,
                        lowerLimit: 0.0,
                        upperLimit: 360.0
                    )
                }
                
                // Create full position from calculated longitude
                let fullPosition = createFullPositionFromLongitude(
                    longitude: parsFortunaLongitude,
                    julianDay: julianDay,
                    latitude: seRequest.Latitude,
                    longitude: seRequest.Longitude,
                    obliquity: obliquity
                )
                
                coordinates[factor] = fullPosition
                
            default:
                Logger.log.error("Unsupported factor \(factor) in calculateLotsFactors")
                break
            }
        }
        
        return coordinates
    }
    
    // MARK: - Private Helper Methods
    
    /// Create full position from ecliptical longitude
    /// - Parameters:
    ///   - longitude: Ecliptical longitude in degrees
    ///   - julianDay: Julian day for UT
    ///   - latitude: Observer latitude
    ///   - longitude: Observer longitude (for horizontal coordinates)
    ///   - obliquity: Obliquity of the ecliptic
    /// - Returns: FullFactorPosition with all coordinate systems
    private func createFullPositionFromLongitude(
        longitude: Double,
        julianDay: Double,
        latitude: Double,
        longitude observerLongitude: Double,
        obliquity: Double
    ) -> FullFactorPosition {
        // Ecliptical position (latitude is 0 for lots)
        let eclipticalPos = MainAstronomicalPosition(
            mainPos: longitude,
            deviation: 0.0,
            distance: 0.0,
            mainPosSpeed: 0.0,
            deviationSpeed: 0.0,
            distanceSpeed: 0.0
        )
        
        // Convert to equatorial coordinates
        let (ra, decl) = seWrapper.eclipticToEquatorial(
            eclipticCoordinates: [longitude, 0.0],
            obliquity: obliquity
        )
        
        let equatorialPos = MainAstronomicalPosition(
            mainPos: ra,
            deviation: decl,
            distance: 0.0,
            mainPosSpeed: 0.0,
            deviationSpeed: 0.0,
            distanceSpeed: 0.0
        )
        
        // Calculate horizontal position using equatorial coordinates
        let (azimuth, altitude) = seWrapper.azimuthAndAltitude(
            julianDay: julianDay,
            rightAscension: ra,
            declination: decl,
            observerLatitude: latitude,
            observerLongitude: observerLongitude,
            height: 0.0
        )
        
        let horizontalPos = HorizontalPosition(azimuth: azimuth, altitude: altitude)
        
        return FullFactorPosition(
            ecliptical: [eclipticalPos],
            equatorial: [equatorialPos],
            horizontal: [horizontalPos]
        )
    }
}
