// AdbXmlParserTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

private func entry(
    adbId: String = "73001",
    name: String = "Grayson, Larry",
    sflname: String? = "Larry Grayson",
    gender: String = "m",
    rating: String = "AA",
    calendar: String = "g",
    year: Int = 1953, month: Int = 1, day: Int = 29,
    time: String? = "08:37:30", ctimetype: String = "s", stmerid: String? = "h1e", jdUt: String? = nil,
    lat: String = "52n13", lon: String = "6e54",
    country: String = "Netherlands",
    extra: String = ""
) -> String {
    let sflnameTag = sflname.map { "<sflname>\($0)</sflname>" } ?? ""
    let timeTag = time.map { "<sbtime ctimetype=\"\(ctimetype)\" stmerid=\"\(stmerid ?? "")\"\(jdUt.map { " jd_ut=\"\($0)\"" } ?? "")>\($0)</sbtime>" } ?? ""
    return """
    <adb_entry adb_id="\(adbId)">
      <public_data>
        <name>\(name)</name>
        \(sflnameTag)
        <gender csex="\(gender)">M</gender>
        <roddenrating rrc="1">\(rating)</roddenrating>
        <sbdate ccalendar="\(calendar)" iyear="\(year)" imonth="\(month)" iday="\(day)">\(year)/\(month)/\(day)</sbdate>
        \(timeTag)
        <place slati="\(lat)" slong="\(lon)">City</place>
        <country sctr="NL">\(country)</country>
        \(extra)
      </public_data>
    </adb_entry>
    """
}

private func wrap(_ entries: [String], format: String = "160715", countAttribute: Int? = nil) -> String {
    let countTag = countAttribute.map { "<adb_entry_count count=\"\($0)\"/>" } ?? ""
    return """
    <?xml version="1.0" encoding="UTF-8"?>
    <astrodatabank_export export_format="\(format)">
      <timestamp>2020-01-01</timestamp>
      \(entries.joined(separator: "\n"))
      \(countTag)
    </astrodatabank_export>
    """
}

struct AdbXmlParserTests {

    @Test("ADB: correct root and version parses without a version warning")
    func testRootAndVersion() {
        let result = AdbXmlParser.parse(data: Data(wrap([entry()]).utf8))
        #expect(result.fatalMessages.isEmpty)
        #expect(!result.warningMessages.contains { $0.message.contains("export_format") })
    }

    @Test("ADB: newer/unknown export_format is tolerated with a warning")
    func testUnknownFormatVersion() {
        let result = AdbXmlParser.parse(data: Data(wrap([entry()], format: "999999").utf8))
        #expect(!result.records.isEmpty)
        #expect(result.warningMessages.contains { $0.message.contains("export_format") })
    }

    @Test("ADB: multiple adb_entry elements all parse")
    func testMultipleEntries() {
        let result = AdbXmlParser.parse(data: Data(wrap([entry(adbId: "1"), entry(adbId: "2")]).utf8))
        #expect(result.records.count == 2)
    }

    @Test("ADB: Gregorian calendar")
    func testGregorian() {
        let record = AdbXmlParser.parse(data: Data(wrap([entry(calendar: "g")]).utf8)).records.first!
        #expect(record.isGregorian)
    }

    @Test("ADB: Julian calendar")
    func testJulian() {
        let record = AdbXmlParser.parse(data: Data(wrap([entry(calendar: "j")]).utf8)).records.first!
        #expect(!record.isGregorian)
    }

    @Test("ADB: BCE astronomical year numbering is used directly")
    func testBceYear() {
        let record = AdbXmlParser.parse(data: Data(wrap([entry(year: -6, month: 12, day: 24)]).utf8)).records.first!
        #expect(record.year == -6)
    }

    @Test("ADB: seconds in birth time")
    func testSecondsInTime() {
        let record = AdbXmlParser.parse(data: Data(wrap([entry(time: "08:37:45")]).utf8)).records.first!
        #expect(record.second == 45)
    }

    @Test("ADB: standard time (ctimetype 's')")
    func testStandardTime() {
        let record = AdbXmlParser.parse(data: Data(wrap([entry(ctimetype: "s")]).utf8)).records.first!
        #expect(record.timeTypeCode == "s")
    }

    @Test("ADB: daylight saving time (ctimetype 'd')")
    func testDaylightSavingTime() {
        let record = AdbXmlParser.parse(data: Data(wrap([entry(ctimetype: "d")]).utf8)).records.first!
        #expect(record.timeTypeCode == "d")
    }

    @Test("ADB: LMT (ctimetype 'l')")
    func testLmt() {
        let record = AdbXmlParser.parse(data: Data(wrap([entry(ctimetype: "l", stmerid: nil)]).utf8)).records.first!
        #expect(record.timeTypeCode == "l")
    }

    @Test("ADB: east/west stmerid")
    func testStmeridDirections() {
        let east = AdbXmlParser.parse(data: Data(wrap([entry(stmerid: "h1e")]).utf8)).records.first!
        let west = AdbXmlParser.parse(data: Data(wrap([entry(stmerid: "h5w")]).utf8)).records.first!
        #expect(east.stmerid == "h1e")
        #expect(west.stmerid == "h5w")
    }

    @Test("ADB: latitude/longitude are parsed from place attributes")
    func testLatLon() {
        let record = AdbXmlParser.parse(data: Data(wrap([entry(lat: "52n13", lon: "6e54")]).utf8)).records.first!
        #expect(try! #require(record.latitude) > 0)
        #expect(try! #require(record.longitude) > 0)
    }

    @Test("ADB: Rodden rating is captured")
    func testRoddenRating() {
        let record = AdbXmlParser.parse(data: Data(wrap([entry(rating: "DD")]).utf8)).records.first!
        #expect(record.roddenRating == "DD")
    }

    @Test("ADB: UTF-8 names are preserved")
    func testUtf8() {
        let record = AdbXmlParser.parse(data: Data(wrap([entry(name: "Müller, André", sflname: "André Müller")]).utf8)).records.first!
        #expect(record.sflname == "André Müller")
    }

    @Test("ADB: missing optional elements (no sflname, no time) do not fail the entry")
    func testMissingOptionalElements() {
        let result = AdbXmlParser.parse(data: Data(wrap([entry(sflname: nil, time: nil)]).utf8))
        #expect(result.fatalMessages.isEmpty)
        let record = try! #require(result.records.first)
        #expect(record.sflname == nil)
        #expect(!record.hasTime)
    }

    @Test("ADB: bdata_alt is detected but its contents are not imported")
    func testBdataAlt() {
        let extra = """
        <bdata_alt>
          <sbdate ccalendar="g" iyear="1900" imonth="1" iday="1">1900/1/1</sbdate>
        </bdata_alt>
        """
        let result = AdbXmlParser.parse(data: Data(wrap([entry(extra: extra)]).utf8))
        let record = try! #require(result.records.first)
        #expect(record.hasAlternativeBirthData)
        #expect(record.year == 1953) // primary date unaffected by the alt block
        #expect(result.warningMessages.contains { $0.field == "bdata_alt" })
    }

    @Test("ADB: unknown XML elements are ignored, not fatal")
    func testUnknownElement() {
        let extra = "<somenewfield>value</somenewfield>"
        let result = AdbXmlParser.parse(data: Data(wrap([entry(extra: extra)]).utf8))
        #expect(result.fatalMessages.isEmpty)
        #expect(result.records.count == 1)
        #expect(result.warningMessages.contains { $0.message.contains("somenewfield") })
    }

    @Test("ADB: adb_entry_count mismatch is a warning, not fatal")
    func testEntryCountMismatch() {
        let result = AdbXmlParser.parse(data: Data(wrap([entry()], countAttribute: 5).utf8))
        #expect(result.fatalMessages.isEmpty)
        #expect(result.warningMessages.contains { $0.message.contains("adb_entry_count") })
    }

    @Test("ADB: malformed XML is a fatal error")
    func testMalformedXml() {
        let result = AdbXmlParser.parse(data: Data("<astrodatabank_export><adb_entry>".utf8))
        #expect(!result.fatalMessages.isEmpty)
    }

    @Test("ADB: wrong root element is a fatal error")
    func testWrongRoot() {
        let result = AdbXmlParser.parse(data: Data("<not_astrodatabank></not_astrodatabank>".utf8))
        #expect(!result.fatalMessages.isEmpty)
    }

    @Test("ADB: external entities are never resolved (XXE protection)")
    func testExternalEntitiesNotResolved() {
        let malicious = """
        <?xml version="1.0"?>
        <!DOCTYPE astrodatabank_export [
          <!ENTITY xxe SYSTEM "file:///etc/passwd">
        ]>
        <astrodatabank_export export_format="160715">
          \(entry(extra: "<sourcenotes>&xxe;</sourcenotes>"))
        </astrodatabank_export>
        """
        let result = AdbXmlParser.parse(data: Data(malicious.utf8))
        // Either the entity is left unresolved/blocked, or parsing fails outright — either is safe.
        // The critical property is that /etc/passwd content is never present in the output.
        let allText = (result.records.first?.sourceNotes ?? "") + result.messages.map(\.message).joined()
        #expect(!allText.contains("root:"))
    }
}
