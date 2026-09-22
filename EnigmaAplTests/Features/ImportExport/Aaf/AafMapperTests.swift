// AafMapperTests.swift
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
    greenwichOffsetSeconds: Int? = 3600, timeType: String = "0"
) -> AafRecord {
    AafRecord(
        lastName: lastName, firstName: firstName, type: type,
        day: day, month: month, year: year, isGregorian: isGregorian,
        hour: hour, minute: minute, second: second,
        place: place, country: country,
        julianDayRaw: julianDayRaw, latitude: latitude, longitude: longitude,
        greenwichOffsetSeconds: greenwichOffsetSeconds, timeType: timeType
    )
}

struct AafMapperTests {

    private let seWrapper = SEWrapper()

    @Test("AafMapper: basic record (standard time, no DST) computes the correct UT Julian Day")
    func testBasicImport() {
        let (chart, messages) = AafMapper.toMappedChart(record: makeRecord(), recordNumber: 1, seWrapper: seWrapper)
        #expect(messages.isEmpty)
        #expect(chart.name == "Jan Kampherbeek")
        #expect(chart.placeName == "Enschede,NL")

        let expectedLocalJd = seWrapper.julianDay(
            date: AstronomicalDate(Year: 1953, Month: 1, Day: 29),
            time: AstronomicalTime(Hour: 8, Minute: 37, Second: 30)
        )
        let expectedUtJd = expectedLocalJd - 3600.0 / 86400.0
        #expect(abs(chart.julianDate - expectedUtJd) < 0.0000001)
    }

    @Test("AafMapper: time type '1' adds one hour of DST on top of the Greenwich offset")
    func testDaylightSavingTimeType() {
        let (chart, _) = AafMapper.toMappedChart(record: makeRecord(greenwichOffsetSeconds: 3600, timeType: "1"), recordNumber: 1, seWrapper: seWrapper)
        let (baseline, _) = AafMapper.toMappedChart(record: makeRecord(greenwichOffsetSeconds: 3600, timeType: "0"), recordNumber: 1, seWrapper: seWrapper)
        // DST record is UT one hour earlier than the standard-time baseline for the same clock time.
        #expect(abs((baseline.julianDate - chart.julianDate) - 1.0 / 24.0) < 0.0000001)
    }

    @Test("AafMapper: time type 'h' adds half an hour")
    func testHalfHourDaylight() {
        let (chart, _) = AafMapper.toMappedChart(record: makeRecord(greenwichOffsetSeconds: 0, timeType: "h"), recordNumber: 1, seWrapper: seWrapper)
        let (baseline, _) = AafMapper.toMappedChart(record: makeRecord(greenwichOffsetSeconds: 0, timeType: "0"), recordNumber: 1, seWrapper: seWrapper)
        #expect(abs((baseline.julianDate - chart.julianDate) - 0.5 / 24.0) < 0.0000001)
    }

    @Test("AafMapper: time type 'L' (LMT) derives the offset from longitude, ignoring the Greenwich field")
    func testLmtTimeType() {
        let (chart, messages) = AafMapper.toMappedChart(
            record: makeRecord(longitude: 6.9, greenwichOffsetSeconds: nil, timeType: "l"),
            recordNumber: 1, seWrapper: seWrapper
        )
        #expect(messages.isEmpty)
        let expectedOffsetSeconds = 6.9 / 15.0 * 3600.0
        let expectedLocalJd = seWrapper.julianDay(
            date: AstronomicalDate(Year: 1953, Month: 1, Day: 29),
            time: AstronomicalTime(Hour: 8, Minute: 37, Second: 30)
        )
        let expectedUtJd = expectedLocalJd - expectedOffsetSeconds / 86400.0
        #expect(abs(chart.julianDate - expectedUtJd) < 0.0000001)
    }

    @Test("AafMapper: time type 'm' uses the Greenwich offset when present")
    func testSpecialMeridianWithOffset() {
        let (chart, _) = AafMapper.toMappedChart(record: makeRecord(greenwichOffsetSeconds: 7200, timeType: "m"), recordNumber: 1, seWrapper: seWrapper)
        let (baseline, _) = AafMapper.toMappedChart(record: makeRecord(greenwichOffsetSeconds: 7200, timeType: "0"), recordNumber: 1, seWrapper: seWrapper)
        #expect(abs(chart.julianDate - baseline.julianDate) < 0.0000001)
    }

    @Test("AafMapper: UTC+5:30 (non-integer-hour offset) is computed correctly")
    func testHalfHourOffset() {
        let (chart, _) = AafMapper.toMappedChart(record: makeRecord(greenwichOffsetSeconds: 5 * 3600 + 30 * 60, timeType: "0"), recordNumber: 1, seWrapper: seWrapper)
        let (utc, _) = AafMapper.toMappedChart(record: makeRecord(greenwichOffsetSeconds: 0, timeType: "0"), recordNumber: 1, seWrapper: seWrapper)
        #expect(abs((utc.julianDate - chart.julianDate) - 5.5 / 24.0) < 0.0000001)
    }

    @Test("AafMapper: unknown Greenwich offset ('*') with a non-LMT time type is a fatal error")
    func testUnknownOffsetIsFatal() {
        let (_, messages) = AafMapper.toMappedChart(record: makeRecord(greenwichOffsetSeconds: nil, timeType: "0"), recordNumber: 1, seWrapper: seWrapper)
        #expect(messages.contains { $0.severity == .fatal })
    }

    @Test("AafMapper: gender type has no domain equivalent and is reported as a warning")
    func testGenderWarning() {
        let (chart, messages) = AafMapper.toMappedChart(record: makeRecord(type: "f"), recordNumber: 1, seWrapper: seWrapper)
        #expect(messages.contains { $0.severity == .warning && $0.field == "type" })
        #expect(chart.category.isEmpty)
    }

    @Test("AafMapper: type 'e'/'l'/'o' map to HoroscopeModel.category")
    func testTypeCategoryMapping() {
        #expect(AafMapper.toMappedChart(record: makeRecord(type: "e"), recordNumber: 1, seWrapper: seWrapper).chart.category == "event")
        #expect(AafMapper.toMappedChart(record: makeRecord(type: "l"), recordNumber: 1, seWrapper: seWrapper).chart.category == "country")
        #expect(AafMapper.toMappedChart(record: makeRecord(type: "o"), recordNumber: 1, seWrapper: seWrapper).chart.category == "organisation")
    }

    @Test("AafMapper: '*' names and country map to unknown/blank")
    func testUnknownFieldsMapToBlank() {
        let (chart, _) = AafMapper.toMappedChart(record: makeRecord(lastName: "*", firstName: "*", country: "*"), recordNumber: 1, seWrapper: seWrapper)
        #expect(chart.name.isEmpty)
        #expect(chart.placeName == "Enschede")
    }

    @Test("AafMapper: #VIA is appended into notes, #SRC maps to the existing source field")
    func testSourceAndViaMapping() {
        var record = makeRecord()
        record.source = "Birth certificate"
        record.via = "Astro-Databank"
        record.comment = "Some comment."
        let (chart, _) = AafMapper.toMappedChart(record: record, recordNumber: 1, seWrapper: seWrapper)
        #expect(chart.source == "Birth certificate")
        #expect(chart.notes == "Some comment.\nVia: Astro-Databank")
    }

    @Test("AafMapper: export warns when the chart's timezone identifier is not UTC")
    func testExportWarnsWhenNotUtc() {
        let (_, messages) = AafMapper.toRecord(
            id: UUID(), name: "Jan Kampherbeek", category: "", source: nil, notes: nil, placeName: nil,
            latitude: 0, longitude: 0, julianDate: 2451545.0, timeZoneIdentifier: "Europe/Amsterdam",
            recordNumber: 1, seWrapper: seWrapper
        )
        #expect(messages.contains { $0.severity == .warning && $0.field == "timezone" })
    }

    @Test("AafMapper: export sanitizes a comma in the place name and warns")
    func testExportSanitizesPlaceComma() {
        let (record, messages) = AafMapper.toRecord(
            id: UUID(), name: "Jane Doe", category: "", source: nil, notes: nil, placeName: "Staten Island, New York",
            latitude: 0, longitude: 0, julianDate: 2451545.0, timeZoneIdentifier: "UTC",
            recordNumber: 1, seWrapper: seWrapper
        )
        #expect(record.place == "Staten Island (New York)")
        #expect(record.country == "*")
        #expect(messages.contains { $0.severity == .warning && $0.field == "place" })
    }

    @Test("AafMapper: export splits 'First Last' into last/first name")
    func testExportNameSplit() {
        let (record, _) = AafMapper.toRecord(
            id: UUID(), name: "Jan Kampherbeek", category: "", source: nil, notes: nil, placeName: nil,
            latitude: 0, longitude: 0, julianDate: 2451545.0, timeZoneIdentifier: "UTC",
            recordNumber: 1, seWrapper: seWrapper
        )
        #expect(record.lastName == "Kampherbeek")
        #expect(record.firstName == "Jan")
    }

    @Test("AafMapper: export sets #ENID from the chart's id")
    func testExportSetsEnigmaId() {
        let id = UUID()
        let (record, _) = AafMapper.toRecord(
            id: id, name: "Jan Kampherbeek", category: "", source: nil, notes: nil, placeName: nil,
            latitude: 0, longitude: 0, julianDate: 2451545.0, timeZoneIdentifier: "UTC",
            recordNumber: 1, seWrapper: seWrapper
        )
        #expect(record.enigmaId == id)
    }

    @Test("AafMapper: import carries the #ENID value through as the chart's id")
    func testImportUsesEnigmaId() {
        let id = UUID()
        var record = makeRecord()
        record.enigmaId = id
        let (chart, _) = AafMapper.toMappedChart(record: record, recordNumber: 1, seWrapper: seWrapper)
        #expect(chart.id == id)
    }

    @Test("AafMapper: import without #ENID leaves the id nil")
    func testImportWithoutEnigmaId() {
        let (chart, _) = AafMapper.toMappedChart(record: makeRecord(), recordNumber: 1, seWrapper: seWrapper)
        #expect(chart.id == nil)
    }
}
