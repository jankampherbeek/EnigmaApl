// MidpointMatch.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// The type of dial used when searching for midpoint matches.
enum MidpointDialType: Equatable {
    /// Full 360° dial — matches at 0° and 180° from the midpoint.
    case dial360
    /// 90° dial — matches at multiples of 45° (0°, 45°, 90°, 135°, 180°).
    case dial90
    /// 45° dial — matches at multiples of 22.5°.
    case dial45

    /// The modulus applied to reduce positions into this dial.
    var dialSize: Double {
        switch self {
        case .dial360: return 360.0
        case .dial90:  return 90.0
        case .dial45:  return 45.0
        }
    }
}

/// A factor that is conjunct (or in hard aspect in the chosen dial) with a midpoint.
struct MidpointMatch {
    /// First factor forming the midpoint pair.
    let factor1: Factors
    /// Second factor forming the midpoint pair.
    let factor2: Factors
    /// Ecliptic longitude of the midpoint (0–360°).
    let midpointPosition: Double
    /// The factor whose position matches the midpoint.
    let matchingFactor: Factors
    /// Ecliptic longitude of the matching factor (0–360°).
    let matchingPosition: Double
    /// Actual angular deviation from the exact match (0 = exact).
    let actualOrb: Double
    /// Maximum allowed orb for this match.
    let maxOrb: Double
}
