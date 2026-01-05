//
//  FormulaCalc.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 04/01/2026.
//

import Foundation

// MARK: - Constants

/// Astronomical constants
private enum AstronomicalConstants {
    /// Julian day for 1900/1/1 0:00:00 UT
    static let JD1900 = 2415020.5
    
    /// Tropical year in days (365.242190 days)
    static let TROPICAL_YEAR_IN_DAYS = 365.242190
}

// MARK: - Formula Calculator

/// Calculate geocentric ecliptical position for celestial points that are not supported by the SE,
/// using specific formulas.
public struct FormulaCalc {
    private let seWrapper: SEWrapper
    
    public init(seWrapper: SEWrapper = SEWrapper()) {
        self.seWrapper = seWrapper
    }
    
    /// Calculate the position for a factor using a formula
    /// Latitude is unknown so we use zero for latitude, ra, declination, azimuth and altitude
    public func calculateFormulaFactors(seRequest: SERequest) -> [Factors: FullFactorPosition] {
                
        var coordinates: [Factors: FullFactorPosition] = [:]
        let julianDay = seRequest.JulianDay
        let distance = 0.0          // distance is unknown or irrelevant
        let latitude = 0.0          // latitude is unknown
        let height = 0.0            // height of the observer is unknnown
        
        let zeroEqCoordinate = MainAstronomicalPosition(mainPos: 0.0, deviation: 0.0, distance: 0.0)
        let zeroHorizontalCoordinate = HorizontalPosition(azimuth: 0.0, altitude: 0.0)
        
        for factor in seRequest.FactorsToUse {
            var longitude = 0.0
            switch factor {
            case .persephoneCarteret:
                longitude = calcCarteretHypPlanet(julianDay: julianDay, startPoint: 212.0, yearlySpeed: 1.0)
            case .vulcanusCarteret:
                longitude = calcCarteretHypPlanet(julianDay: julianDay, startPoint: 15.7, yearlySpeed: 0.55)
            case .apogeeCorrected:
                let apogeeCalc = ApogeeDuvalCalc(seWrapper: seWrapper)
                longitude = apogeeCalc.calcApogeeDuval(julianDay: julianDay)
            default :
                Logger.log.error ("Unsupported factor \(factor) in FormulaCalc")
                break;
            }
                    
            let eclipticalPos = MainAstronomicalPosition(
                mainPos: longitude,
                deviation: latitude,
                distance: distance
            )
            let fullPosition = FullFactorPosition(
                ecliptical: [eclipticalPos],
                equatorial: [zeroEqCoordinate],
                horizontal: [zeroHorizontalCoordinate]
            )
                
            coordinates[factor] = fullPosition

        }
        return coordinates
    }
    

    
    
    
    // MARK: - Private Calculation Methods
    
    /// Calculate Carteret hypothetical planet position
    /// - Parameters:
    ///   - julianDay: Julian day for UT
    ///   - startPoint: Starting point in degrees
    ///   - yearlySpeed: Yearly speed in degrees per year
    /// - Returns: Longitude in degrees (0-360)
    private func calcCarteretHypPlanet(julianDay: Double, startPoint: Double, yearlySpeed: Double) -> Double {
        let positions = startPoint + ((julianDay - AstronomicalConstants.JD1900) * (yearlySpeed / AstronomicalConstants.TROPICAL_YEAR_IN_DAYS))
        return RangeUtil.valueToRange(positions, lowerLimit: 0.0, upperLimit: 360.0)
    }
    
}
