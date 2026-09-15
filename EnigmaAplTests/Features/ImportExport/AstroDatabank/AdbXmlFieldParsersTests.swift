// AdbXmlFieldParsersTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct AdbXmlFieldParsersTests {

    // MARK: - Coordinates

    @Test("ADB coordinate: latitude/longitude without seconds")
    func testCoordinateWithoutSeconds() {
        let lat = try! #require(AdbXmlFieldParsers.parseCoordinate("52n04", positiveChar: "n", negativeChar: "s"))
        let lon = try! #require(AdbXmlFieldParsers.parseCoordinate("1w20", positiveChar: "e", negativeChar: "w"))
        #expect(lat > 0)
        #expect(lon < 0)
        #expect(abs(lat - (52.0 + 4.0/60.0)) < 0.0001)
    }

    @Test("ADB coordinate: trailing digits without a colon are treated as seconds")
    func testCoordinateNoColonSeconds() {
        let lat = try! #require(AdbXmlFieldParsers.parseCoordinate("52n0430", positiveChar: "n", negativeChar: "s"))
        #expect(abs(lat - (52.0 + 4.0/60.0 + 30.0/3600.0)) < 0.0001)
    }

    @Test("ADB coordinate: colon-delimited seconds are also accepted")
    func testCoordinateColonSeconds() {
        let lat = try! #require(AdbXmlFieldParsers.parseCoordinate("52n04:30", positiveChar: "n", negativeChar: "s"))
        #expect(abs(lat - (52.0 + 4.0/60.0 + 30.0/3600.0)) < 0.0001)
    }

    // MARK: - Meridian / stmerid

    @Test("ADB stmerid: 'h1e' is a direct 1-hour east offset")
    func testMeridianHoursEast() {
        #expect(AdbXmlFieldParsers.parseMeridianOffsetSeconds("h1e") == 3600)
    }

    @Test("ADB stmerid: 'h5w' is a direct 5-hour west offset")
    func testMeridianHoursWest() {
        #expect(AdbXmlFieldParsers.parseMeridianOffsetSeconds("h5w") == -18000)
    }

    @Test("ADB stmerid: 'm72e30' is a geographic meridian converted at 15° = 1 hour")
    func testMeridianDegrees() {
        let expected = Int(((72.0 + 30.0/60.0) / 15.0 * 3600.0).rounded())
        #expect(AdbXmlFieldParsers.parseMeridianOffsetSeconds("m72e30") == expected)
    }

    @Test("ADB stmerid: 'm4w15' is west of Greenwich, negative offset")
    func testMeridianDegreesWest() {
        #expect(AdbXmlFieldParsers.parseMeridianOffsetSeconds("m4w15")! < 0)
    }

    // MARK: - Time

    @Test("ADB sbtime text: HH:mm")
    func testTimeHM() {
        let result = try! #require(AdbXmlFieldParsers.parseTime("08:30"))
        #expect(result.hour == 8 && result.minute == 30 && result.second == 0)
    }

    @Test("ADB sbtime text: HH:mm:ss")
    func testTimeHMS() {
        let result = try! #require(AdbXmlFieldParsers.parseTime("08:30:45"))
        #expect(result.second == 45)
    }
}
