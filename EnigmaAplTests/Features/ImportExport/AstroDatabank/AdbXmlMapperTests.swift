// AdbXmlMapperTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

private func makeRecord(
    adbId: String? = "73001", name: String? = "Grayson, Larry", sflname: String? = "Larry Grayson",
    genderCode: String? = "u", roddenRating: String? = "AA",
    hasDate: Bool = true, isGregorian: Bool = true, year: Int = 1953, month: Int = 1, day: Int = 29,
    hasTime: Bool = true, hour: Int = 8, minute: Int = 37, second: Int = 30,
    timeTypeCode: String? = "s", stmerid: String? = "h1e", jdUt: Double? = nil,
    placeName: String? = "Enschede", latitude: Double? = 52.2166, longitude: Double? = 6.9,
    countryName: String? = "Netherlands", countryCode: String? = "NL",
    sourceNotes: String? = nil, hasAlternativeBirthData: Bool = false
) -> AdbXmlRecord {
    AdbXmlRecord(
        adbId: adbId, name: name, sflname: sflname, birthname: nil,
        genderCode: genderCode, roddenRating: roddenRating,
        hasDate: hasDate, isGregorian: isGregorian, year: year, month: month, day: day,
        hasTime: hasTime, hour: hour, minute: minute, second: second,
        timeTypeCode: timeTypeCode, stmerid: stmerid, jdUt: jdUt,
        placeName: placeName, latitude: latitude, longitude: longitude,
        countryName: countryName, countryCode: countryCode,
        sourceNotes: sourceNotes, hasAlternativeBirthData: hasAlternativeBirthData
    )
}

struct AdbXmlMapperTests {

    private let seWrapper = SEWrapper()

    @Test("AdbXmlMapper: prefers sflname, falls back to name")
    func testNameResolution() {
        let withSflname = AdbXmlMapper.toMappedChart(record: makeRecord(), recordNumber: 1, seWrapper: seWrapper).chart
        #expect(withSflname.name == "Larry Grayson")

        let withoutSflname = AdbXmlMapper.toMappedChart(record: makeRecord(sflname: nil), recordNumber: 1, seWrapper: seWrapper).chart
        #expect(withoutSflname.name == "Grayson, Larry")
    }

    @Test("AdbXmlMapper: standard time computes the correct UT Julian Day")
    func testStandardTimeJulianDay() {
        let (chart, messages) = AdbXmlMapper.toMappedChart(record: makeRecord(), recordNumber: 1, seWrapper: seWrapper)
        #expect(messages.isEmpty)
        let expectedLocal = seWrapper.julianDay(date: AstronomicalDate(Year: 1953, Month: 1, Day: 29), time: AstronomicalTime(Hour: 8, Minute: 37, Second: 30))
        #expect(abs(chart.julianDate - (expectedLocal - 3600.0/86400.0)) < 0.0000001)
        #expect(!chart.timeIsUnknown)
    }

    @Test("AdbXmlMapper: missing birth time uses noon UT with timeIsUnknown")
    func testMissingTimeUsesNoon() {
        let (chart, _) = AdbXmlMapper.toMappedChart(record: makeRecord(hasTime: false), recordNumber: 1, seWrapper: seWrapper)
        #expect(chart.timeIsUnknown)
        let noonJd = seWrapper.julianDay(date: AstronomicalDate(Year: 1953, Month: 1, Day: 29), time: AstronomicalTime(Hour: 12, Minute: 0, Second: 0))
        #expect(abs(chart.julianDate - noonJd) < 0.0000001)
    }

    @Test("AdbXmlMapper: LMT (ctimetype 'l') derives the offset from longitude")
    func testLmt() {
        let (chart, _) = AdbXmlMapper.toMappedChart(record: makeRecord(timeTypeCode: "l", stmerid: nil, longitude: 6.9), recordNumber: 1, seWrapper: seWrapper)
        let expectedOffset = 6.9 / 15.0 * 3600.0
        let expectedLocal = seWrapper.julianDay(date: AstronomicalDate(Year: 1953, Month: 1, Day: 29), time: AstronomicalTime(Hour: 8, Minute: 37, Second: 30))
        #expect(abs(chart.julianDate - (expectedLocal - expectedOffset/86400.0)) < 0.0000001)
    }

    @Test("AdbXmlMapper: daylight saving ('d') adds one hour")
    func testDaylightSaving() {
        let (dst, _) = AdbXmlMapper.toMappedChart(record: makeRecord(timeTypeCode: "d"), recordNumber: 1, seWrapper: seWrapper)
        let (standard, _) = AdbXmlMapper.toMappedChart(record: makeRecord(timeTypeCode: "s"), recordNumber: 1, seWrapper: seWrapper)
        #expect(abs((standard.julianDate - dst.julianDate) - 1.0/24.0) < 0.0000001)
    }

    @Test("AdbXmlMapper: missing stmerid falls back to UTC with a warning")
    func testMissingStmeridFallsBackToUtc() {
        let (_, messages) = AdbXmlMapper.toMappedChart(record: makeRecord(timeTypeCode: "s", stmerid: nil), recordNumber: 1, seWrapper: seWrapper)
        #expect(messages.contains { $0.severity == .warning && $0.field == "stmerid" })
    }

    @Test("AdbXmlMapper: known Rodden rating maps to its canonical rawValue")
    func testKnownRoddenRating() {
        let (chart, messages) = AdbXmlMapper.toMappedChart(record: makeRecord(roddenRating: "dd"), recordNumber: 1, seWrapper: seWrapper)
        #expect(chart.roddenRating == "DD")
        #expect(messages.isEmpty)
    }

    @Test("AdbXmlMapper: unknown Rodden rating is kept as-is with a warning")
    func testUnknownRoddenRating() {
        let (chart, messages) = AdbXmlMapper.toMappedChart(record: makeRecord(roddenRating: "AB"), recordNumber: 1, seWrapper: seWrapper)
        #expect(chart.roddenRating == "AB")
        #expect(messages.contains { $0.severity == .warning && $0.field == "roddenrating" })
    }

    @Test("AdbXmlMapper: gender 'e' maps to category 'event', 'm'/'f' are reported as a warning")
    func testGenderMapping() {
        #expect(AdbXmlMapper.toMappedChart(record: makeRecord(genderCode: "e"), recordNumber: 1, seWrapper: seWrapper).chart.category == "event")
        let (_, messages) = AdbXmlMapper.toMappedChart(record: makeRecord(genderCode: "f"), recordNumber: 1, seWrapper: seWrapper)
        #expect(messages.contains { $0.field == "gender" })
    }

    @Test("AdbXmlMapper: place and country are merged, adb_id and sourcenotes go into notes")
    func testPlaceAndNotes() {
        let (chart, _) = AdbXmlMapper.toMappedChart(record: makeRecord(sourceNotes: "Birth certificate."), recordNumber: 1, seWrapper: seWrapper)
        #expect(chart.placeName == "Enschede,Netherlands")
        #expect(chart.notes == "Birth certificate.\nAstro-Databank ID: 73001")
    }

    @Test("AdbXmlMapper: bdata_alt presence produced a warning from the parser (mapper does not re-derive it)")
    func testAlternativeBirthDataFlagIsJustCarriedThrough() {
        let (_, messages) = AdbXmlMapper.toMappedChart(record: makeRecord(hasAlternativeBirthData: true), recordNumber: 1, seWrapper: seWrapper)
        // The parser (not the mapper) emits the bdata_alt warning; the mapper itself adds none for it.
        #expect(!messages.contains { $0.field == "bdata_alt" })
    }
}
