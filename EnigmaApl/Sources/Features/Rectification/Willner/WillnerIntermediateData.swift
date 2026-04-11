// WillnerIntermediateData.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Intermediate values computed during the Spiritual Birthtime calculation.
/// Passed between the sub-calculators so each step has what it needs.
struct WillnerIntermediateData {
    // MARK: - Obliquity
    /// True obliquity of the ecliptic in radians (includes nutation in obliquity).
    let obliquityRad: Double
    /// Sine of true obliquity.
    let obliquitySin: Double
    /// Cosine of true obliquity.
    let obliquityCos: Double
    /// Nutation in longitude in radians (Δψ).
    let nutationLonRad: Double

    // MARK: - Geocentric latitude
    /// Geocentric birth latitude in radians.
    let geocentricLatRad: Double

    // MARK: - Noon positions (all values in radians)
    /// Sun's ecliptical longitude at noon UT on the birth date.
    let sunLonRad: Double
    /// Moon's ecliptical longitude at noon UT.
    let moonLonRad: Double
    /// Moon's ecliptical latitude at noon UT.
    let moonLatRad: Double
    /// Uranus's ecliptical longitude at noon UT.
    let uranusLonRad: Double
    /// Uranus's ecliptical latitude at noon UT.
    let uranusLatRad: Double
    /// Uranus's declination at noon UT in radians.
    let uranusDeclRad: Double

    // MARK: - Sign numbers (1–12, 0 = not used)
    /// Sun's zodiac sign (1 = Aries … 12 = Pisces).
    let sunSign: Int
    /// Moon's zodiac sign.
    let moonSign: Int
    /// Uranus's zodiac sign.
    let uranusSign: Int

    // MARK: - Moon declination derived from ecliptic
    /// Moon's declination derived from its ecliptical position and obliquity, in radians.
    let moonDeclRad: Double

    // MARK: - RAMC values (degrees)
    /// RAMC degree for Moon (MOMCLN).
    let moonRamcDeg: Double
    /// RAMC degree for Uranus (URMCLN).
    let uranusRamcDeg: Double

    // MARK: - Birth time reference values
    /// Approximate birth time in local solar time (decimal hours).
    let aprxbt: Double
    /// Hours before noon (12 − APRXBT).
    let beNoon: Double
    /// Corrected Greenwich Sidereal Time at noon (decimal hours).
    let cgst: Double
    /// Sidereal time at noon mod 24 (decimal hours).
    let st: Double
    /// Geographic longitude expressed as hours (positive = east).
    let longitudeInHours: Double
    /// Julian century T from epoch J1900 (used in the original GST formula).
    let julianCenturyT: Double
}
