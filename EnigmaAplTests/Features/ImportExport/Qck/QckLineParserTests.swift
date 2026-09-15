// QckLineParserTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

/// Builds a raw 100-character QCK line with full control over every field,
/// including combinations `QckWriter` would never itself produce (used for
/// negative tests such as out-of-range coordinates).
private func rawLine(
    name: String = "JK",
    month: String = "JAN",
    day: String = " 29",
    year: String = " 1953",
    time: String = "08:37:30 AM ",
    tz: String = "   ",
    correction: String = "-01:00",
    lonCore: String = "006E54'00",
    latCore: String = "52N13'00",
    place: String = "Enschede,Netherlands"
) -> String {
    let n = name.padding(toLength: 23, withPad: " ", startingAt: 0)
    let lon = lonCore.padding(toLength: 9, withPad: " ", startingAt: 0) + " "
    let lat = latCore.padding(toLength: 8, withPad: " ", startingAt: 0) + " "
    let p = place.padding(toLength: 25, withPad: " ", startingAt: 0)
    return n + month + day + "," + year + time + tz + correction + lon + lat + p
}

struct QckLineParserTests {

    // 1. Exact 100-position record (regression fixture from the spec).
    @Test("QCK: regression fixture parses with expected fields")
    func testRegressionFixture() {
        let line = "JK                     JAN 29, 195308:37:30 AM    -01:00006E54'00 52N13'00 Enschede,Netherlands     "
        #expect(line.count == 100)
        let (record, messages) = QckLineParser.parse(line: line, recordNumber: 1)
        let record0 = try! #require(record)
        #expect(messages.isEmpty)
        #expect(record0.year == 1953 && record0.month == 1 && record0.day == 29)
        #expect(record0.hour == 8 && record0.minute == 37 && record0.second == 30)
        #expect(record0.effectiveUtcOffsetMinutes == 60)
        #expect(abs(record0.longitude - (6.0 + 54.0/60.0)) < 0.0001)
        #expect(abs(record0.latitude - (52.0 + 13.0/60.0)) < 0.0001)
        #expect(record0.place == "Enschede,Netherlands")
    }

    // 2. 101-position record with trailing space.
    @Test("QCK: 101-character record with trailing space parses identically")
    func test101CharacterRecord() {
        let line = "JK                     JAN 29, 195308:37:30 AM    -01:00006E54'00 52N13'00 Enschede,Netherlands     " + " "
        #expect(line.count == 101)
        let (record, messages) = QckLineParser.parse(line: line, recordNumber: 1)
        #expect(try! #require(record).place == "Enschede,Netherlands")
        #expect(messages.isEmpty)
    }

    // 3. CET.
    @Test("QCK: CET correction maps to UTC+1")
    func testCET() {
        let line = rawLine(tz: "CET", correction: "-01:00")
        let (record, _) = QckLineParser.parse(line: line, recordNumber: 1)
        #expect(try! #require(record).effectiveUtcOffsetMinutes == 60)
    }

    // 4. American western timezone (PST).
    @Test("QCK: PST correction maps to UTC-8")
    func testPST() {
        let line = rawLine(tz: "PST", correction: "+08:00")
        let (record, _) = QckLineParser.parse(line: line, recordNumber: 1)
        #expect(try! #require(record).effectiveUtcOffsetMinutes == -480)
    }

    // 5. DST zone code EDT/PDT.
    @Test("QCK: DST zone codes are flagged informationally, offset stays authoritative")
    func testDstZoneCode() {
        let line = rawLine(tz: "EDT", correction: "+04:00")
        let (record, _) = QckLineParser.parse(line: line, recordNumber: 1)
        let record0 = try! #require(record)
        #expect(record0.indicatesDaylightOrWarTime)
        #expect(record0.effectiveUtcOffsetMinutes == -240)
    }

    // 6. LMT.
    @Test("QCK: LMT is recognized and roughly matches longitude/15")
    func testLmt() {
        let line = rawLine(tz: "LMT", correction: "-00:23", lonCore: "005E47'00")
        let (record, messages) = QckLineParser.parse(line: line, recordNumber: 1)
        let record0 = try! #require(record)
        #expect(record0.isLmt)
        #expect(messages.isEmpty)
    }

    @Test("QCK: LMT with a correction far from longitude/15 is only a warning")
    func testLmtMismatchIsWarningNotFatal() {
        // Longitude 5E47 => ~23 minutes east; correction below is off by hours.
        let line = rawLine(tz: "LMT", correction: "-03:00", lonCore: "005E47'00")
        let (record, messages) = QckLineParser.parse(line: line, recordNumber: 1)
        #expect(record != nil)
        #expect(messages.allSatisfy { $0.severity != .fatal })
    }

    // 7. Latitude North/South.
    @Test("QCK: latitude North is positive, South is negative")
    func testLatitudeDirections() {
        let north = QckLineParser.parse(line: rawLine(latCore: "52N13'00"), recordNumber: 1).record
        let south = QckLineParser.parse(line: rawLine(latCore: "33S52'00"), recordNumber: 1).record
        #expect(try! #require(north).latitude > 0)
        #expect(try! #require(south).latitude < 0)
    }

    // 8. Longitude East/West.
    @Test("QCK: longitude East is positive, West is negative")
    func testLongitudeDirections() {
        let east = QckLineParser.parse(line: rawLine(lonCore: "006E54'00"), recordNumber: 1).record
        let west = QckLineParser.parse(line: rawLine(lonCore: "073W52'00"), recordNumber: 1).record
        #expect(try! #require(east).longitude > 0)
        #expect(try! #require(west).longitude < 0)
    }

    // 9. Name exact 23 positions.
    @Test("QCK: name of exactly 23 characters is preserved")
    func testNameExact23() {
        let name = "ABCDEFGHIJKLMNOPQRSTUV" // 22 chars
        let fullName = name + "W" // 23 chars, no trailing space to strip
        #expect(fullName.count == 23)
        let (record, _) = QckLineParser.parse(line: rawLine(name: fullName), recordNumber: 1)
        #expect(try! #require(record).name == fullName)
    }

    // 11. Place exact 25 positions.
    @Test("QCK: place of exactly 25 characters is preserved")
    func testPlaceExact25() {
        let place = String(repeating: "X", count: 24) + "Y"
        #expect(place.count == 25)
        let (record, _) = QckLineParser.parse(line: rawLine(place: place), recordNumber: 1)
        #expect(try! #require(record).place == place)
    }

    // 13. Historical date.
    @Test("QCK: pre-Gregorian-cutover date parses with a calendar-ambiguity warning")
    func testHistoricalDate() {
        let line = rawLine(month: "MAR", day: "  1", year: "  800")
        let (record, messages) = QckLineParser.parse(line: line, recordNumber: 1)
        let record0 = try! #require(record)
        #expect(record0.year == 800)
        #expect(messages.contains { $0.severity == .warning && $0.field == "date" })
    }

    @Test("QCK: negative (BCE-range) year is accepted")
    func testNegativeYear() {
        let line = rawLine(month: "JUN", day: " 15", year: "-0100")
        let (record, _) = QckLineParser.parse(line: line, recordNumber: 1)
        #expect(try! #require(record).year == -100)
    }

    // 14. Invalid record length.
    @Test("QCK: invalid record length is a fatal error")
    func testInvalidRecordLength() {
        let line = String(repeating: "X", count: 90)
        let (record, messages) = QckLineParser.parse(line: line, recordNumber: 1)
        #expect(record == nil)
        #expect(messages.contains { $0.severity == .fatal })
    }

    // 15. Invalid longitude/latitude.
    @Test("QCK: out-of-range longitude is a fatal error")
    func testInvalidLongitude() {
        let line = rawLine(lonCore: "200E54'00")
        let (record, messages) = QckLineParser.parse(line: line, recordNumber: 1)
        #expect(record == nil)
        #expect(messages.contains { $0.severity == .fatal && $0.field == "longitude" })
    }

    @Test("QCK: out-of-range latitude is a fatal error")
    func testInvalidLatitude() {
        let line = rawLine(latCore: "95N13'00")
        let (record, messages) = QckLineParser.parse(line: line, recordNumber: 1)
        #expect(record == nil)
        #expect(messages.contains { $0.severity == .fatal && $0.field == "latitude" })
    }

    @Test("QCK: invalid longitude direction letter is a fatal error")
    func testInvalidLongitudeDirection() {
        let line = rawLine(lonCore: "006X54'00")
        let (record, messages) = QckLineParser.parse(line: line, recordNumber: 1)
        #expect(record == nil)
        #expect(messages.contains { $0.severity == .fatal })
    }

    @Test("QCK: unrecognized month abbreviation is a fatal error")
    func testInvalidMonth() {
        let line = rawLine(month: "XXX")
        let (record, messages) = QckLineParser.parse(line: line, recordNumber: 1)
        #expect(record == nil)
        #expect(messages.contains { $0.severity == .fatal && $0.field == "month" })
    }

    @Test("QCK: historical '00:mm:ss PM' time is tolerated as 12:mm:ss PM")
    func testHistoricalNoonBug() {
        let line = rawLine(time: "00:00:00 PM ")
        let (record, messages) = QckLineParser.parse(line: line, recordNumber: 1)
        let record0 = try! #require(record)
        #expect(record0.hour == 12 && record0.minute == 0)
        #expect(messages.contains { $0.severity == .warning && $0.field == "time" })
    }
}
