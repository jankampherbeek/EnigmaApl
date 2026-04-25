// DataImporter.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Errors

public enum DataImportError: Error {
    /// A line could not be parsed; includes 1-based line number and the offending text.
    case parseError(line: Int, text: String)
    /// A required field contains an out-of-range value.
    case valueOutOfRange(line: Int, field: String, value: String)
    /// The source (file, string) could not be read.
    case sourceUnreadable(String)
    /// The file has no data rows (may be empty or header-only).
    case noData
}

// MARK: - Protocol

/// Converts an external data source into `[ResearchInputRecord]`.
/// Implementations decide the format (CSV, JSON, …).
/// `isData` is set by the caller — the same protocol is used for both
/// real-data imports and control-group imports.
public protocol DataImporter: Sendable {
    /// Parses the source and returns validated records.
    /// `startId` is the id assigned to the first record; subsequent records increment by 1.
    /// - Parameters:
    ///   - source: Format-specific source descriptor (file path, raw string, …).
    ///   - isData: Whether these records are real data (`true`) or control group (`false`).
    ///   - startId: Id to assign to the first parsed record.
    /// - Returns: Parsed and validated records in source order.
    /// - Throws: `DataImportError` on any parse or validation failure.
    func parse(source: String, isData: Bool, startId: Int) throws -> [ResearchInputRecord]
}

// MARK: - CSV importer

/// Parses a semicolon-delimited CSV file into `[ResearchInputRecord]`.
///
/// ## Expected column order (no header row):
/// ```
/// year ; month ; day ; hour ; minute ; second ; geoLat ; geoLon ; offset
/// ```
/// - `year`    — full year, e.g. 1953
/// - `month`   — 1–12
/// - `day`     — 1–31
/// - `hour`    — 0–23
/// - `minute`  — 0–59
/// - `second`  — 0–59
/// - `geoLat`  — decimal degrees, negative = south (−90 … +90)
/// - `geoLon`  — decimal degrees, negative = west (−180 … +180)
/// - `offset`  — UTC offset in decimal hours, e.g. 1.0 for CET, −5.0 for EST
///
/// Blank lines and lines starting with `#` are silently skipped.
public struct CsvDataImporter: DataImporter, Sendable {

    private let separator: Character

    /// - Parameter separator: Column separator, defaults to `;`.
    public init(separator: Character = ";") {
        self.separator = separator
    }

    public func parse(source: String, isData: Bool, startId: Int) throws -> [ResearchInputRecord] {
        let raw: String
        do {
            raw = try String(contentsOfFile: source, encoding: .utf8)
        } catch {
            throw DataImportError.sourceUnreadable(source)
        }
        return try parseString(raw, isData: isData, startId: startId)
    }

    /// Convenience entry point that parses an in-memory string directly (useful for tests).
    public func parseString(_ content: String, isData: Bool, startId: Int) throws -> [ResearchInputRecord] {
        let lines = content.components(separatedBy: .newlines)
        var records: [ResearchInputRecord] = []
        var nextId = startId

        for (zeroIndex, line) in lines.enumerated() {
            let lineNumber = zeroIndex + 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Skip blank lines and comments
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

            let fields = trimmed.split(separator: separator, omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespaces) }

            guard fields.count == 9 else {
                throw DataImportError.parseError(line: lineNumber, text: trimmed)
            }

            // Parse each field with clear error reporting
            guard let year   = Int(fields[0]) else { throw DataImportError.parseError(line: lineNumber, text: fields[0]) }
            guard let month  = Int(fields[1]) else { throw DataImportError.parseError(line: lineNumber, text: fields[1]) }
            guard let day    = Int(fields[2]) else { throw DataImportError.parseError(line: lineNumber, text: fields[2]) }
            guard let hour   = Int(fields[3]) else { throw DataImportError.parseError(line: lineNumber, text: fields[3]) }
            guard let minute = Int(fields[4]) else { throw DataImportError.parseError(line: lineNumber, text: fields[4]) }
            guard let second = Int(fields[5]) else { throw DataImportError.parseError(line: lineNumber, text: fields[5]) }
            guard let geoLat = Double(fields[6]) else { throw DataImportError.parseError(line: lineNumber, text: fields[6]) }
            guard let geoLon = Double(fields[7]) else { throw DataImportError.parseError(line: lineNumber, text: fields[7]) }
            guard let offset = Double(fields[8]) else { throw DataImportError.parseError(line: lineNumber, text: fields[8]) }

            // Range validation
            if month  < 1  || month  > 12  { throw DataImportError.valueOutOfRange(line: lineNumber, field: "month",  value: fields[1]) }
            if day    < 1  || day    > 31  { throw DataImportError.valueOutOfRange(line: lineNumber, field: "day",    value: fields[2]) }
            if hour   < 0  || hour   > 23  { throw DataImportError.valueOutOfRange(line: lineNumber, field: "hour",   value: fields[3]) }
            if minute < 0  || minute > 59  { throw DataImportError.valueOutOfRange(line: lineNumber, field: "minute", value: fields[4]) }
            if second < 0  || second > 59  { throw DataImportError.valueOutOfRange(line: lineNumber, field: "second", value: fields[5]) }
            if geoLat < -90  || geoLat > 90   { throw DataImportError.valueOutOfRange(line: lineNumber, field: "geoLat", value: fields[6]) }
            if geoLon < -180 || geoLon > 180  { throw DataImportError.valueOutOfRange(line: lineNumber, field: "geoLon", value: fields[7]) }
            if offset < -14  || offset > 14   { throw DataImportError.valueOutOfRange(line: lineNumber, field: "offset", value: fields[8]) }

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
}
