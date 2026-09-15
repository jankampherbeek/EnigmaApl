// QckFileParserTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct QckFileParserTests {

    private let fixture = "JK                     JAN 29, 195308:37:30 AM    -01:00006E54'00 52N13'00 Enschede,Netherlands     "

    // 16. CRLF and LF.
    @Test("QCK: file with mixed CRLF and LF line endings parses both records")
    func testMixedLineEndings() {
        let content = fixture + "\r\n" + fixture + "\n"
        let result = QckFileParser.parse(content: content)
        #expect(result.records.count == 2)
        #expect(result.fatalMessages.isEmpty)
    }

    // 17. Multiple records in one file.
    @Test("QCK: multiple records in one file are all parsed")
    func testMultipleRecords() {
        let content = [fixture, fixture, fixture].joined(separator: "\n")
        let result = QckFileParser.parse(content: content)
        #expect(result.records.count == 3)
    }

    @Test("QCK: a fatal error in one record does not abort the remaining records")
    func testOneBadRecordDoesNotAbortFile() {
        let badLine = String(repeating: "X", count: 90)
        let content = [fixture, badLine, fixture].joined(separator: "\n")
        let result = QckFileParser.parse(content: content)
        #expect(result.records.count == 2)
        #expect(result.fatalMessages.count == 1)
    }

    @Test("QCK: blank lines between records are ignored")
    func testBlankLinesIgnored() {
        let content = fixture + "\n\n" + fixture
        let result = QckFileParser.parse(content: content)
        #expect(result.records.count == 2)
    }
}
