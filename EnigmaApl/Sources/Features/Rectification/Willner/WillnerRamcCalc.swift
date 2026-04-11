// WillnerRamcCalc.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Converts an ecliptical longitude (with declination and ecliptical latitude) to a
/// RAMC value in degrees, quadrant-corrected for the Willner Moment-of-Incarnation algorithm.
///
/// Port of RAMC.cs / G_RAMC_S() from the Willner C# reference implementation.
struct WillnerRamcCalc {

    private static let pi    = Double.pi
    private static let pi2   = 2.0 * Double.pi
    private static let pi_2  = Double.pi / 2.0        // 90°
    private static let pi3_2 = 3.0 * Double.pi / 2.0  // 270°
    private static let deg   = 180.0 / Double.pi

    /// Computes MOMCLN (Moon) and URMCLN (Uranus) in degrees.
    ///
    /// - Parameters:
    ///   - moonLonRad: Moon ecliptical longitude in radians.
    ///   - moonLatRad: Moon ecliptical latitude in radians.
    ///   - moonDeclRad: Moon declination in radians.
    ///   - moonSign: Moon zodiac sign (1–12).
    ///   - uranusLonRad: Uranus ecliptical longitude in radians.
    ///   - uranusLatRad: Uranus ecliptical latitude in radians.
    ///   - uranusDeclRad: Uranus declination in radians.
    ///   - uranusSign: Uranus zodiac sign (1–12).
    ///   - geocentricLatRad: Geocentric birth latitude in radians.
    ///   - obliquityCos: Cosine of true obliquity.
    /// - Returns: (moonRamcDeg, uranusRamcDeg)
    static func calculate(moonLonRad: Double,
                          moonLatRad: Double,
                          moonDeclRad: Double,
                          moonSign: Int,
                          uranusLonRad: Double,
                          uranusLatRad: Double,
                          uranusDeclRad: Double,
                          uranusSign: Int,
                          geocentricLatRad: Double,
                          obliquityCos: Double) -> (moonRamcDeg: Double, uranusRamcDeg: Double) {

        // ── Hour-angle from ecliptic: cos(HA) = cos(lon)·cos(lat) / cos(decl) ──
        var moonHA  = arcCosine(cos(moonLonRad)   * cos(moonLatRad)   / cos(moonDeclRad))
        var uranHA  = arcCosine(cos(uranusLonRad) * cos(uranusLatRad) / cos(uranusDeclRad))

        // ── Semi-arc for each body:  arcsin(tan(decl)·tan(lat)) ──
        let moonSemiArc   = arcSine(tan(moonDeclRad)   * tan(geocentricLatRad))
        let uranusSemiArc = arcSine(tan(uranusDeclRad) * tan(geocentricLatRad))

        // ── Combine: sign-above-horizon bodies are in signs 7–12 ──
        moonHA  = (moonSign  >= 7) ? (pi3_2 - moonHA  - moonSemiArc)
                                   : (pi3_2 + moonHA  - moonSemiArc)
        uranHA  = (uranusSign >= 7) ? (pi3_2 - uranHA  - uranusSemiArc)
                                    : (pi3_2 + uranHA  - uranusSemiArc)

        moonHA  = normalise2Pi(moonHA)
        uranHA  = normalise2Pi(uranHA)

        let momcln = ramcDegrees(hourAngle: moonHA,   obliquityCos: obliquityCos)
        let urmcln = ramcDegrees(hourAngle: uranHA,   obliquityCos: obliquityCos)

        return (momcln, urmcln)
    }

    // MARK: - Private helpers

    /// Convert a normalised hour-angle (radians) to RAMC degrees using the obliquity,
    /// matching the quadrant logic in the C# RAMC.cs.
    private static func ramcDegrees(hourAngle ha: Double, obliquityCos: Double) -> Double {
        var angle = ha
        var result: Double

        if angle < pi_2 {
            // Quadrant I  (0 – 90°)
            result = atan(tan(angle) / obliquityCos) / (pi / 180.0)
        } else if angle > pi3_2 {
            // Quadrant IV (270° – 360°)
            angle -= pi3_2
            result = atan(obliquityCos * tan(angle)) / (pi / 180.0) + 270.0
        } else if angle > pi {
            // Quadrant III (180° – 270°)
            angle -= pi
            result = atan(tan(angle) / obliquityCos) / (pi / 180.0) + 180.0
        } else {
            // Quadrant II (90° – 180°)
            angle -= pi_2
            result = atan(obliquityCos * tan(angle)) / (pi / 180.0) + 90.0
        }
        return result
    }

    private static func normalise2Pi(_ angle: Double) -> Double {
        var a = angle
        if a < 0          { a += pi2 }
        if a >= pi2       { a -= pi2 }
        return a
    }

    private static func arcSine(_ a: Double) -> Double {
        let s = a == 0.0 ? 1e-28 : a
        return atan(s / sqrt(1.0 - s * s))
    }

    private static func arcCosine(_ a: Double) -> Double {
        let s = a == 0.0 ? 1e-28 : a
        return atan(sqrt(1.0 - s * s) / s)
    }
}
