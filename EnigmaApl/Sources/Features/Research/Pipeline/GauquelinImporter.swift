// GauquelinImporter.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Parses Gauquelin data files into `[ResearchInputRecord]`.
///
/// Files are tab-separated with a single header line that is skipped.
/// Blank lines and lines starting with `#` are silently skipped.
/// Seconds are not present in the coordinate fields and are treated as zero.
///
/// ## Column order:
/// ```
/// NUM  NAT  DAY  MON  YEA  HOU  MIN  SEC  TMZ  LAT  LON  COD  PLA
/// ```
/// - `NUM` — record number (ignored; ids are reassigned from `startId`)
/// - `NAT` — country code (ignored)
/// - `DAY` — day of month (1–31)
/// - `MON` — month (1–12)
/// - `YEA` — year (full, e.g. 1937)
/// - `HOU` — hour (0–23)
/// - `MIN` — minute (0–59)
/// - `SEC` — second (0–59)
/// - `TMZ` — UTC offset in whole hours (e.g. 0, 1, -5)
/// - `LAT` — latitude  `ddNmm` or `ddSmm`  (N positive, S negative; no seconds)
/// - `LON` — longitude `ddEmm` or `ddWmm`  (E positive, W negative; no seconds)
/// - `COD` — birthplace code (ignored)
/// - `PLA` — place name (ignored)
///
/// ## Example rows:
/// ```
/// NUM    NAT    DAY    MON    YEA    HOU    MIN    SEC    TMZ    LAT    LON    COD    PLA
/// 1    F    17    9    1937    17    0    0    0    44N50    0W34    33    BORDEAUX
/// 2    F    13    8    1889    12    20    40    0    48N50    2E20    75    PARIS 8E
/// ```
public struct GauquelinImporter: DataImporter, Sendable {

    public init() {}

    public func parse(source: String, isData: Bool, startId: Int) throws -> [ResearchInputRecord] {
        let raw: String
        do {
            raw = try String(contentsOfFile: source, encoding: .utf8)
        } catch {
            // Try ISO-8859-1 as a fallback for older Gauquelin files.
            if let r = try? String(contentsOfFile: source, encoding: .isoLatin1) {
                raw = r
            } else {
                throw DataImportError.sourceUnreadable(source)
            }
        }
        return try parseString(raw, isData: isData, startId: startId)
    }

    /// Parses an in-memory string — useful for tests.
    public func parseString(_ content: String, isData: Bool, startId: Int) throws -> [ResearchInputRecord] {
        let normalised = content
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r",   with: "\n")

        let lines = normalised.components(separatedBy: "\n")
        var records: [ResearchInputRecord] = []
        var nextId = startId
        var headerSkipped = false

        for (zeroIndex, line) in lines.enumerated() {
            let lineNumber = zeroIndex + 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

            // Skip the header row (first non-blank, non-comment line).
            if !headerSkipped {
                headerSkipped = true
                continue
            }

            let fields = trimmed.components(separatedBy: "\t")

            guard fields.count >= 13 else {
                throw DataImportError.parseError(line: lineNumber, text: trimmed)
            }

            // Fields 0 (NUM) and 1 (NAT) are ignored.
            let dayStr  = fields[2].trimmingCharacters(in: .whitespaces)
            let monStr  = fields[3].trimmingCharacters(in: .whitespaces)
            let yeaStr  = fields[4].trimmingCharacters(in: .whitespaces)
            let houStr  = fields[5].trimmingCharacters(in: .whitespaces)
            let minStr  = fields[6].trimmingCharacters(in: .whitespaces)
            let secStr  = fields[7].trimmingCharacters(in: .whitespaces)
            let tmzStr  = fields[8].trimmingCharacters(in: .whitespaces)
            let latStr  = fields[9].trimmingCharacters(in: .whitespaces)
            let lonStr  = fields[10].trimmingCharacters(in: .whitespaces)
            // Fields 11 (COD) and 12 (PLA) are ignored.

            guard let day    = Int(dayStr),  day    >= 1,  day    <= 31 else { throw DataImportError.valueOutOfRange(line: lineNumber, field: "day",    value: dayStr) }
            guard let month  = Int(monStr),  month  >= 1,  month  <= 12 else { throw DataImportError.valueOutOfRange(line: lineNumber, field: "month",  value: monStr) }
            guard let year   = Int(yeaStr)                               else { throw DataImportError.parseError(line: lineNumber, text: yeaStr) }
            guard let hour   = Int(houStr),  hour   >= 0,  hour   <= 23 else { throw DataImportError.valueOutOfRange(line: lineNumber, field: "hour",   value: houStr) }
            guard let minute = Int(minStr),  minute >= 0,  minute <= 59 else { throw DataImportError.valueOutOfRange(line: lineNumber, field: "minute", value: minStr) }
            guard let second = Int(secStr),  second >= 0,  second <= 59 else { throw DataImportError.valueOutOfRange(line: lineNumber, field: "second", value: secStr) }
            guard let offset = Double(tmzStr), offset >= -14, offset <= 14 else { throw DataImportError.valueOutOfRange(line: lineNumber, field: "timezone", value: tmzStr) }

            let geoLat = try parseCoordinate(latStr, directions: ("N", "S"), fieldName: "latitude",  line: lineNumber)
            let geoLon = try parseCoordinate(lonStr, directions: ("E", "W"), fieldName: "longitude", line: lineNumber)

            if geoLat < -90  || geoLat > 90  { throw DataImportError.valueOutOfRange(line: lineNumber, field: "latitude",  value: latStr) }
            if geoLon < -180 || geoLon > 180 { throw DataImportError.valueOutOfRange(line: lineNumber, field: "longitude", value: lonStr) }

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

    // MARK: - Helpers

    /// Parses a coordinate in the form `ddNmm` / `ddSmm` (latitude) or `ddEmm` / `ddWmm` (longitude).
    /// `directions.0` is the positive direction, `directions.1` is the negative direction.
    /// Seconds are not present in the Gauquelin format and are treated as zero.
    private func parseCoordinate(_ raw: String, directions: (String, String),
                                 fieldName: String, line: Int) throws -> Double {
        let upper = raw.uppercased()
        let posDir = directions.0.uppercased()
        let negDir = directions.1.uppercased()

        let isNegative: Bool
        let splitChar: Character
        if upper.contains(Character(posDir)) {
            isNegative = false
            splitChar  = Character(posDir)
        } else if upper.contains(Character(negDir)) {
            isNegative = true
            splitChar  = Character(negDir)
        } else {
            throw DataImportError.parseError(line: line, text: raw)
        }

        guard let splitIdx = upper.firstIndex(of: splitChar) else {
            throw DataImportError.parseError(line: line, text: raw)
        }

        let degStr = String(upper[upper.startIndex..<splitIdx])
            .trimmingCharacters(in: .whitespaces)
        let minStr = String(upper[upper.index(after: splitIdx)...])
            .trimmingCharacters(in: .whitespaces)

        guard let deg = Double(degStr), let min = Double(minStr) else {
            throw DataImportError.parseError(line: line, text: raw)
        }

        let decimal = deg + min / 60.0
        return isNegative ? -decimal : decimal
    }
}
