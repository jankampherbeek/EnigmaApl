// SpiritualBirthtimeCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Orchestrates the full Willner Moment-of-Incarnation (Spiritual Birthtime) calculation.
///
/// Usage:
/// ```swift
/// let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper() // or app-level instance
/// let input = SpiritualBirthtimeInput(...)
/// let candidates = SpiritualBirthtimeCalculator.calculate(input: input, seWrapper: seWrapper)
/// ```
public struct SpiritualBirthtimeCalculator {

    /// J1900 Julian Day used as epoch for the Willner T formula.
    private static let j1900 = 2415020.0

    /// Calculates the Spiritual Birthtime candidates for the given input.
    ///
    /// - Parameters:
    ///   - input: All birth data.
    ///   - seWrapper: Swiss Ephemeris wrapper (use app-level instance in production;
    ///                `SEWrapperTestCoordinator.shared.getSEWrapper()` in tests).
    /// - Returns: Candidates sorted chronologically by TLT.
    public static func calculate(input: SpiritualBirthtimeInput,
                                 seWrapper: SEWrapper) -> [SpiritualBirthtimeCandidate] {

        // ── Step 1: Noon Julian Day ───────────────────────────────────────────────
        let birthDate = AstronomicalDate(Year: input.year, Month: input.month, Day: input.day)
        let noonTime  = AstronomicalTime(Hour: 12, Minute: 0, Second: 0)
        let julianDayNoon = seWrapper.julianDay(date: birthDate, time: noonTime)

        // ── Step 2: Noon positions (SE) ──────────────────────────────────────────
        let noonPositions = NoonPositions.calcNoonPositions(date: birthDate, seWrapper: seWrapper)
        guard
            let sunPos    = noonPositions[.sun],
            let moonPos   = noonPositions[.moon],
            let uranusPos = noonPositions[.uranus]
        else {
            return []
        }

        let deg2rad = Double.pi / 180.0

        let sunLonRad    = sunPos.longitude    * deg2rad
        let moonLonRad   = moonPos.longitude   * deg2rad
        let moonLatRad   = moonPos.latitude    * deg2rad
        let uranusLonRad = uranusPos.longitude * deg2rad
        let uranusLatRad = uranusPos.latitude  * deg2rad
        let uranusDeclRad = uranusPos.declination * deg2rad

        // ── Step 3: Obliquity and nutation from SE ────────────────────────────────
        let (trueObliquityRad, nutationLonRad) =
            WillnerObliquityCalc.calculate(julianDayNoon: julianDayNoon, seWrapper: seWrapper)

        let obliquitySin = sin(trueObliquityRad)
        let obliquityCos = cos(trueObliquityRad)

        // ── Step 4: Geocentric latitude ───────────────────────────────────────────
        let geoLatDeg        = abs(input.geoLatitude)
        let geocentricLatRad = GeocentricLatitude.geographicToGeocentric(geoLatDeg) * deg2rad
            * (input.geoLatitude < 0 ? -1.0 : 1.0)

        // ── Step 5: Julian century T from J1900 (Willner epoch) ──────────────────
        // The original C# code uses TT = (JD - J1900) / 36525, then adds delta-T.
        // We use the SE-based JD directly (already in UT) and omit delta-T since SE
        // positions already account for it via Swiss Ephemeris.
        let julianCenturyT = (julianDayNoon - j1900) / 36525.0

        // ── Step 6: Birth time and GST ────────────────────────────────────────────
        let (aprxbt, beNoon, st, cgst, longitudeInHours) = WillnerBirthTimeCalc.calculate(
            input: input,
            julianCenturyT: julianCenturyT,
            nutationLonRad: nutationLonRad,
            obliquityCos: obliquityCos
        )

        // ── Step 7: Zodiac signs (1–12) ───────────────────────────────────────────
        let sunSign    = Int(sunPos.longitude    / 30.0) + 1
        let moonSign   = Int(moonPos.longitude   / 30.0) + 1
        let uranusSign = Int(uranusPos.longitude / 30.0) + 1

        // ── Step 8: Moon's declination from ecliptic ──────────────────────────────
        let moonDeclRad = WillnerMoonDeclinationCalc.calculate(
            moonLonRad: moonLonRad,
            moonLatRad: moonLatRad,
            obliquitySin: obliquitySin,
            obliquityCos: obliquityCos
        )

        // ── Step 9: RAMC values for Moon and Uranus ───────────────────────────────
        let (moonRamcDeg, uranusRamcDeg) = WillnerRamcCalc.calculate(
            moonLonRad: moonLonRad,
            moonLatRad: moonLatRad,
            moonDeclRad: moonDeclRad,
            moonSign: moonSign,
            uranusLonRad: uranusLonRad,
            uranusLatRad: uranusLatRad,
            uranusDeclRad: uranusDeclRad,
            uranusSign: uranusSign,
            geocentricLatRad: geocentricLatRad,
            obliquityCos: obliquityCos
        )

        // ── Step 10: Sign numbers ─────────────────────────────────────────────────
        let (moonNums, uranusNums) = WillnerSignNumbers.calculate(
            sunSign: sunSign,
            moonSign: moonSign,
            uranusSign: uranusSign
        )

        // ── Step 11: Candidate LSTs ───────────────────────────────────────────────
        // Southern latitude: add 12 h offset (night correction)
        let night = input.geoLatitude < 0 ? 12.0 : 0.0
        // AM/PM: birth hour < 12 is AM
        let isAmBirth = input.hour < 12

        let lstCandidates = WillnerCandidateLstCalc.calculate(
            moonNums: moonNums,
            uranusNums: uranusNums,
            moonRamcDeg: moonRamcDeg,
            uranusRamcDeg: uranusRamcDeg,
            obliquityCos: obliquityCos,
            cgst: cgst,
            aprxbt: aprxbt,
            isAmBirth: isAmBirth,
            night: night
        )

        // ── Step 12: TLT refinement and output assembly ───────────────────────────
        var candidates: [SpiritualBirthtimeCandidate] = []

        for lstCandidate in lstCandidates {
            var lst = lstCandidate.lst

            // Normalise LST to 0–24
            if lst > 24.0 { lst -= 24.0 }
            if lst < 0.0  { lst += 24.0 }

            let tlt = WillnerTltRefiner.refine(
                candidateLST: lst,
                cgst: cgst,
                longitudeInHours: longitudeInHours,
                noonT: julianCenturyT,
                nutationLonRad: nutationLonRad,
                obliquityCos: obliquityCos
            )

            // GMT = TLT + longitudeInHours
            var gmt = tlt + longitudeInHours
            if gmt > 12.0 { gmt -= 12.0 }
            if gmt < 0.0  { gmt += 12.0 }

            // Zone time = GMT + timezone
            var zoneTime = gmt + input.timeZone
            if zoneTime > 24.0 { zoneTime -= 24.0 }
            if zoneTime < 0.0  { zoneTime += 24.0 }

            // ARC = LST in radians, normalised to 0–2π
            var arc = lst * (Double.pi / 12.0)    // hours → radians
            if arc > 2 * Double.pi { arc -= 2 * Double.pi }
            if arc < 0             { arc += 2 * Double.pi }

            let isAm = lst < cgst

            candidates.append(SpiritualBirthtimeCandidate(
                lst: lst,
                tlt: tlt,
                gmt: gmt,
                zoneTime: zoneTime,
                arc: arc,
                isAm: isAm,
                additionalHours: lstCandidate.additionalHours
            ))
        }

        // Sort by TLT ascending
        return candidates.sorted { $0.tlt < $1.tlt }
    }
}
