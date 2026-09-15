// QckFileParser.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Splits a QCK file (as decoded text) into records and parses each one.
/// A fatal error in one record does not abort the file: the remaining
/// records are still parsed.
enum QckFileParser {

    static func parse(content: String) -> FormatParseResult<QckRecord> {
        let normalized = content
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let lines = normalized.components(separatedBy: "\n")

        var result = FormatParseResult<QckRecord>()
        var recordNumber = 0

        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            recordNumber += 1
            let (record, messages) = QckLineParser.parse(line: line, recordNumber: recordNumber)
            result.messages.append(contentsOf: messages)
            if let record {
                result.records.append(record)
            }
        }

        return result
    }
}
