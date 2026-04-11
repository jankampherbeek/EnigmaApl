// WillnerMoonDeclinationCalcTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

/// Tests for WillnerMoonDeclinationCalc.calculate().
///
/// The formula is:
///   sin(decl) = cos(lat)·sin(lon)·sin(obliquity) + sin(lat)·cos(obliquity)
///
/// Reference cases are computed analytically for known inputs.
struct WillnerMoonDeclinationCalcTests {

    private let delta = 1e-9
    private static let obliquity = 23.4393 * Double.pi / 180.0
    private static let sinObl = sin(obliquity)
    private static let cosObl = cos(obliquity)

    @Test("WillnerMoonDeclinationCalc: Moon at 0° lon, 0° lat → declination ≈ 0")
    func testMoonAtAries() {
        let decl = WillnerMoonDeclinationCalc.calculate(
            moonLonRad: 0.0,
            moonLatRad: 0.0,
            obliquitySin: Self.sinObl,
            obliquityCos: Self.cosObl
        )
        // sin(decl) = cos(0)·sin(0)·sinObl + sin(0)·cosObl = 0
        #expect(abs(decl) < 1e-10)
    }

    @Test("WillnerMoonDeclinationCalc: Moon at 90° lon, 0° lat → declination ≈ obliquity")
    func testMoonAt90Lon() {
        let decl = WillnerMoonDeclinationCalc.calculate(
            moonLonRad: Double.pi / 2.0,
            moonLatRad: 0.0,
            obliquitySin: Self.sinObl,
            obliquityCos: Self.cosObl
        )
        // sin(decl) = cos(0)·sin(90°)·sinObl = sinObl → decl ≈ obliquity
        let expected = asin(Self.sinObl)
        #expect(abs(decl - expected) < delta)
    }

    @Test("WillnerMoonDeclinationCalc: Moon at 270° lon, 0° lat → declination ≈ -obliquity")
    func testMoonAt270Lon() {
        let decl = WillnerMoonDeclinationCalc.calculate(
            moonLonRad: 3.0 * Double.pi / 2.0,
            moonLatRad: 0.0,
            obliquitySin: Self.sinObl,
            obliquityCos: Self.cosObl
        )
        let expected = asin(-Self.sinObl)
        #expect(abs(decl - expected) < delta)
    }

    @Test("WillnerMoonDeclinationCalc: declination is in range ±90°")
    func testDeclinationRange() {
        let decl = WillnerMoonDeclinationCalc.calculate(
            moonLonRad: 1.2,
            moonLatRad: 0.08,
            obliquitySin: Self.sinObl,
            obliquityCos: Self.cosObl
        )
        #expect(decl >= -Double.pi / 2.0 && decl <= Double.pi / 2.0)
    }

    @Test("WillnerMoonDeclinationCalc: ecliptic latitude shifts declination")
    func testLatitudeEffect() {
        let declNoLat = WillnerMoonDeclinationCalc.calculate(
            moonLonRad: 1.0,
            moonLatRad: 0.0,
            obliquitySin: Self.sinObl,
            obliquityCos: Self.cosObl
        )
        let declWithLat = WillnerMoonDeclinationCalc.calculate(
            moonLonRad: 1.0,
            moonLatRad: 0.1,
            obliquitySin: Self.sinObl,
            obliquityCos: Self.cosObl
        )
        // Adding positive latitude to a northern longitude should increase declination
        #expect(declWithLat != declNoLat)
    }
}
