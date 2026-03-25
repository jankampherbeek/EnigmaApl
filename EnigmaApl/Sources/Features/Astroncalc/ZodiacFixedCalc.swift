// ZodiacFixedCalc.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
public struct ZodiacFixedCalc {
    
    
    
    /// Calculate the cordinates for a predefined point on the ecliptic
    public func zodiacFixedFactors(calcRequest: CalcRequest, obliquity: Double, seWrapper: SEWrapper) -> [Factors: FullFactorPosition] {
            
        var coordinates: [Factors: FullFactorPosition] = [:]
        let julianDay = calcRequest.JulianDay
        let distance = 0.0          // distance is unknown or irrelevant
        let latitude = 0.0          // latitude is zero by definition
        let observerLat = calcRequest.Latitude
        let observerLong = calcRequest.Longitude
        
        for factor in calcRequest.FactorsToUse {
            var longitude = 0.0
            switch factor {
            case .zeroAries:
                longitude = 0.0
            default:
                Logger.log.error ("Unsupported factor \(factor) in ZodiacFixedCalc")
                break;
            }
                    
            let fullPositionCalc = FullPositionFromLongitude()
            let fullPosition = fullPositionCalc.createFullPositionFromLongitude(
                longitude: longitude,
                julianDay: julianDay,
                observerLatitude: observerLat,
                observerLongitude: observerLong,
                obliquity: obliquity,
                seWrapper: seWrapper
            )
            
            coordinates[factor] = fullPosition

        }
        return coordinates
    }
}
