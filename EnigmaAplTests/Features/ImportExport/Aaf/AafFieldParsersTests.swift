// AafFieldParsersTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct AafFieldParsersTests {

    // MARK: - Date

    @Test("AAF date: plain date without suffix, on/after cutover defaults to Gregorian")
    func testDateWithoutSuffixModern() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseDate("29.1.1953", recordNumber: 1, messages: &messages))
        #expect(result.day == 29 && result.month == 1 && result.year == 1953)
        #expect(result.isGregorian)
        #expect(messages.isEmpty)
    }

    @Test("AAF date: plain date before cutover defaults to Julian")
    func testDateWithoutSuffixHistorical() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseDate("1.1.1500", recordNumber: 1, messages: &messages))
        #expect(!result.isGregorian)
    }

    @Test("AAF date: explicit Gregorian suffix 'g'")
    func testGregorianSuffix() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseDate("7.10.1582g", recordNumber: 1, messages: &messages))
        #expect(result.isGregorian)
        #expect(result.year == 1582)
    }

    @Test("AAF date: explicit Julian suffix 'j'")
    func testJulianSuffix() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseDate("7.10.1582j", recordNumber: 1, messages: &messages))
        #expect(!result.isGregorian)
    }

    @Test("AAF date: BCE astronomical year numbering is used directly")
    func testBceAstronomicalYear() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseDate("24.12.-6g", recordNumber: 1, messages: &messages))
        #expect(result.year == -6)
    }

    @Test("AAF date: invalid day-in-month is a fatal error")
    func testInvalidDate() {
        var messages: [ExchangeMessage] = []
        let result = AafFieldParsers.parseDate("30.2.2000g", recordNumber: 1, messages: &messages)
        #expect(result == nil)
        #expect(messages.contains { $0.severity == .fatal })
    }

    // MARK: - Time

    @Test("AAF time: HH:mm")
    func testTimeHM() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseTime("16:55", recordNumber: 1, messages: &messages))
        #expect(result.hour == 16 && result.minute == 55 && result.second == 0)
    }

    @Test("AAF time: HH:mm:ss")
    func testTimeHMS() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseTime("22:30:12", recordNumber: 1, messages: &messages))
        #expect(result.hour == 22 && result.minute == 30 && result.second == 12)
    }

    @Test("AAF time: hour only")
    func testTimeHourOnly() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseTime("19", recordNumber: 1, messages: &messages))
        #expect(result.hour == 19 && result.minute == 0 && result.second == 0)
    }

    @Test("AAF time: 'h' separator form")
    func testTimeHSeparator() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseTime("22h30:12", recordNumber: 1, messages: &messages))
        #expect(result.hour == 22 && result.minute == 30 && result.second == 12)
    }

    // MARK: - Coordinates

    @Test("AAF coordinate: latitude with seconds")
    func testLatitudeWithSeconds() {
        var messages: [ExchangeMessage] = []
        let value = try! #require(AafFieldParsers.parseCoordinate("15s53:03", positiveChar: "n", negativeChar: "s", isLongitude: false, recordNumber: 1, field: "latitude", messages: &messages))
        #expect(value < 0)
        #expect(abs(abs(value) - (15.0 + 53.0/60.0 + 3.0/3600.0)) < 0.0001)
    }

    @Test("AAF coordinate: latitude without seconds")
    func testLatitudeWithoutSeconds() {
        var messages: [ExchangeMessage] = []
        let value = try! #require(AafFieldParsers.parseCoordinate("52n13", positiveChar: "n", negativeChar: "s", isLongitude: false, recordNumber: 1, field: "latitude", messages: &messages))
        #expect(value > 0)
    }

    @Test("AAF coordinate: longitude east/west")
    func testLongitudeDirections() {
        var messages: [ExchangeMessage] = []
        let east = try! #require(AafFieldParsers.parseCoordinate("6e54", positiveChar: "e", negativeChar: "w", isLongitude: true, recordNumber: 1, field: "longitude", messages: &messages))
        let west = try! #require(AafFieldParsers.parseCoordinate("74w54:45", positiveChar: "e", negativeChar: "w", isLongitude: true, recordNumber: 1, field: "longitude", messages: &messages))
        #expect(east > 0)
        #expect(west < 0)
    }

    // MARK: - Greenwich offset

    @Test("AAF Greenwich offset: '*' is unknown")
    func testGreenwichUnknown() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseGreenwichOffset("*", recordNumber: 1, messages: &messages))
        #expect(result == nil)
    }

    @Test("AAF Greenwich offset: '1he' is UTC+1")
    func testGreenwichEast() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseGreenwichOffset("1he", recordNumber: 1, messages: &messages))
        #expect(result == 3600)
    }

    @Test("AAF Greenwich offset: '5hw' is UTC-5")
    func testGreenwichWest() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseGreenwichOffset("5hw", recordNumber: 1, messages: &messages))
        #expect(result == -18000)
    }

    @Test("AAF Greenwich offset: '5he30' is UTC+5:30")
    func testGreenwichWithMinutes() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseGreenwichOffset("5he30", recordNumber: 1, messages: &messages))
        #expect(result == 5 * 3600 + 30 * 60)
    }

    @Test("AAF Greenwich offset: '0he32:06' includes seconds")
    func testGreenwichWithSeconds() {
        var messages: [ExchangeMessage] = []
        let result = try! #require(AafFieldParsers.parseGreenwichOffset("0he32:06", recordNumber: 1, messages: &messages))
        #expect(result == 32 * 60 + 6)
    }
}
