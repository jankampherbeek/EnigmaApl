//
//  ApogeeDuvalCalc.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 05/01/2026.
//

import Foundation

// MARK: - Apogee Duval Calculator

/// Calculate corrected apogee using Duval's formula
public struct ApogeeDuvalCalc {
    private let seWrapper: SEWrapper
    
    public init(seWrapper: SEWrapper = SEWrapper()) {
        self.seWrapper = seWrapper
    }
    
    /// Calculate corrected apogee using Duval's formula
    /// - Parameter julianDay: Julian day for UT
    /// - Returns: Longitude in degrees (0-360)
    public func calcApogeeDuval(julianDay: Double) -> Double {
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

