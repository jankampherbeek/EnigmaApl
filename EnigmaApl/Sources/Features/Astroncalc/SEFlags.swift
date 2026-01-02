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
    ///   - coordinateSystem: The coordinate system to use
    ///   - observerPosition: The observer position
    ///   - zodiacType: The zodiac type
    /// - Returns: The calculated flags for Swiss Ephemeris
    public static func defineFlags(
        coordinateSystem: CoordinateSystems,
        observerPosition: ObserverPositions,
        zodiacType: ZodiacTypes
    ) -> Int {
        var flags = 2 + 256  // use SE + speed
        
        if coordinateSystem == .equatorial {
            flags += 2048  // use equatorial positions
        }
        if observerPosition == .topoCentric {
            flags += (32 * 1024)  // use topocentric position (apply parallax)
        }
        if observerPosition == .helioCentric {
            flags += 8  // use heliocentric positions
        }
        if zodiacType == .sidereal && coordinateSystem == .ecliptical {
            flags += (64 * 1024)  // use sidereal zodiac
        }
        
        return flags
    }
}
