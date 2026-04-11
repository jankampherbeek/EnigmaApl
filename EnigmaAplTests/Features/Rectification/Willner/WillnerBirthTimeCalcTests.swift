// WillnerBirthTimeCalcTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

/// Tests for WillnerBirthTimeCalc.calculate().
///
/// Reference case:
///   Birth: 1970-06-15, 14:30:00 LT, timezone +1 h East
///   Location: 52°13'N, 6°54'E → geoLat = +52.2167°, geoLon = +6.9000°
///
///   longitudeInHours = 6.9 / 15 = 0.46 h
///   birthHourDecimal = 14 + 30/60 = 14.5 h
///   APRXBT = 1.0 - 0.46 + 14.5 = 15.04 h
///   BENOON = 12 - 15.04 = -3.04  (afternoon birth)
struct WillnerBirthTimeCalcTests {

    private let delta = 1e-6

    private static let input = SpiritualBirthtimeInput(
        year: 1970, month: 6, day: 15,
        hour: 14, minute: 30, second: 0,
        timeZone: 1.0,
        geoLatitude: 52.2167,
        geoLongitude: 6.9
    )

    // Dummy obliquity values (don't affect APRXBT/BENOON/longitudeInHours)
    private static let dummyT       = 0.0
    private static let dummyNut     = 0.0
    private static let dummyObsCos  = cos(23.44 * Double.pi / 180.0)

    @Test("WillnerBirthTimeCalc: longitudeInHours = geoLon / 15")
    func testLongitudeInHours() {
        let (_, _, _, _, lonHours) = WillnerBirthTimeCalc.calculate(
            input: Self.input,
            julianCenturyT: Self.dummyT,
            nutationLonRad: Self.dummyNut,
            obliquityCos: Self.dummyObsCos
        )
        #expect(abs(lonHours - 6.9 / 15.0) < delta)
    }

    @Test("WillnerBirthTimeCalc: APRXBT = timezone - lonHours + birthTime")
    func testAprxbt() {
        let (aprxbt, _, _, _, _) = WillnerBirthTimeCalc.calculate(
            input: Self.input,
            julianCenturyT: Self.dummyT,
            nutationLonRad: Self.dummyNut,
            obliquityCos: Self.dummyObsCos
        )
        let expected = 1.0 - 6.9 / 15.0 + 14.5   // ≈ 15.04
        #expect(abs(aprxbt - expected) < delta)
    }

    @Test("WillnerBirthTimeCalc: BENOON = 12 - APRXBT")
    func testBeNoon() {
        let (aprxbt, beNoon, _, _, _) = WillnerBirthTimeCalc.calculate(
            input: Self.input,
            julianCenturyT: Self.dummyT,
            nutationLonRad: Self.dummyNut,
            obliquityCos: Self.dummyObsCos
        )
        #expect(abs(beNoon - (12.0 - aprxbt)) < delta)
    }

    @Test("WillnerBirthTimeCalc: CGST = ST + lonHours * 0.002737909258")
    func testCgstRelationToSt() {
        let (_, _, st, cgst, lonHours) = WillnerBirthTimeCalc.calculate(
            input: Self.input,
            julianCenturyT: Self.dummyT,
            nutationLonRad: Self.dummyNut,
            obliquityCos: Self.dummyObsCos
        )
        #expect(abs(cgst - (st + lonHours * 0.002737909258)) < delta)
    }

    @Test("WillnerBirthTimeCalc: ST is in range 0–24")
    func testStRange() {
        let (_, _, st, _, _) = WillnerBirthTimeCalc.calculate(
            input: Self.input,
            julianCenturyT: 0.7,   // arbitrary T
            nutationLonRad: 0.0001,
            obliquityCos: Self.dummyObsCos
        )
        #expect(st >= 0.0 && st < 24.0)
    }

    @Test("WillnerBirthTimeCalc: midnight birth gives APRXBT = timezone - lonHours")
    func testMidnightBirth() {
        let midnightInput = SpiritualBirthtimeInput(
            year: 1970, month: 6, day: 15,
            hour: 0, minute: 0, second: 0,
            timeZone: 1.0,
            geoLatitude: 52.0,
            geoLongitude: 0.0
        )
        let (aprxbt, _, _, _, _) = WillnerBirthTimeCalc.calculate(
            input: midnightInput,
            julianCenturyT: 0.0,
            nutationLonRad: 0.0,
            obliquityCos: 1.0
        )
        // lonHours = 0, birthHour = 0 → APRXBT = timezone = 1.0
        #expect(abs(aprxbt - 1.0) < delta)
    }
}
