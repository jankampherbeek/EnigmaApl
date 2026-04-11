// GeocentricLatitudeTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

/// Test data:
///   Input:  geographic latitude 52° 13' 00" N  = 52.21667°
///   Output: geocentric latitude 52° 01' 48.7" N ≈ 52.030194°
struct GeocentricLatitudeTests {

    /// Tolerance: 0.0001° ≈ 0.36" — sufficient for the expected precision of the formula.
    private let delta = 0.0001

    // MARK: - Happy flow

    @Test("GeocentricLatitude: 52°13'00\" N geographic → 52°01'48.7\" N geocentric")
    func testKnownNorthernLatitude() {
        let geographic = 52.0 + 13.0 / 60.0                   // 52°13'00" N
        let expectedGeocentric = 52.0 + 1.0 / 60.0 + 48.7 / 3600.0  // 52°01'48.7" N

        let result = GeocentricLatitude.geographicToGeocentric(geographic)

        #expect(abs(result - expectedGeocentric) < delta)
    }

    @Test("GeocentricLatitude: geocentric latitude is always smaller in magnitude than geographic")
    func testGeocentricSmallerMagnitude() {
        let geographic = 52.0 + 13.0 / 60.0
        let result = GeocentricLatitude.geographicToGeocentric(geographic)
        #expect(result < geographic)
    }

    @Test("GeocentricLatitude: equator (0°) maps to 0°")
    func testEquatorIsUnchanged() {
        let result = GeocentricLatitude.geographicToGeocentric(0.0)
        #expect(abs(result) < 1e-10)
    }

    @Test("GeocentricLatitude: 90° geographic maps to 90° geocentric")
    func testNorthPoleIsUnchanged() {
        let result = GeocentricLatitude.geographicToGeocentric(90.0)
        #expect(abs(result - 90.0) < delta)
    }

    @Test("GeocentricLatitude: result is negative for southern latitudes")
    func testSouthernLatitudeIsNegative() {
        let result = GeocentricLatitude.geographicToGeocentric(-52.0 - 13.0 / 60.0)
        #expect(result < 0.0)
    }

    @Test("GeocentricLatitude: southern hemisphere mirrors northern hemisphere")
    func testSouthernMirrorsNorthern() {
        let north = GeocentricLatitude.geographicToGeocentric(40.0)
        let south = GeocentricLatitude.geographicToGeocentric(-40.0)
        #expect(abs(north + south) < 1e-10)
    }
}
