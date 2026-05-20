// ApsidesCalc.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Apsides Calculator

/// Calculate apsides (perihelion/aphelion for planets, perigee/apogee for Moon) using Swiss Ephemeris
public struct ApsidesCalc {
    
    /// Calculate apsides factors
    /// - Parameters:
    ///   - calcRequest: The CalcRequest containing calculation parameters
    ///   - flags ; SE flags for ecliptical calculations
    ///   - seWrapper: SEWrapper instance for calculations
    /// - Returns: A dictionary of factor positions
    public func calculateApsidesFactors(calcRequest: CalcRequest, obliquity: Double, ayanamshaOffset: Double, flags: Int, seWrapper: SEWrapper) -> [Factors: FullFactorPosition] {
        
        Logger.log.debug( "Calculating apsides, start of method" )

        var coordinates: [Factors: FullFactorPosition] = [:]

        if calcRequest.calculationConfig.observerPosition == .helioCentric {
            Logger.log.warning("ApsidesCalc: heliocentric position requested for apsides factors — not applicable, skipping")
            return coordinates
        }
        let julianDay = calcRequest.JulianDay
        let method =  1  // SE_NODBIT_MEAN for mean nodes/apsides, currently only Black Sun and Diamond are supported
                         // so there is no need for an oscillating method
        
        let fullPositionCalc = FullPositionFromLongitude()
        
        Logger.log.debug( "Calculating apsides, start of loop" )
        
        for factor in calcRequest.FactorsToUse {
            
            Logger.log.debug( "starting loop for \(factor)" ) 
            
            var longitude = 0.0
            var latitude = 0.0
            let planetId = Factors.sun.seId
            Logger.log.debug("Starting calculation of apsides for \(factor)"   )
            guard let apsidesResult = seWrapper.calculateApsides(
                julianDay: julianDay,
                planet: planetId,
                flags: flags,
                method: method
            ) else {
                Logger.log.error("Failed to calculate apsides for planet \(planetId)")
                return coordinates
            }
            Logger.log.debug("Completed calculation aspides for planet \(planetId) ")
            
            
            
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
                longitude: longitude - ayanamshaOffset,
                julianDay: julianDay,
                observerLatitude: calcRequest.Latitude,
                observerLongitude: calcRequest.Longitude,
                obliquity: obliquity,
                eclipticalLatitude: latitude,
                seWrapper: seWrapper
            )
            
            coordinates[factor] = fullPosition
        }
        
        return coordinates
    }
}
