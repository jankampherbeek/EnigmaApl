// QckWriterTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

private func sampleRecord(
    name: String = "Test",
    month: Int = 1, day: Int = 29, year: Int = 1953,
    hour: Int = 8, minute: Int = 37, second: Int = 30,
    tz: String = "", correctionMinutes: Int = -60,
    longitude: Double = 6.9, latitude: Double = 52.2166,
    place: String = "Enschede,Netherlands"
) -> QckRecord {
    QckRecord(
        name: name, month: month, day: day, year: year,
        hour: hour, minute: minute, second: second, isPM: hour >= 12,
        timeZoneAbbreviation: tz, qckCorrectionMinutes: correctionMinutes,
        longitude: longitude, latitude: latitude, place: place
    )
}

struct QckWriterTests {

    @Test("QCK writer: produces exactly 100 characters")
    func testLineLength() {
        let (line, _) = QckWriter.write(record: sampleRecord(), recordNumber: 1)
        #expect(try! #require(line).count == 100)
    }

    @Test("QCK writer: normal 12-hour time notation, never the historical noon bug")
    func testNormalTimeNotation() {
        let (line, _) = QckWriter.write(record: sampleRecord(hour: 0, minute: 0, second: 0), recordNumber: 1)
        let text = try! #require(line)
        #expect(text.contains("12:00:00 AM"))
    }

    @Test("QCK writer: noon writes 12:00:00 PM")
    func testNoon() {
        let (line, _) = QckWriter.write(record: sampleRecord(hour: 12, minute: 0, second: 0), recordNumber: 1)
        #expect(try! #require(line).contains("12:00:00 PM"))
    }

    // 10. Name longer than 23 -> truncation warning.
    @Test("QCK writer: name longer than 23 characters is truncated with a warning")
    func testNameTruncation() {
        let longName = String(repeating: "N", count: 30)
        let (line, messages) = QckWriter.write(record: sampleRecord(name: longName), recordNumber: 1)
        let text = try! #require(line)
        #expect(String(text.prefix(23)) == String(longName.prefix(23)))
        #expect(messages.contains { $0.severity == .warning && $0.field == "name" })
    }

    // 12. Place longer than 25 -> truncation warning.
    @Test("QCK writer: place longer than 25 characters is truncated with a warning")
    func testPlaceTruncation() {
        let longPlace = "Staten Island,United States"
        #expect(longPlace.count > 25)
        let (line, messages) = QckWriter.write(record: sampleRecord(place: longPlace), recordNumber: 1)
        let text = try! #require(line)
        let placeField = String(text[text.index(text.startIndex, offsetBy: 75)...])
        #expect(placeField.trimmingCharacters(in: .whitespaces) == String(longPlace.prefix(25)))
        #expect(messages.contains { $0.severity == .warning && $0.field == "place" })
    }

    @Test("QCK writer: name and place exactly at their width produce no truncation warning")
    func testExactWidthNoWarning() {
        let name23 = String(repeating: "A", count: 23)
        let place25 = String(repeating: "B", count: 25)
        let (_, messages) = QckWriter.write(record: sampleRecord(name: name23, place: place25), recordNumber: 1)
        #expect(messages.isEmpty)
    }

    @Test("QCK writer: year outside QCK's range is a fatal error, record is skipped")
    func testYearOutOfRange() {
        let (line, messages) = QckWriter.write(record: sampleRecord(year: 200_000), recordNumber: 1)
        #expect(line == nil)
        #expect(messages.contains { $0.severity == .fatal })
    }

    @Test("QCK writer + parser round trip preserves name, place, date, time and coordinates")
    func testRoundTrip() {
        let original = sampleRecord(tz: "CET", correctionMinutes: -60)
        let (line, writeMessages) = QckWriter.write(record: original, recordNumber: 1)
        #expect(writeMessages.isEmpty)
        let (reparsed, parseMessages) = QckLineParser.parse(line: try! #require(line), recordNumber: 1)
        #expect(parseMessages.isEmpty)
        let record = try! #require(reparsed)
        #expect(record.name.trimmingCharacters(in: .whitespaces) == original.name)
        #expect(record.month == original.month && record.day == original.day && record.year == original.year)
        #expect(record.hour == original.hour && record.minute == original.minute && record.second == original.second)
        #expect(abs(record.longitude - original.longitude) < 0.001)
        #expect(abs(record.latitude - original.latitude) < 0.001)
        #expect(record.place.trimmingCharacters(in: .whitespaces) == original.place)
        #expect(record.timeZoneAbbreviation == original.timeZoneAbbreviation)
        #expect(record.effectiveUtcOffsetMinutes == original.effectiveUtcOffsetMinutes)
    }
}
