//
//  FullPositionFromLongitude.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 06/01/2026.
//

import Foundation

// MARK: - Full Position From Longitude Calculator

/// Utility struct for creating full factor positions from ecliptical longitude
public struct FullPositionFromLongitude {
    private let seWrapper: SEWrapper
    
    public init(seWrapper: SEWrapper = SEWrapper()) {
        self.seWrapper = seWrapper
    }
    
    /// Create full position from ecliptical longitude
    /// - Parameters:
    ///   - longitude: Ecliptical longitude in degrees
    ///   - julianDay: Julian day for UT
    ///   - observerLatitude: Observer latitude in degrees
    ///   - observerLongitude: Observer longitude in degrees (for horizontal coordinates)
    ///   - obliquity: Obliquity of the ecliptic in degrees
    ///   - eclipticalLatitude: Optional ecliptical latitude in degrees (defaults to 0.0)
    /// - Returns: FullFactorPosition with all coordinate systems
    public func createFullPositionFromLongitude(
        longitude: Double,
        julianDay: Double,
        observerLatitude: Double,
        observerLongitude: Double,
        obliquity: Double,
        eclipticalLatitude: Double = 0.0
    ) -> FullFactorPosition {
        let eclipticalPos = MainAstronomicalPosition(
            mainPos: longitude,
            deviation: eclipticalLatitude,
            distance: 0.0,
            mainPosSpeed: 0.0,
            deviationSpeed: 0.0,
            distanceSpeed: 0.0
        )
        
        // Convert to equatorial coordinates
        let (ra, decl) = seWrapper.eclipticToEquatorial(
            eclipticCoordinates: [longitude, eclipticalLatitude],
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
            observerLatitude: observerLatitude,
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

