// EnigmaFormatImporter.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Parses the standard Enigma CSV format into `[ResearchInputRecord]`.
///
/// ## File format
/// Comma-separated, first row is a header and is skipped.
/// Blank lines and lines starting with `#` are silently skipped.
///
/// Column order:
/// ```
/// Id, Name, longitude, latitude, date, cal, time, zone, dst
/// ```
/// - `Id`        — integer identifier (ignored; ids are reassigned from `startId`)
/// - `Name`      — free text (ignored)
/// - `longitude` — `deg:min:sec:dir`  dir = E or W
/// - `latitude`  — `deg:min:sec:dir`  dir = N or S
/// - `date`      — `year/month/day`
/// - `cal`       — `G` (Gregorian) or `J` (Julian) — stored but not used in calculation (SE handles via JD)
/// - `time`      — `hour:minute` or `hour:minute:second`
/// - `zone`      — UTC offset as decimal hours (e.g. `0.7277778`)
/// - `dst`       — daylight saving time offset as decimal hours (e.g. `0` or `1`)
///
/// The effective UTC offset applied is `zone + dst`.
///
/// ## Example rows
/// ```
/// 107, Leonardo da Vinci, 10:55:0:E, 43:47:0:N, 1452/4/14, J, 21:40,   0.7277778 ,0
/// 111, Joshua Reynolds, 4:3:0:W, 50:23:0:N, 1723/7/27, G, 9:30, -0.27, 0
/// ```
public struct EnigmaFormatImporter: DataImporter {

    public init() {}

    public func parse(source: String, isData: Bool, startId: Int) throws -> [ResearchInputRecord] {
        let raw: String
        do {
            raw = try String(contentsOfFile: source, encoding: .utf8)
        } catch {
            throw DataImportError.sourceUnreadable(source)
        }
        return try parseString(raw, isData: isData, startId: startId)
    }

    /// Parses an in-memory string — useful for tests.
    public func parseString(_ content: String, isData: Bool, startId: Int) throws -> [ResearchInputRecord] {
        let lines = content.components(separatedBy: .newlines)
        var records: [ResearchInputRecord] = []
        var nextId = startId
        var headerSkipped = false

        for (zeroIndex, line) in lines.enumerated() {
            let lineNumber = zeroIndex + 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

            // Skip the header row (first non-blank, non-comment line)
            if !headerSkipped {
                headerSkipped = true
                continue
            }

            let fields = trimmed.split(separator: ",", omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespaces) }

            guard fields.count == 9 else {
                throw DataImportError.parseError(line: lineNumber, text: trimmed)
            }

            // fields[0] = Id (ignored), fields[1] = Name (ignored)
            let geoLon = try parseDmsDirection(fields[2], fieldName: "longitude", line: lineNumber)
            let geoLat = try parseDmsDirection(fields[3], fieldName: "latitude",  line: lineNumber)
            let (year, month, day) = try parseDate(fields[4], line: lineNumber)
            // fields[5] = cal (J/G) — not used further
            let (hour, minute, second) = try parseTime(fields[6], line: lineNumber)

            guard let zone = Double(fields[7]) else {
                throw DataImportError.parseError(line: lineNumber, text: fields[7])
            }
            guard let dst = Double(fields[8]) else {
                throw DataImportError.parseError(line: lineNumber, text: fields[8])
            }
            let offset = zone + dst

            if geoLat < -90  || geoLat > 90   { throw DataImportError.valueOutOfRange(line: lineNumber, field: "latitude",  value: fields[3]) }
            if geoLon < -180 || geoLon > 180  { throw DataImportError.valueOutOfRange(line: lineNumber, field: "longitude", value: fields[2]) }
            if offset < -14  || offset > 14   { throw DataImportError.valueOutOfRange(line: lineNumber, field: "zone+dst",  value: "\(offset)") }

            records.append(ResearchInputRecord(
                id: nextId,
                isData: isData,
                geoLat: geoLat,
                geoLon: geoLon,
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                offset: offset
            ))
            nextId += 1
        }

        if records.isEmpty { throw DataImportError.noData }
        return records
    }

    // MARK: - Field parsers

    /// Parses `deg:min:sec:dir` where dir is N/S/E/W.
    /// Returns decimal degrees; southern and western directions are negative.
    private func parseDmsDirection(_ raw: String, fieldName: String, line: Int) throws -> Double {
        let parts = raw.split(separator: ":", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 4,
              let deg = Double(parts[0]),
              let min = Double(parts[1]),
              let sec = Double(parts[2]) else {
            throw DataImportError.parseError(line: line, text: raw)
        }
        let dir = parts[3].uppercased()
        guard ["N", "S", "E", "W"].contains(dir) else {
            throw DataImportError.parseError(line: line, text: raw)
        }
        let decimal = deg + min / 60.0 + sec / 3600.0
        return (dir == "S" || dir == "W") ? -decimal : decimal
    }

    /// Parses `year/month/day`.
    private func parseDate(_ raw: String, line: Int) throws -> (year: Int, month: Int, day: Int) {
        let parts = raw.split(separator: "/").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 3,
              let year  = Int(parts[0]),
              let month = Int(parts[1]),
              let day   = Int(parts[2]) else {
            throw DataImportError.parseError(line: line, text: raw)
        }
        if month < 1 || month > 12 { throw DataImportError.valueOutOfRange(line: line, field: "month", value: parts[1]) }
        if day   < 1 || day   > 31 { throw DataImportError.valueOutOfRange(line: line, field: "day",   value: parts[2]) }
        return (year, month, day)
    }

    /// Parses `hour:minute` or `hour:minute:second`.
    private func parseTime(_ raw: String, line: Int) throws -> (hour: Int, minute: Int, second: Int) {
        let parts = raw.split(separator: ":").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count >= 2,
              let hour   = Int(parts[0]),
              let minute = Int(parts[1]) else {
            throw DataImportError.parseError(line: line, text: raw)
        }
        let second = parts.count >= 3 ? (Int(parts[2]) ?? 0) : 0
        if hour   < 0 || hour   > 23 { throw DataImportError.valueOutOfRange(line: line, field: "hour",   value: parts[0]) }
        if minute < 0 || minute > 59 { throw DataImportError.valueOutOfRange(line: line, field: "minute", value: parts[1]) }
        if second < 0 || second > 59 { throw DataImportError.valueOutOfRange(line: line, field: "second", value: "\(second)") }
        return (hour, minute, second)
    }
}
