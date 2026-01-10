//
//  ApsidesCalc.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 07/01/2026.
//

import Foundation

// MARK: - Apsides Calculator

/// Calculate apsides (perihelion/aphelion for planets, perigee/apogee for Moon) using Swiss Ephemeris
public struct ApsidesCalc {
    private let seWrapper: SEWrapper
    
    public init(seWrapper: SEWrapper = SEWrapper()) {
        self.seWrapper = seWrapper
    }
    
    /// Calculate apsides factors
    /// - Parameter seRequest: The SERequest containing calculation parameters
    /// - Returns: A dictionary of factor positions
    public func calculateApsidesFactors(seRequest: SERequest) -> [Factors: FullFactorPosition] {
        var coordinates: [Factors: FullFactorPosition] = [:]
        let julianDay = seRequest.JulianDay
        let flags = seRequest.SEFlags
        let method =  1  // SE_NODBIT_MEAN for mean nodes/apsides, currently only Black Sun and Diamond are supported
                         // so there is no need for an oscillating method
        
        // Calculate obliquity for coordinate conversion
        let obliquityPosition = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            planet: -1,
            flags: 2  // Use SE, no need for speed
        )
        let obliquity = obliquityPosition?.mainPos ?? 0.0
        
            
        let fullPositionCalc = FullPositionFromLongitude(seWrapper: seWrapper)
        
        for factor in seRequest.FactorsToUse {
            var longitude = 0.0
            var latitude = 0.0
            let planetId = Factors.sun.seId
            guard let apsidesResult = seWrapper.calculateApsides(
                julianDay: julianDay,
                planet: planetId,
                flags: flags,
                method: method
            ) else {
                Logger.log.error("Failed to calculate apsides for planet \(planetId)")
                return coordinates
            }
            
            
            
            switch factor {
            case .blackSun:
                // Black Sun = Earth's aphelion (farthest from Sun)
                longitude = apsidesResult.aphelion[0]
                latitude = apsidesResult.aphelion[1]
            case .diamond:
                // Diamond = Earth's perihelion (closest to Sun)
                longitude = apsidesResult.perihelion[0]
                latitude = apsidesResult.perihelion[1]
            default:
                Logger.log.error("Unsupported factor \(factor) in ApsidesCalc")
                continue
            }
            
            let fullPosition = fullPositionCalc.createFullPositionFromLongitude(
                longitude: longitude,
                julianDay: julianDay,
                observerLatitude: seRequest.Latitude,
                observerLongitude: seRequest.Longitude,
                obliquity: obliquity,
                eclipticalLatitude: latitude
            )
            
            coordinates[factor] = fullPosition
        }
        
        return coordinates
    }
}
