//
//  ZodiacFixedCalc.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 06/01/2026.
//
public struct ZodiacFixedCalc {
    
    
    
    /// Calculate the cordinates for a predefined point on the ecliptic
    public func zodiacFixedFactors(seRequest: SERequest, obliquity: Double, seWrapper: SEWrapper) -> [Factors: FullFactorPosition] {
            
        var coordinates: [Factors: FullFactorPosition] = [:]
        let julianDay = seRequest.JulianDay
        let distance = 0.0          // distance is unknown or irrelevant
        let latitude = 0.0          // latitude is zero by definition
        let observerLat = seRequest.Latitude
        let observerLong = seRequest.Longitude
        
        for factor in seRequest.FactorsToUse {
            var longitude = 0.0
            switch factor {
            case .zeroAries:
                longitude = 0.0
            default:
                Logger.log.error ("Unsupported factor \(factor) in ZodiacFixedCalc")
                break;
            }
                    
            let fullPosition = createFullPositionFromLongitude(seWrapper: seWrapper,longitude: longitude, julianDay: julianDay, observerLatitude: observerLat, observerLongitude: observerLong, obliquity: obliquity)
            
            coordinates[factor] = fullPosition

        }
        return coordinates
    }
    
    
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
        observerLatitude: Double,
        observerLongitude : Double,
        obliquity: Double
    ) -> FullFactorPosition {
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
