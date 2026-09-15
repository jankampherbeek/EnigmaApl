// AafRecordParserTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct AafRecordParserTests {

    @Test("AAF: basic record from the format spec parses correctly")
    func testBasicRecord() {
        let content = """
        #: Enigma AAF export
        #A93:Kampherbeek,Jan,*,29.1.1953,08:37:30,Enschede,NL
        #B93:*,52n13,6e54,1he,0
        #ZNAM:CET
        #: AAF end
        """
        let result = AafRecordParser.parse(content: content)
        #expect(result.fatalMessages.isEmpty)
        let record = try! #require(result.records.first)
        #expect(record.lastName == "Kampherbeek" && record.firstName == "Jan")
        #expect(record.day == 29 && record.month == 1 && record.year == 1953)
        #expect(record.hour == 8 && record.minute == 37 && record.second == 30)
        #expect(record.place == "Enschede" && record.country == "NL")
        #expect(record.greenwichOffsetSeconds == 3600)
        #expect(record.timeType == "0")
        #expect(record.zoneName == "CET")
    }

    @Test("AAF: unknown chunk is ignored, not fatal")
    func testUnknownChunkIsIgnored() {
        let content = """
        #A93:Doe,Jane,*,1.1.2000,12:00,City,US
        #B93:*,0n00,0e00,0he,0
        #LPOS:some data here
        """
        let result = AafRecordParser.parse(content: content)
        #expect(result.records.count == 1)
        #expect(result.fatalMessages.isEmpty)
        #expect(result.warningMessages.contains { $0.message.contains("LPOS") })
    }

    @Test("AAF: #SRC/#VIA/#COM allow commas since they are free text")
    func testFreeTextChunksAllowCommas() {
        let content = """
        #A93:Doe,Jane,*,1.1.2000,12:00,City,US
        #B93:*,0n00,0e00,0he,0
        #SRC:Birth certificate, county registry
        #VIA:Astro-Databank, via research
        #COM:Additional comments, with punctuation.
        """
        let record = AafRecordParser.parse(content: content).records.first!
        #expect(record.source == "Birth certificate, county registry")
        #expect(record.via == "Astro-Databank, via research")
        #expect(record.comment == "Additional comments, with punctuation.")
    }

    @Test("AAF: multiple records in one file")
    func testMultipleRecords() {
        let content = """
        #A93:Doe,Jane,*,1.1.2000,12:00,City,US
        #B93:*,0n00,0e00,0he,0
        #A93:Roe,Richard,*,2.2.2001,13:00,Town,US
        #B93:*,1n00,1e00,1he,0
        """
        let result = AafRecordParser.parse(content: content)
        #expect(result.records.count == 2)
        #expect(result.records[0].lastName == "Doe")
        #expect(result.records[1].lastName == "Roe")
    }

    @Test("AAF: UTF-8 names are preserved (Montréal, Málaga, Osnabrück)")
    func testUtf8Names() {
        let content = """
        #A93:Müller,André,*,1.1.2000,12:00,Montréal,CA
        #B93:*,45n30,73w34,5hw,0
        #COM:Born near Málaga, moved to Osnabrück.
        """
        let record = AafRecordParser.parse(content: content).records.first!
        #expect(record.lastName == "Müller" && record.firstName == "André")
        #expect(record.place == "Montréal")
        #expect(record.comment == "Born near Málaga, moved to Osnabrück.")
    }

    @Test("AAF: a fatal error in one record does not abort the remaining records")
    func testFatalRecordDoesNotAbortFile() {
        let content = """
        #A93:Doe,Jane,*,1.1.2000,12:00,City,US
        #B93:*,0n00,0e00,0he,0
        #A93:Broken,Record,*,not-a-date,12:00,City,US
        #B93:*,0n00,0e00,0he,0
        #A93:Roe,Richard,*,2.2.2001,13:00,Town,US
        #B93:*,1n00,1e00,1he,0
        """
        let result = AafRecordParser.parse(content: content)
        #expect(result.records.count == 2)
        #expect(result.fatalMessages.count == 1)
    }

    @Test("AAF: missing #B93 chunk is a fatal error for that record")
    func testMissingB93() {
        let content = "#A93:Doe,Jane,*,1.1.2000,12:00,City,US"
        let result = AafRecordParser.parse(content: content)
        #expect(result.records.isEmpty)
        #expect(result.fatalMessages.count == 1)
    }

    @Test("AAF: wrong number of #A93 fields is a fatal error")
    func testWrongFieldCount() {
        let content = "#A93:Doe,Jane,*,1.1.2000,12:00,City"
        let result = AafRecordParser.parse(content: content)
        #expect(result.records.isEmpty)
        #expect(result.fatalMessages.count == 1)
    }
}
