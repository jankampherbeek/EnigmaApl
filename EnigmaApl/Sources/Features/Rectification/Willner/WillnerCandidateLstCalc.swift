// WillnerCandidateLstCalc.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Result of one candidate LST search.
struct WillnerLstCandidate {
    let lst: Double        // Local Sidereal Time (decimal hours)
    let moonNumIdx: Int    // MOONUM index that generated this candidate (1–4)
    let uranusNumIdx: Int  // URANUM index
    let slotIdx: Int       // LST slot index (1–8)
    let additionalHours: Int
}

/// Computes the 8 candidate Local Sidereal Times for each combination of
/// Moon-number and Uranus-number, then filters them to the allowed birth-time window.
///
/// Port of Incarnation_Routine_CLST.cs / CLST().
struct WillnerCandidateLstCalc {

    /// Length of a sidereal day in hours.
    private static let siderealDay   = 23.935555555555556
    /// Half a sidereal day.
    private static let siderealDay12 = siderealDay / 2.0
    /// Solar/sidereal conversion factor.
    private static let solarSidereal = 1.002737909259
    /// 6 sidereal hours expressed in solar hours (for the fallback 6-h correction).
    private static let sixSiderealHours = 6.016427455554

    private static let pi    = Double.pi
    private static let pi2   = 2.0 * Double.pi
    private static let pi_2  = Double.pi / 2.0
    private static let pi3_2 = 3.0 * Double.pi / 2.0

    /// - Parameters:
    ///   - moonNums: MOONUM[1..4] from WillnerSignNumbers.
    ///   - uranusNums: URANUM[1..4].
    ///   - moonRamcDeg: MOMCLN in degrees.
    ///   - uranusRamcDeg: URMCLN in degrees.
    ///   - obliquityCos: Cosine of true obliquity.
    ///   - cgst: Corrected GST at noon (decimal hours).
    ///   - aprxbt: Approximate birth time in local solar time (decimal hours).
    ///   - isAmBirth: true if birth is AM, false if PM.
    ///   - night: Additional hour offset for southern latitudes (0 or 12).
    /// - Returns: Surviving LST candidates.
    static func calculate(moonNums: [Int],
                          uranusNums: [Int],
                          moonRamcDeg: Double,
                          uranusRamcDeg: Double,
                          obliquityCos: Double,
                          cgst: Double,
                          aprxbt: Double,
                          isAmBirth: Bool,
                          night: Double) -> [WillnerLstCandidate] {

        var results: [WillnerLstCandidate] = []

        for moonIdx in 1...4 {
            guard moonNums[moonIdx] != 0 else { continue }

            // Moon: convert number+RAMC to RA in radians, then to sidereal hours
            let moonRASid = raToSiderealHours(number: moonNums[moonIdx],
                                              ramcDeg: moonRamcDeg,
                                              obliquityCos: obliquityCos)

            for uranusIdx in 1...4 {
                guard uranusNums[uranusIdx] != 0 else { continue }

                // Uranus: same conversion
                let uranusRASid = raToSiderealHours(number: uranusNums[uranusIdx],
                                                    ramcDeg: uranusRamcDeg,
                                                    obliquityCos: obliquityCos)

                // Differences and sums of sidereal RA hours
                var diff1 = absDiff(moonRASid, uranusRASid)
                if diff1 > siderealDay12 { diff1 -= siderealDay12 }
                var diff2 = siderealDay12 - diff1

                var sum1 = moonRASid + uranusRASid
                if sum1 > siderealDay  { sum1 -= siderealDay }
                if sum1 > siderealDay12 { sum1 -= siderealDay12 }
                var sum2 = siderealDay12 - sum1

                // Convert to solar-time units
                var nightSolar = night * solarSidereal
                diff1 *= solarSidereal
                diff2 *= solarSidereal
                sum1  *= solarSidereal
                sum2  *= solarSidereal

                // 8 candidate LSTs
                let candidates: [Double] = [
                    0.0,                        // index 0 unused
                    cgst - diff1 + nightSolar,
                    cgst - diff2 + nightSolar,
                    cgst - sum1  + nightSolar,
                    cgst - sum2  + nightSolar,
                    cgst + diff1 - nightSolar,
                    cgst + diff2 - nightSolar,
                    cgst + sum1  - nightSolar,
                    cgst + sum2  - nightSolar
                ]

                // Reference time for window check
                let reference = isAmBirth ? (cgst + aprxbt) : (cgst - 12.0 + aprxbt)

                for slot in 1...8 {
                    var lst = candidates[slot]
                    var addHrs = 0

                    // Window: candidate must not be more than 1 h later or more than 5 h earlier
                    if lst > reference + 1.0 || lst < reference - 5.0 {
                        addHrs = 6
                        if lst > reference + 1.0 { lst -= sixSiderealHours }
                        if lst < reference - 5.0 { lst += sixSiderealHours }
                        // If still out of window, discard
                        if lst < reference - 5.0 || lst > reference + 1.0 { continue }
                    }

                    // Discard if exactly equal to CGST (degenerate case)
                    if lst == cgst { continue }

                    results.append(WillnerLstCandidate(
                        lst: lst,
                        moonNumIdx: moonIdx,
                        uranusNumIdx: uranusIdx,
                        slotIdx: slot,
                        additionalHours: addHrs
                    ))
                }
            }
        }

        return results
    }

    // MARK: - Private helpers

    /// Convert a (number, RAMC-degrees) pair to sidereal hours using the obliquity.
    /// This mirrors the RA-conversion logic in CLST() for both Moon (array) and Uranus (array2).
    private static func raToSiderealHours(number: Int, ramcDeg: Double, obliquityCos: Double) -> Double {
        var angle = (Double(number) + ramcDeg - 1.0) * Double.pi / 180.0
        if angle >= pi2 { angle -= pi2 }

        let ra = eclipticToRA(angle: angle, obliquityCos: obliquityCos)

        // Convert RA radians to sidereal hours (radian-to-hour factor = 12/π)
        var hours = ra * (12.0 / Double.pi)     // = ra * 3.81971863420549
        if hours > siderealDay12 { hours -= siderealDay12 }
        return hours
    }

    /// Converts an ecliptic angle (radians, 0–2π) to its right-ascension equivalent
    /// using the same quadrant logic as the CLST routine for array[]/array2[].
    private static func eclipticToRA(angle: Double, obliquityCos: Double) -> Double {
        var a = angle
        if a < pi_2 {
            return atan(obliquityCos * tan(a))
        } else if a > pi3_2 {
            a -= pi3_2
            return atan(tan(a) / obliquityCos) + pi3_2
        } else if a > pi {
            a -= pi
            return atan(obliquityCos * tan(a)) + pi
        } else {
            // pi_2 … pi
            a -= pi_2
            return atan(tan(a) / obliquityCos) + pi_2
        }
    }

    private static func absDiff(_ a: Double, _ b: Double) -> Double {
        return a > b ? a - b : b - a
    }
}
