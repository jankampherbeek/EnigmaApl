// AafRecordParser.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Parses an AAF'97 file into `[AafRecord]`. A new "#A93:" chunk starts a new
/// record and implicitly ends the previous one. Unknown chunks and "#:"
/// comment lines never abort parsing; a fatal error in one record does not
/// prevent the remaining records from being parsed.
enum AafRecordParser {

    private struct Builder {
        var a93Raw: String?
        var b93Raw: String?
        var zoneName: String?
        var source: String?
        var via: String?
        var comment: String?
        var unknownChunkNames: [String] = []
    }

    static func parse(content: String) -> FormatParseResult<AafRecord> {
        var result = FormatParseResult<AafRecord>()
        let normalized = content.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")

        var builder: Builder?
        var recordNumber = 0

        func finalizeIfNeeded() {
            guard let current = builder else { return }
            let (record, messages) = finalize(current, recordNumber: recordNumber)
            result.messages.append(contentsOf: messages)
            if let record { result.records.append(record) }
            builder = nil
        }

        for line in normalized.components(separatedBy: "\n") {
            guard line.hasPrefix("#"), let colonIndex = line.dropFirst().firstIndex(of: ":") else { continue }
            let tag = String(line[line.index(line.startIndex, offsetBy: 1)..<colonIndex]).uppercased()
            let rest = String(line[line.index(after: colonIndex)...])

            if tag.isEmpty { continue } // "#: comment"

            switch tag {
            case "A93":
                finalizeIfNeeded()
                recordNumber += 1
                builder = Builder(a93Raw: rest)
            case "B93":
                if builder != nil { builder?.b93Raw = rest }
                else { result.messages.append(.warning("'#B93' chunk found before any '#A93' record; ignored.")) }
            case "ZNAM":
                if builder != nil { builder?.zoneName = rest }
                else { result.messages.append(.warning("'#ZNAM' chunk found before any '#A93' record; ignored.")) }
            case "SRC":
                if builder != nil { builder?.source = rest }
                else { result.messages.append(.warning("'#SRC' chunk found before any '#A93' record; ignored.")) }
            case "VIA":
                if builder != nil { builder?.via = rest }
                else { result.messages.append(.warning("'#VIA' chunk found before any '#A93' record; ignored.")) }
            case "COM":
                if builder != nil { builder?.comment = rest }
                else { result.messages.append(.warning("'#COM' chunk found before any '#A93' record; ignored.")) }
            default:
                if builder != nil {
                    builder?.unknownChunkNames.append(tag)
                    result.messages.append(.warning("Unknown chunk '#\(tag)' ignored.", recordNumber: recordNumber))
                } else {
                    result.messages.append(.warning("Unknown chunk '#\(tag)' ignored."))
                }
            }
        }
        finalizeIfNeeded()

        return result
    }

    private static func finalize(_ builder: Builder, recordNumber: Int) -> (record: AafRecord?, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []

        guard let a93Raw = builder.a93Raw else {
            messages.append(.fatal("Record has no '#A93' chunk.", recordNumber: recordNumber))
            return (nil, messages)
        }
        let a93Fields = a93Raw.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard a93Fields.count == 7 else {
            messages.append(.fatal("'#A93' must have exactly 7 comma-separated fields, found \(a93Fields.count).", recordNumber: recordNumber))
            return (nil, messages)
        }

        guard let date = AafFieldParsers.parseDate(a93Fields[3], recordNumber: recordNumber, messages: &messages) else {
            return (nil, messages)
        }
        guard let time = AafFieldParsers.parseTime(a93Fields[4], recordNumber: recordNumber, messages: &messages) else {
            return (nil, messages)
        }

        guard let b93Raw = builder.b93Raw else {
            messages.append(.fatal("Record has no '#B93' chunk.", recordNumber: recordNumber))
            return (nil, messages)
        }
        let b93Fields = b93Raw.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard b93Fields.count == 5 else {
            messages.append(.fatal("'#B93' must have exactly 5 comma-separated fields, found \(b93Fields.count).", recordNumber: recordNumber))
            return (nil, messages)
        }

        guard let latitude = AafFieldParsers.parseCoordinate(
            b93Fields[1], positiveChar: "n", negativeChar: "s", isLongitude: false,
            recordNumber: recordNumber, field: "latitude", messages: &messages
        ) else {
            return (nil, messages)
        }
        guard let longitude = AafFieldParsers.parseCoordinate(
            b93Fields[2], positiveChar: "e", negativeChar: "w", isLongitude: true,
            recordNumber: recordNumber, field: "longitude", messages: &messages
        ) else {
            return (nil, messages)
        }
        guard let greenwichOffsetSeconds = AafFieldParsers.parseGreenwichOffset(b93Fields[3], recordNumber: recordNumber, messages: &messages) else {
            return (nil, messages)
        }

        let record = AafRecord(
            lastName: a93Fields[0],
            firstName: a93Fields[1],
            type: a93Fields[2].lowercased(),
            day: date.day, month: date.month, year: date.year, isGregorian: date.isGregorian,
            hour: time.hour, minute: time.minute, second: time.second,
            place: a93Fields[5],
            country: a93Fields[6],
            julianDayRaw: b93Fields[0],
            latitude: latitude,
            longitude: longitude,
            greenwichOffsetSeconds: greenwichOffsetSeconds,
            timeType: b93Fields[4].lowercased(),
            zoneName: builder.zoneName,
            source: builder.source,
            via: builder.via,
            comment: builder.comment,
            unknownChunkNames: builder.unknownChunkNames
        )
        return (record, messages)
    }
}
