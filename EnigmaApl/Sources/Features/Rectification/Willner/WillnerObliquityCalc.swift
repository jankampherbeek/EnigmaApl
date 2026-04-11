// WillnerObliquityCalc.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates the true obliquity of the ecliptic and nutation in longitude from the Swiss Ephemeris.
///
/// SE factor -1 (SE_ECL_NUT) with flags = 2 returns:
///   result[0] = true obliquity (degrees)
///   result[1] = mean obliquity (degrees)
///   result[2] = nutation in longitude (arcseconds)
///   result[3] = nutation in obliquity (arcseconds)
struct WillnerObliquityCalc {

    private static let arcsecToRad = Double.pi / (180.0 * 3600.0)

    /// Returns (trueObliquityRad, nutationInLongRad) for the given Julian Day at noon UT.
    static func calculate(julianDayNoon: Double, seWrapper: SEWrapper) -> (trueObliquityRad: Double, nutationLonRad: Double) {
        guard let pos = seWrapper.calculateFactorPosition(julianDay: julianDayNoon, factor: -1, flags: 2) else {
            return (0.0, 0.0)
        }
        let trueObliquityRad = pos.mainPos * Double.pi / 180.0
        // pos.distance = nutation in longitude in arcseconds
        let nutationLonRad = pos.distance * arcsecToRad
        return (trueObliquityRad, nutationLonRad)
    }
}
