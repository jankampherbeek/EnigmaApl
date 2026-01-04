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
    /// - Parameters:
    ///   - factor: A point that should be calculated with a specific formula
    ///   - julianDay: Julian day for UT
    /// - Returns: Array with longitude, latitude and distance in that sequence
    public func calculate(_ factor: Factors, julianDay: Double) -> [Double] {
        switch factor {
        case .persephoneCarteret:
            let longitude = calcCarteretHypPlanet(julianDay: julianDay, startPoint: 212.0, yearlySpeed: 1.0)
            return [longitude, 0.0, 0.0]
            
        case .vulcanusCarteret:
            let longitude = calcCarteretHypPlanet(julianDay: julianDay, startPoint: 15.7, yearlySpeed: 0.55)
            return [longitude, 0.0, 0.0]
            
        case .apogeeCorrected:
            let longitude = calcApogeeDuval(julianDay: julianDay)
            return [longitude, 0.0, 0.0]
            
        default:
            return [0.0, 0.0, 0.0]
        }
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
    
    /// Calculate corrected apogee using Duval's formula
    /// - Parameter julianDay: Julian day for UT
    /// - Returns: Longitude in degrees (0-360)
    private func calcApogeeDuval(julianDay: Double) -> Double {
        let flagsEcl = 2 + 256  // use SE + speed
        
        // Get Sun longitude
        guard let sunPosition = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            planet: Factors.sun.seId,
            flags: flagsEcl
        ) else {
            return 0.0
        }
        let longSun = sunPosition.mainPos
        
        // Get mean apogee longitude
        guard let apogeeMeanPosition = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            planet: Factors.apogeeMean.seId,
            flags: flagsEcl
        ) else {
            return 0.0
        }
        let longApogeeMean = apogeeMeanPosition.mainPos
        
        // Calculate difference and normalize to -180 to 180
        let diff = RangeUtil.valueToRange(longSun - longApogeeMean, lowerLimit: -180.0, upperLimit: 180.0)
        
        // Calculate correction factors
        let factor1 = 12.37
        let sin2Diff = sin(MathExtra.degToRad(2 * diff))
        let factor2 = sin(MathExtra.degToRad(2 * (diff - 11.726 * sin2Diff)))
        let sin6Diff = sin(MathExtra.degToRad(6 * diff))
        let factor3 = (8.8 / 60.0) * sin6Diff
        let corrFactor = factor1 * factor2 + factor3
        
        // Return corrected apogee longitude normalized to 0-360
        return RangeUtil.valueToRange(longApogeeMean + corrFactor, lowerLimit: 0.0, upperLimit: 360.0)
    }
}
