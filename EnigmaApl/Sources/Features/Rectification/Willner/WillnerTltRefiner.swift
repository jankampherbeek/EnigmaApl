// WillnerTltRefiner.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Refines a candidate LST to the True Local Time (TLT) by iteratively adjusting
/// the Julian-century value until the recalculated GST matches the candidate LST.
///
/// Port of TLTCorrection.cs / G_TLT_Correction_F() from the Willner reference implementation.
struct WillnerTltRefiner {

    /// Maximum number of refinement iterations (the C# code stops at 5).
    private static let maxIterations = 5

    /// - Parameters:
    ///   - candidateLST: The candidate Local Sidereal Time (decimal hours) to refine.
    ///   - cgst: Corrected Greenwich Sidereal Time at noon.
    ///   - longitudeInHours: Geographic longitude expressed as hours.
    ///   - noonT: Julian century T from J1900 (at noon on the birth date), delta-T corrected.
    ///   - nutationLonRad: Nutation in longitude in radians (Δψ) — treated as constant here.
    ///   - obliquityCos: Cosine of the true obliquity — treated as constant here.
    /// - Returns: Refined TLT in decimal hours.
    static func refine(candidateLST: Double,
                       cgst: Double,
                       longitudeInHours: Double,
                       noonT: Double,
                       nutationLonRad: Double,
                       obliquityCos: Double) -> Double {

        // Initial offset between candidate LST and CGST
        var offset = candidateLST - cgst

        // Correct for longitude
        let offsetWithLon = offset + longitudeInHours

        // Compute new T
        let newTT = noonT + offsetWithLon / 24.0 / 36525.0

        // First iteration: compute GST at newTT, add offset
        var values = [Double](repeating: 0.0, count: maxIterations + 2)
        values[1] = gst(t: newTT, nutationLonRad: nutationLonRad, obliquityCos: obliquityCos) + offset

        var finalOffset = offset

        for i in 1...maxIterations {
            // Exact match — done
            if values[i] == candidateLST { break }

            let diff = values[i] - candidateLST
            finalOffset = diff > 0 ? offset - diff : offset + abs(diff)

            if i < maxIterations {
                values[i + 1] = gst(t: newTT, nutationLonRad: nutationLonRad, obliquityCos: obliquityCos) + finalOffset
            }
        }

        var tlt = finalOffset
        if tlt > 24.0 { tlt -= 24.0 }
        if tlt < 0.0  { tlt += 24.0 }
        return tlt
    }

    // MARK: - Private

    /// Computes Greenwich Sidereal Time at a given Julian century T using the same
    /// Newcomb formula as WillnerBirthTimeCalc.
    private static func gst(t: Double, nutationLonRad: Double, obliquityCos: Double) -> Double {
        let raw = 18.646065556
            + 2400.051262 * t
            + 2.5805556e-5 * t * t
            + nutationLonRad * obliquityCos * 0.3183098862
        var result = raw.truncatingRemainder(dividingBy: 24.0)
        if result < 0.0 { result += 24.0 }
        return result
    }
}
