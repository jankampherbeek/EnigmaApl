// WillnerMoonDeclinationCalc.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Derives the Moon's declination from its ecliptical position and the obliquity.
///
/// Formula (from Willner Incarnation_Routine.cs, line 87):
///   sin(MODECL) = cos(latMoon)·sin(lonMoon)·sin(obliquity) + sin(latMoon)·cos(obliquity)
///
/// This is the standard ecliptic-to-equatorial conversion for declination.
struct WillnerMoonDeclinationCalc {

    /// - Parameters:
    ///   - moonLonRad: Moon's ecliptical longitude in radians.
    ///   - moonLatRad: Moon's ecliptical latitude in radians.
    ///   - obliquitySin: Sine of the true obliquity.
    ///   - obliquityCos: Cosine of the true obliquity.
    /// - Returns: Moon's declination in radians.
    static func calculate(moonLonRad: Double,
                          moonLatRad: Double,
                          obliquitySin: Double,
                          obliquityCos: Double) -> Double {
        let sinDecl = cos(moonLatRad) * sin(moonLonRad) * obliquitySin
                    + sin(moonLatRad) * obliquityCos
        return arcSine(sinDecl)
    }

    /// Safe arc-sine matching the original VB implementation:
    /// avoids domain error when |a| is exactly 0 by nudging to a tiny value.
    private static func arcSine(_ a: Double) -> Double {
        let safeA = a == 0.0 ? 1e-28 : a
        return atan(safeA / sqrt(1.0 - safeA * safeA))
    }
}
