// WillnerBirthTimeCalc.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates the Approximate Birth Time (APRXBT) in local solar time
/// and the corrected Greenwich Sidereal Time at noon (CGST).
struct WillnerBirthTimeCalc {

    /// Computes APRXBT, BENOON, ST, and CGST.
    ///
    /// - Parameters:
    ///   - input: All birth input data.
    ///   - julianCenturyT: Julian century T from J1900, already corrected for delta-T.
    ///   - nutationLonRad: Nutation in longitude in radians (Δψ).
    ///   - obliquityCos: Cosine of the true obliquity.
    /// - Returns: (aprxbt, beNoon, st, cgst, longitudeInHours)
    static func calculate(input: SpiritualBirthtimeInput,
                          julianCenturyT: Double,
                          nutationLonRad: Double,
                          obliquityCos: Double)
        -> (aprxbt: Double, beNoon: Double, st: Double, cgst: Double, longitudeInHours: Double) {

        // Geographic longitude in hours (positive = east, negative = west)
        let longitudeInHours = input.geoLongitude / 15.0

        // Approximate birth time in local solar time (decimal hours)
        let birthHourDecimal = Double(input.hour) + Double(input.minute) / 60.0 + Double(input.second) / 3600.0
        let aprxbt = input.timeZone - longitudeInHours + birthHourDecimal

        let beNoon = 12.0 - aprxbt

        // Greenwich Sidereal Time at noon UT for the birth date.
        // Formula from the original Willner code (Newcomb-based):
        //   ST = (18.646065556 + 2400.051262·T + 2.5805556e-5·T² + Δψ·cos(ε)/π) mod 24
        // where T is Julian centuries from J1900, Δψ is nutation in longitude in radians,
        // and the last term converts the equation of the equinoxes from radians to hours.
        let rawST = 18.646065556
            + 2400.051262 * julianCenturyT
            + 2.5805556e-5 * julianCenturyT * julianCenturyT
            + nutationLonRad * obliquityCos * 0.3183098862   // 1/π ≈ 0.3183098862
        var st = rawST.truncatingRemainder(dividingBy: 24.0)
        if st < 0.0 { st += 24.0 }

        // CGST corrects for the observer's longitude using the sidereal/solar ratio
        let cgst = st + longitudeInHours * 0.002737909258

        return (aprxbt, beNoon, st, cgst, longitudeInHours)
    }
}
