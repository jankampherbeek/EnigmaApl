// NoonPositionsTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

/// Tests for NoonPositions.calcNoonPositions(date:seWrapper:).
///
/// Reference date: 2010-01-01 (Gregorian).
/// At noon UT on 2010-01-01 the Sun is in early Capricorn (~281°), so longitude
/// must be in the range 270–360. The Moon moves quickly (~12°/day) and is in
/// Cancer/Leo on this date, so its longitude is in the range 90–150.
/// Uranus is near 0° Pisces (~354°), so its longitude is in the range 340–360.
///
/// All three bodies should produce values within valid astronomical ranges, and
/// the result dictionary must contain exactly the three expected factors.
@MainActor
struct NoonPositionsTests {

    private static let testDate = AstronomicalDate(Year: 2010, Month: 1, Day: 1)
    private static let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()

    // MARK: - Result completeness

    @Test("NoonPositions: result contains exactly Sun, Moon, and Uranus")
    func testResultContainsThreeFactors() {
        let result = NoonPositions.calcNoonPositions(date: Self.testDate, seWrapper: Self.seWrapper)
        #expect(result.count == 3)
        #expect(result[.sun]    != nil)
        #expect(result[.moon]   != nil)
        #expect(result[.uranus] != nil)
    }

    // MARK: - Longitude range (0–360)

    @Test("NoonPositions: Sun longitude is in valid range 0–360")
    func testSunLongitudeRange() {
        let result = NoonPositions.calcNoonPositions(date: Self.testDate, seWrapper: Self.seWrapper)
        let lon = result[.sun]!.longitude
        #expect(lon >= 0.0 && lon < 360.0)
    }

    @Test("NoonPositions: Moon longitude is in valid range 0–360")
    func testMoonLongitudeRange() {
        let result = NoonPositions.calcNoonPositions(date: Self.testDate, seWrapper: Self.seWrapper)
        let lon = result[.moon]!.longitude
        #expect(lon >= 0.0 && lon < 360.0)
    }

    @Test("NoonPositions: Uranus longitude is in valid range 0–360")
    func testUranusLongitudeRange() {
        let result = NoonPositions.calcNoonPositions(date: Self.testDate, seWrapper: Self.seWrapper)
        let lon = result[.uranus]!.longitude
        #expect(lon >= 0.0 && lon < 360.0)
    }

    // MARK: - Declination range (−90 to +90)

    @Test("NoonPositions: Sun declination is in valid range ±90°")
    func testSunDeclinationRange() {
        let result = NoonPositions.calcNoonPositions(date: Self.testDate, seWrapper: Self.seWrapper)
        let dec = result[.sun]!.declination
        #expect(dec >= -90.0 && dec <= 90.0)
    }

    @Test("NoonPositions: Moon declination is in valid range ±90°")
    func testMoonDeclinationRange() {
        let result = NoonPositions.calcNoonPositions(date: Self.testDate, seWrapper: Self.seWrapper)
        let dec = result[.moon]!.declination
        #expect(dec >= -90.0 && dec <= 90.0)
    }

    @Test("NoonPositions: Uranus declination is in valid range ±90°")
    func testUranusDeclinationRange() {
        let result = NoonPositions.calcNoonPositions(date: Self.testDate, seWrapper: Self.seWrapper)
        let dec = result[.uranus]!.declination
        #expect(dec >= -90.0 && dec <= 90.0)
    }

    // MARK: - Approximate positions for 2010-01-01 noon UT

    @Test("NoonPositions: Sun is in Capricorn on 2010-01-01 (longitude 270–300)")
    func testSunInCapricorn() {
        let result = NoonPositions.calcNoonPositions(date: Self.testDate, seWrapper: Self.seWrapper)
        let lon = result[.sun]!.longitude
        // Sun enters Capricorn around Dec 21, exits around Jan 20.
        #expect(lon >= 270.0 && lon < 300.0)
    }

    @Test("NoonPositions: Uranus is near 0° Pisces on 2010-01-01 (longitude 340–360)")
    func testUranusNearPisces() {
        let result = NoonPositions.calcNoonPositions(date: Self.testDate, seWrapper: Self.seWrapper)
        let lon = result[.uranus]!.longitude
        // Uranus was around 354° on this date.
        #expect(lon >= 340.0 && lon < 360.0)
    }

    @Test("NoonPositions: Sun has southerly declination near winter solstice (< 0°)")
    func testSunDeclinationSouthInJanuary() {
        let result = NoonPositions.calcNoonPositions(date: Self.testDate, seWrapper: Self.seWrapper)
        let dec = result[.sun]!.declination
        // January 1: Sun is still south of equator (~−23°).
        #expect(dec < 0.0)
    }

    // MARK: - Different dates produce different results

    @Test("NoonPositions: Moon position differs between two consecutive days")
    func testMoonMovesDay() {
        let date1 = AstronomicalDate(Year: 2010, Month: 1, Day: 1)
        let date2 = AstronomicalDate(Year: 2010, Month: 1, Day: 2)
        let seWrapper = Self.seWrapper
        let result1 = NoonPositions.calcNoonPositions(date: date1, seWrapper: seWrapper)
        let result2 = NoonPositions.calcNoonPositions(date: date2, seWrapper: seWrapper)
        let lon1 = result1[.moon]!.longitude
        let lon2 = result2[.moon]!.longitude
        // Moon moves ~12°/day, so longitudes must differ.
        #expect(abs(lon2 - lon1) > 1.0)
    }
}
