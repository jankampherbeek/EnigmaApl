// LotsCalc.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Lots Calculator

/// Calculate Hellenistic lots (e.g., Pars Fortuna)
/// For now only the calculation of Pars Fortunae (with and without sect).
/// Should augment this to include the standard Greek lots
public struct LotsCalc {

    
    /// Calculate lots factors
    /// - Parameters:
    ///   - calcRequest: The CalcRequest containing calculation parameters
    ///   - ascendantLongitude: The ecliptical longitude of the Ascendant in degrees
    ///   - sunLongitude: The ecliptical longitude of the Sun in degrees
    ///   - moonLongitude: The ecliptical longitude of the Moon in degrees
    /// - Returns: A dictionary of factor positions
    public func calculateLotsFactors(
        seWrapper: SEWrapper,
        calcRequest: CalcRequest,
        obliquity: Double,
        ascendantLongitude: Double,
        sunLongitude: Double,
        moonLongitude: Double,
        isDayChart: Bool,
        ayanamshaOffset: Double
    ) -> [Factors: FullFactorPosition] {
        var coordinates: [Factors: FullFactorPosition] = [:]
        let julianDay = calcRequest.JulianDay
        let configData = calcRequest.calculationConfig
        
        for factor in calcRequest.FactorsToUse {
            switch factor {
            case .parsfortuna:
                // Calculate Pars Fortuna
                // Formula: With sect (only if night chart): Ascendant + Moon - Sun
                //          Without sect (for day and night chart): Ascendant + Sun - Moon
                
                let parsFortunaLongitude: Double
                if configData.lotsType == .sect && !isDayChart {
                    // With sect, night chart: Ascendant + Sun - Moon
                    parsFortunaLongitude = RangeUtil.valueToRange(
                        ascendantLongitude + sunLongitude - moonLongitude,
                        lowerLimit: 0.0,
                        upperLimit: 360.0
                    )
                } else {
                    // Without sect, or any day chart: Ascendant + Moon - Sun
                    parsFortunaLongitude = RangeUtil.valueToRange(
                        ascendantLongitude + moonLongitude - sunLongitude,
                        lowerLimit: 0.0,
                        upperLimit: 360.0
                    )
                }
                
                // Create full position from calculated longitude
                let fullPosition = createFullPositionFromLongitude(
                    seWrapper: seWrapper,
                    longitude: parsFortunaLongitude,
                    julianDay: julianDay,
                    latitude: calcRequest.Latitude,
                    longitude: calcRequest.Longitude,
                    obliquity: obliquity,
                    ayanamshaOffset: ayanamshaOffset
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
        seWrapper: SEWrapper,
        longitude: Double,
        julianDay: Double,
        latitude: Double,
        longitude observerLongitude: Double,
        obliquity: Double,
        ayanamshaOffset: Double
    ) -> FullFactorPosition {
        // Ecliptical position (latitude is 0 for lots)
        let eclipticalPos = MainAstronomicalPosition(
            mainPos: RangeUtil.valueToRange(longitude - ayanamshaOffset, lowerLimit: 0.0, upperLimit: 360.0),
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
