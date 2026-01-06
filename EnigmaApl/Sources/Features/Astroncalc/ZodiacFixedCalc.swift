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
                    
            let fullPositionCalc = FullPositionFromLongitude(seWrapper: seWrapper)
            let fullPosition = fullPositionCalc.createFullPositionFromLongitude(
                longitude: longitude,
                julianDay: julianDay,
                observerLatitude: observerLat,
                observerLongitude: observerLong,
                obliquity: obliquity
            )
            
            coordinates[factor] = fullPosition

        }
        return coordinates
    }
}
