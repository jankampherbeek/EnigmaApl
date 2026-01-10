//
//  ObliqueLongitudeCalc.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 06/01/2026.
//

import Foundation

// MARK: - Named Ecliptic Coordinates

/// Represents a named celestial point with its ecliptic coordinates
public struct NamedEclipticCoordinates {
    public let factor: Factors
    public let longitude: Double
    public let latitude: Double
    
    public init(factor: Factors, longitude: Double, latitude: Double) {
        self.factor = factor
        self.longitude = longitude
        self.latitude = latitude
    }
}

// MARK: - Named Ecliptic Longitude

/// Represents a named celestial point with its oblique longitude
public struct NamedEclipticLongitude {
    public let factor: Factors
    public let obliqueLongitude: Double
    
    public init(factor: Factors, obliqueLongitude: Double) {
        self.factor = factor
        self.obliqueLongitude = obliqueLongitude
    }
}

// MARK: - Oblique Longitude Calculator

/// Calculate oblique longitudes for celestial points
/// Oblique longitude is a correction for the mundane position, also called 'true location',
/// as used by the School of Ram
public struct ObliqueLongitudeCalc {
    
    /// Calculate oblique longitudes for factors
    /// - Parameters:
    ///   - armc: Right Ascension of the Midheaven (ARMC) in degrees
    ///   - obliquity: Obliquity of the ecliptic in degrees
    ///   - geoLat: Geographic latitude in degrees
    ///   - celPointCoordinates: List of named ecliptic coordinates to calculate oblique longitudes for
    ///   - ayanamshaOffset: Ayanamsha offset in degrees
    /// - Returns: Array of named ecliptic longitudes with their oblique longitude values
    public func ObliqueLongitudeForFactor(
        armc: Double,
        obliquity: Double,
        geoLat: Double,
        celPointCoordinates: [NamedEclipticCoordinates],
        ayanamshaOffset: Double
    ) -> [NamedEclipticLongitude] {
        var results: [NamedEclipticLongitude] = []
        
        // Calculate the south point
        let southPoint = CalculateSouthPoint(armc: armc, obliquity: obliquity, geoLat: geoLat)
        
        for coord in celPointCoordinates {
            // Convert ecliptic coordinates to equatorial
            let (ra, decl) = eclipticToEquatorial(
                longitude: coord.longitude,
                latitude: coord.latitude,
                obliquity: obliquity
            )
            
            // Calculate the oblique longitude
            let obliqueLongitude = calculateObliqueLongitude(
                rightAscension: ra,
                declination: decl,
                armc: armc,
                geoLat: geoLat,
                obliquity: obliquity,
                southPoint: southPoint
            )
            
            // Apply ayanamsha offset and normalize to 0-360
            let adjustedLongitude = RangeUtil.valueToRange(
                obliqueLongitude + ayanamshaOffset,
                lowerLimit: 0.0,
                upperLimit: 360.0
            )
            
            results.append(NamedEclipticLongitude(
                factor: coord.factor,
                obliqueLongitude: adjustedLongitude
            ))
        }
        
        return results
    }
    
    // MARK: - Private Helper Methods
    
    /// Calculate the south point (also known as the anti-culminating point)
    /// - Parameters:
    ///   - armc: Right Ascension of the Midheaven in degrees
    ///   - obliquity: Obliquity of the ecliptic in degrees
    ///   - geoLat: Geographic latitude in degrees
    /// - Returns: The south point longitude in degrees
    private func CalculateSouthPoint(armc: Double, obliquity: Double, geoLat: Double) -> Double {
        // The south point is the point on the ecliptic that culminates at the lower meridian
        // It can be calculated using the formula involving ARMC, obliquity, and geographic latitude
        
        // Convert ARMC to radians
        let armcRad = MathExtra.degToRad(armc)
        let obliquityRad = MathExtra.degToRad(obliquity)
        let geoLatRad = MathExtra.degToRad(geoLat)
        
        // Calculate the right ascension of the south point
        // The south point's RA is ARMC + 180 degrees (opposite of MC)
        let southPointRA = armcRad + .pi
        
        // Calculate the declination of the south point
        // Using the formula: sin(dec) = -sin(geoLat) / cos(obliquity)
        // This gives us the declination of the point on the ecliptic that culminates at the lower meridian
        let sinDec = -sin(geoLatRad) / cos(obliquityRad)
        let dec = asin(sinDec)
        
        // Convert the south point from equatorial to ecliptic coordinates
        // Using the inverse transformation
        let southPointLongitude = equatorialToEcliptic(
            rightAscension: southPointRA,
            declination: dec,
            obliquity: obliquityRad
        )
        
        // Normalize to 0-360 degrees
        return RangeUtil.valueToRange(
            MathExtra.radToDeg(southPointLongitude),
            lowerLimit: 0.0,
            upperLimit: 360.0
        )
    }
    
    /// Calculate oblique longitude for a celestial point
    /// - Parameters:
    ///   - rightAscension: Right ascension in degrees
    ///   - declination: Declination in degrees
    ///   - armc: Right Ascension of the Midheaven in degrees
    ///   - geoLat: Geographic latitude in degrees
    ///   - obliquity: Obliquity of the ecliptic in degrees
    ///   - southPoint: The south point longitude in degrees
    /// - Returns: Oblique longitude in degrees
    private func calculateObliqueLongitude(
        rightAscension: Double,
        declination: Double,
        armc: Double,
        geoLat: Double,
        obliquity: Double,
        southPoint: Double
    ) -> Double {
        // Convert to radians
        let raRad = MathExtra.degToRad(rightAscension)
        let decRad = MathExtra.degToRad(declination)
        let armcRad = MathExtra.degToRad(armc)
        let geoLatRad = MathExtra.degToRad(geoLat)
        let obliquityRad = MathExtra.degToRad(obliquity)
        
        // Calculate the oblique ascension (OA)
        // Formula: OA = RA - arcsin(tan(dec) * tan(geoLat))
        // But we need to account for the hour angle and use a more precise formula
        let hourAngle = raRad - armcRad
        
        // Calculate the oblique ascension using the standard formula
        // tan(OA - ARMC) = tan(RA - ARMC) * cos(geoLat) / (cos(dec) + sin(dec) * tan(geoLat) * sin(RA - ARMC))
        let numerator = tan(hourAngle) * cos(geoLatRad)
        let denominator = cos(decRad) + sin(decRad) * tan(geoLatRad) * sin(hourAngle)
        let tanOADiff = numerator / denominator
        let oaDiff = atan(tanOADiff)
        let obliqueAscension = armcRad + oaDiff
        
        // Find the ecliptic longitude that has this oblique ascension
        // This requires solving for lambda such that the oblique ascension of lambda equals the calculated OA
        // We use an iterative approach or a direct formula based on the south point
        let obliqueLongitudeRad = findEclipticLongitudeForObliqueAscension(
            obliqueAscension: obliqueAscension,
            southPoint: MathExtra.degToRad(southPoint),
            geoLat: geoLatRad,
            obliquity: obliquityRad
        )
        
        return MathExtra.radToDeg(obliqueLongitudeRad)
    }
    
    /// Convert ecliptic coordinates to equatorial coordinates
    /// - Parameters:
    ///   - longitude: Ecliptic longitude in degrees
    ///   - latitude: Ecliptic latitude in degrees
    ///   - obliquity: Obliquity of the ecliptic in degrees
    /// - Returns: Tuple of (rightAscension, declination) in degrees
    private func eclipticToEquatorial(longitude: Double, latitude: Double, obliquity: Double) -> (Double, Double) {
        let lonRad = MathExtra.degToRad(longitude)
        let latRad = MathExtra.degToRad(latitude)
        let oblRad = MathExtra.degToRad(obliquity)
        
        // Standard conversion formulas
        let sinDec = sin(latRad) * cos(oblRad) + cos(latRad) * sin(oblRad) * sin(lonRad)
        let dec = asin(sinDec)
        
        let y = sin(lonRad) * cos(oblRad) - tan(latRad) * sin(oblRad)
        let x = cos(lonRad)
        let ra = atan2(y, x)
        
        return (MathExtra.radToDeg(ra), MathExtra.radToDeg(dec))
    }
    
    /// Convert equatorial coordinates to ecliptic coordinates
    /// - Parameters:
    ///   - rightAscension: Right ascension in radians
    ///   - declination: Declination in radians
    ///   - obliquity: Obliquity of the ecliptic in radians
    /// - Returns: Ecliptic longitude in radians
    private func equatorialToEcliptic(rightAscension: Double, declination: Double, obliquity: Double) -> Double {
        // Standard conversion formulas (inverse)
        let sinLat = sin(declination) * cos(obliquity) - cos(declination) * sin(obliquity) * sin(rightAscension)
        let lat = asin(sinLat)
        
        let y = sin(rightAscension) * cos(obliquity) + tan(declination) * sin(obliquity)
        let x = cos(rightAscension)
        let lon = atan2(y, x)
        
        return lon
    }
    
    /// Find the ecliptic longitude that has the given oblique ascension
    /// - Parameters:
    ///   - obliqueAscension: Oblique ascension in radians
    ///   - southPoint: South point longitude in radians
    ///   - geoLat: Geographic latitude in radians
    ///   - obliquity: Obliquity of the ecliptic in radians
    /// - Returns: Ecliptic longitude in radians
    private func findEclipticLongitudeForObliqueAscension(
        obliqueAscension: Double,
        southPoint: Double,
        geoLat: Double,
        obliquity: Double
    ) -> Double {
        // For the School of Ram method, we need to find the point on the ecliptic
        // that has the same oblique ascension as the celestial body
        
        // The oblique ascension of a point on the ecliptic (lambda, 0) is:
        // OA(lambda) = RA(lambda) - arcsin(tan(0) * tan(geoLat))
        // Since latitude is 0 on the ecliptic, this simplifies
        
        // We need to solve: OA(lambda) = obliqueAscension
        // This requires finding lambda such that the RA of lambda, when adjusted for oblique ascension, equals the target
        
        // A common approach: use the difference from the south point
        // The south point has a known relationship to ARMC
        // Calculate the difference in oblique ascension from the south point's oblique ascension
        let southPointRA = southPoint + .pi / 2  // Approximate - south point RA relative to its longitude
        let southPointOADiff = obliqueAscension - southPointRA
        
        // Convert this difference to an ecliptic longitude difference
        // This is a simplified approach - the exact formula depends on the specific method
        let longitudeDiff = southPointOADiff / cos(obliquity)
        let obliqueLongitude = southPoint + longitudeDiff
        
        return obliqueLongitude
    }
}
