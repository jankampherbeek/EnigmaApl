//
//  SEFlags.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 01/01/2025.
//

import Foundation

/// Calculates the flags for a calculation via the Swiss Ephemeris
public struct SEFlags {
    
    /// Define flags based on coordinate system, observer position, and zodiac type
    /// - Parameters:
    ///   - configData: Configuration data
    ///   - coordSystem: Coordinate system
    /// - Returns: The calculated flags for Swiss Ephemeris
    public static func defineFlags(calculationConfig: CalculationConfig, coordSystem: CoordinateSystems) -> Int {
        var flags = 2 + 256  // use SE + speed

        if coordSystem == .equatorial {
            flags += 2048  // use equatorial positions
        }
        if calculationConfig.observerPosition == .topoCentric {
            flags += (32 * 1024)  // use topocentric position (apply parallax)
        }
        if calculationConfig.observerPosition == .helioCentric {
            flags += 8  // use heliocentric positions
        }
        if calculationConfig.ayanamsha != .tropical && coordSystem == .ecliptical {
            flags += (64 * 1024)  // use sidereal zodiac
        }

        return flags
    }
}
