// AafWriterTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

private func makeRecord(
    lastName: String = "Kampherbeek", firstName: String = "Jan", type: String = "*",
    day: Int = 29, month: Int = 1, year: Int = 1953, isGregorian: Bool = true,
    hour: Int = 8, minute: Int = 37, second: Int = 30,
    place: String = "Enschede", country: String = "NL",
    julianDayRaw: String = "*", latitude: Double = 52.2166, longitude: Double = 6.9,
    greenwichOffsetSeconds: Int? = 3600, timeType: String = "0", enigmaId: UUID? = nil
) -> AafRecord {
    AafRecord(
        lastName: lastName, firstName: firstName, type: type,
        day: day, month: month, year: year, isGregorian: isGregorian,
        hour: hour, minute: minute, second: second,
        place: place, country: country,
        julianDayRaw: julianDayRaw, latitude: latitude, longitude: longitude,
        greenwichOffsetSeconds: greenwichOffsetSeconds, timeType: timeType,
        enigmaId: enigmaId
    )
}

struct AafWriterTests {

    @Test("AafWriter: writes #A93 and #B93 lines")
    func testBasicWrite() {
        let (text, messages) = AafWriter.write(record: makeRecord(), recordNumber: 1)
        #expect(messages.isEmpty)
        #expect(text.contains("#A93:Kampherbeek,Jan,*,29.1.1953g,08:37:30,Enschede,NL"))
        #expect(text.contains("#B93:*,52n13,6e54,1he,0"))
    }

    @Test("AafWriter: Julian calendar suffix is written for a Julian date")
    func testJulianSuffix() {
        let (text, _) = AafWriter.write(record: makeRecord(isGregorian: false), recordNumber: 1)
        #expect(text.contains("29.1.1953j"))
    }

    @Test("AafWriter: metadata chunks are written only when present")
    func testOptionalChunks() {
        var record = makeRecord()
        record.zoneName = "CET"
        record.source = "Birth certificate"
        record.comment = "A comment."
        let (text, _) = AafWriter.write(record: record, recordNumber: 1)
        #expect(text.contains("#ZNAM:CET"))
        #expect(text.contains("#SRC:Birth certificate"))
        #expect(text.contains("#COM:A comment."))
        #expect(!text.contains("#VIA:"))
    }

    @Test("AafWriter: #ENID is written when the record has an id, omitted otherwise")
    func testEnigmaIdChunk() {
        let id = UUID()
        let (withId, _) = AafWriter.write(record: makeRecord(enigmaId: id), recordNumber: 1)
        #expect(withId.contains("#ENID:\(id.uuidString)"))

        let (withoutId, _) = AafWriter.write(record: makeRecord(enigmaId: nil), recordNumber: 1)
        #expect(!withoutId.contains("#ENID"))
    }

    @Test("AafWriter: a stray comma in a field-based value is sanitized with a warning")
    func testCommaSanitizedInFieldValue() {
        let (text, messages) = AafWriter.write(record: makeRecord(place: "Staten Island, USA"), recordNumber: 1)
        #expect(!text.contains("Staten Island, USA"))
        #expect(text.contains("Staten Island  USA"))
        #expect(messages.contains { $0.severity == .warning && $0.field == "place" })
    }

    @Test("AafWriter: UTF-8 characters are preserved verbatim")
    func testUtf8Preserved() {
        let (text, _) = AafWriter.write(record: makeRecord(lastName: "Müller", firstName: "André", place: "Montréal"), recordNumber: 1)
        #expect(text.contains("Müller,André"))
        #expect(text.contains("Montréal"))
    }

    @Test("AafWriter + AafRecordParser round trip preserves date, time, coordinates, place and id")
    func testRoundTrip() {
        let original = makeRecord(enigmaId: UUID())
        let (text, writeMessages) = AafWriter.write(record: original, recordNumber: 1)
        #expect(writeMessages.isEmpty)

        let result = AafRecordParser.parse(content: text)
        #expect(result.fatalMessages.isEmpty)
        let reparsed = try! #require(result.records.first)

        #expect(reparsed.lastName == original.lastName && reparsed.firstName == original.firstName)
        #expect(reparsed.day == original.day && reparsed.month == original.month && reparsed.year == original.year)
        #expect(reparsed.isGregorian == original.isGregorian)
        #expect(reparsed.hour == original.hour && reparsed.minute == original.minute && reparsed.second == original.second)
        #expect(abs(reparsed.latitude - original.latitude) < 0.001)
        #expect(abs(reparsed.longitude - original.longitude) < 0.001)
        #expect(reparsed.greenwichOffsetSeconds == original.greenwichOffsetSeconds)
        #expect(reparsed.place == original.place && reparsed.country == original.country)
        #expect(reparsed.enigmaId == original.enigmaId)
    }
}
