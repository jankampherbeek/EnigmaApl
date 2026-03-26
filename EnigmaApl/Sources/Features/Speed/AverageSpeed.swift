// AverageSpeed.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Average daily speeds (in decimal degrees) for celestial factors that support slow/stationary detection.
/// Returns nil for factors without a known average speed (only Direct/Retrograde applies to those).
struct AverageSpeed {

    /// Returns the average daily speed for a given factor, or nil if not applicable.
    static func averageFor(_ factor: Factors) -> Double? {
        switch factor {
        case .sun:      return 0.985555
        case .moon:     return 13.17666
        case .mercury:  return 1.3833
        case .venus:    return 1.2
        case .mars:     return 0.5242
        case .jupiter:  return 0.0831
        case .saturn:   return 0.0336
        case .uranus:   return 0.026666
        case .neptune:  return 0.006668
        case .pluto:    return 0.0041666
        default:        return nil
        }
    }
}
