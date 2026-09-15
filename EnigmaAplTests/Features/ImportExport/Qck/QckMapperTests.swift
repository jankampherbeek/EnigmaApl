// QckMapperTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct QckMapperTests {

    private let seWrapper = SEWrapper()

    @Test("QckMapper: import computes the correct UT Julian Day from local time and QCK correction")
    func testImportJulianDay() {
        let record = QckRecord(
            name: "JK", month: 1, day: 29, year: 1953,
            hour: 8, minute: 37, second: 30, isPM: false,
            timeZoneAbbreviation: "", qckCorrectionMinutes: -60,
            longitude: 6.9, latitude: 52.2166, place: "Enschede,Netherlands"
        )
        let (chart, messages) = QckMapper.toMappedChart(record: record, recordNumber: 1, seWrapper: seWrapper)
        #expect(messages.isEmpty)

        let expectedLocalJd = seWrapper.julianDay(
            date: AstronomicalDate(Year: 1953, Month: 1, Day: 29),
            time: AstronomicalTime(Hour: 8, Minute: 37, Second: 30)
        )
        let expectedUtJd = expectedLocalJd - Double(60) / 1440.0 // effective offset +60 min => UT = local - 60min
        #expect(abs(chart.julianDate - expectedUtJd) < 0.0000001)
        #expect(chart.name == "JK")
        #expect(chart.placeName == "Enschede,Netherlands")
    }

    @Test("QckMapper: import warns when a non-LMT timezone abbreviation is present")
    func testImportWarnsOnUnresolvedAbbreviation() {
        let record = QckRecord(
            name: "N", month: 6, day: 1, year: 2000,
            hour: 12, minute: 0, second: 0, isPM: true,
            timeZoneAbbreviation: "CET", qckCorrectionMinutes: -60,
            longitude: 0, latitude: 0, place: ""
        )
        let (_, messages) = QckMapper.toMappedChart(record: record, recordNumber: 1, seWrapper: seWrapper)
        #expect(messages.contains { $0.severity == .warning && $0.field == "timezone" })
    }

    @Test("QckMapper: export warns when the chart's timezone identifier is not UTC")
    func testExportWarnsWhenNotUtc() {
        let (_, messages) = QckMapper.toRecord(
            name: "N", placeName: nil, latitude: 0, longitude: 0,
            julianDate: 2451545.0, timeZoneIdentifier: "Europe/Amsterdam",
            recordNumber: 1, seWrapper: seWrapper
        )
        #expect(messages.contains { $0.severity == .warning && $0.field == "timezone" })
    }

    @Test("QckMapper: export does not warn when the chart's timezone identifier is UTC")
    func testExportNoWarningWhenUtc() {
        let (_, messages) = QckMapper.toRecord(
            name: "N", placeName: nil, latitude: 0, longitude: 0,
            julianDate: 2451545.0, timeZoneIdentifier: "UTC",
            recordNumber: 1, seWrapper: seWrapper
        )
        #expect(messages.isEmpty)
    }

    @Test("QckMapper: import -> export -> import preserves the represented instant (Julian Day)")
    func testRoundTripPreservesInstant() {
        let record = QckRecord(
            name: "JK", month: 1, day: 29, year: 1953,
            hour: 8, minute: 37, second: 30, isPM: false,
            timeZoneAbbreviation: "", qckCorrectionMinutes: -60,
            longitude: 6.9, latitude: 52.2166, place: "Enschede,Netherlands"
        )
        let (imported, _) = QckMapper.toMappedChart(record: record, recordNumber: 1, seWrapper: seWrapper)

        let (exportedRecord, _) = QckMapper.toRecord(
            name: imported.name, placeName: imported.placeName,
            latitude: imported.latitude, longitude: imported.longitude,
            julianDate: imported.julianDate, timeZoneIdentifier: "UTC",
            recordNumber: 1, seWrapper: seWrapper
        )
        let (reimported, _) = QckMapper.toMappedChart(record: exportedRecord, recordNumber: 1, seWrapper: seWrapper)

        #expect(abs(reimported.julianDate - imported.julianDate) < 0.0000001)
    }
}
