// QuickChartImporter.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Parses files in the QuickChart SDF (Structure Defined Format) into `[ResearchInputRecord]`.
///
/// QuickChart uses fixed-width columns, Windows line endings (CR/LF), and Windows-1252 encoding.
/// Blank lines are silently skipped. Lines shorter than 74 characters throw a parse error.
/// Content at column 101 and beyond (calculated positions) is ignored.
///
/// ## Column layout (1-based positions):
/// ```
///  1–23   Name                    (ignored)
/// 24–26   Month abbreviation      JAN … DEC
/// 27      Space
/// 28–29   Day                     two digits, leading zero
/// 30      Comma
/// 31      Space
/// 32–35   Year                    four digits
/// 36–46   Time                    hh:mm:ss AM  or  hh:mm:ss PM  (11 chars)
/// 47      Space
/// 48–50   Timezone indicator      LMT  or  three spaces
/// 51–56   UTC offset              ±hh:mm  (sign + hours + colon + minutes)
/// 57–65   Geographic longitude    dddDmm'ss  (D = E or W)
/// 66      Space
/// 67–74   Geographic latitude     ddDmm'ss   (D = N or S)
/// 75–100  Location and country    (ignored)
/// 101+    Calculated positions    (ignored)
/// ```
///
/// If the timezone indicator is `LMT`, the UTC offset is derived from the geographic longitude
/// by dividing it by 15 (including seconds of arc).
public struct QuickChartImporter: DataImporter, Sendable {

    public init() {}

    public func parse(source: String, isData: Bool, startId: Int) throws -> [ResearchInputRecord] {
        // QuickChart uses Windows-1252; fall back to ISO-8859-1 if unavailable.
        let raw: String
        if let r = try? String(contentsOfFile: source, encoding: .windowsCP1252) {
            raw = r
        } else if let r = try? String(contentsOfFile: source, encoding: .isoLatin1) {
            raw = r
        } else {
            throw DataImportError.sourceUnreadable(source)
        }
        return try parseString(raw, isData: isData, startId: startId)
    }

    /// Parses an in-memory string — useful for tests.
    public func parseString(_ content: String, isData: Bool, startId: Int) throws -> [ResearchInputRecord] {
        // Normalise CR/LF and bare CR to LF.
        let normalised = content
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r",   with: "\n")

        let lines = normalised.components(separatedBy: "\n")
        var records: [ResearchInputRecord] = []
        var nextId = startId

        for (zeroIndex, line) in lines.enumerated() {
            let lineNumber = zeroIndex + 1

            // Skip blank lines.
            if line.trimmingCharacters(in: .whitespaces).isEmpty { continue }

            let chars = Array(line)

            // Latitude ends at position 74 (index 73); anything shorter is malformed.
            guard chars.count >= 74 else {
                throw DataImportError.parseError(line: lineNumber, text: line)
            }

            // ── Extract fixed-width fields (0-based indices) ──────────────────────
            let monthStr  = String(chars[23..<26])         // pos 24–26
            let dayStr    = String(chars[27..<29])         // pos 28–29
            let yearStr   = String(chars[31..<35])         // pos 32–35
            let timeStr   = String(chars[35..<46])         // pos 36–46
            let tzStr     = String(chars[47..<50])         // pos 48–50
            let offsetStr = String(chars[50..<56])         // pos 51–56
            let lonStr    = String(chars[56..<65])         // pos 57–65
            let latStr    = String(chars[66..<74])         // pos 67–74

            // ── Parse fields ──────────────────────────────────────────────────────
            let month  = try parseMonth(monthStr,  line: lineNumber)
            let day    = try parseDay(dayStr,      line: lineNumber)
            let year   = try parseYear(yearStr,    line: lineNumber)
            let (hour, minute, second) = try parseTime(timeStr, line: lineNumber)
            let geoLon = try parseLongitude(lonStr, line: lineNumber)
            let geoLat = try parseLatitude(latStr,  line: lineNumber)

            // LMT: recalculate offset from longitude; otherwise parse the stored offset.
            let isLmt  = tzStr.trimmingCharacters(in: .whitespaces).uppercased() == "LMT"
            let offset = isLmt ? (geoLon / 15.0) : (try parseOffset(offsetStr, line: lineNumber))

            // ── Range validation ──────────────────────────────────────────────────
            if geoLat < -90  || geoLat > 90  { throw DataImportError.valueOutOfRange(line: lineNumber, field: "latitude",  value: latStr) }
            if geoLon < -180 || geoLon > 180 { throw DataImportError.valueOutOfRange(line: lineNumber, field: "longitude", value: lonStr) }
            if offset  < -14 || offset  > 14 { throw DataImportError.valueOutOfRange(line: lineNumber, field: "offset",    value: offsetStr) }

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

    private func parseMonth(_ raw: String, line: Int) throws -> Int {
        switch raw.trimmingCharacters(in: .whitespaces).uppercased() {
        case "JAN": return 1
        case "FEB": return 2
        case "MAR": return 3
        case "APR": return 4
        case "MAY": return 5
        case "JUN": return 6
        case "JUL": return 7
        case "AUG": return 8
        case "SEP": return 9
        case "OCT": return 10
        case "NOV": return 11
        case "DEC": return 12
        default:
            throw DataImportError.valueOutOfRange(line: line, field: "month", value: raw.trimmingCharacters(in: .whitespaces))
        }
    }

    private func parseDay(_ raw: String, line: Int) throws -> Int {
        guard let day = Int(raw.trimmingCharacters(in: .whitespaces)), day >= 1, day <= 31 else {
            throw DataImportError.valueOutOfRange(line: line, field: "day", value: raw.trimmingCharacters(in: .whitespaces))
        }
        return day
    }

    private func parseYear(_ raw: String, line: Int) throws -> Int {
        guard let year = Int(raw.trimmingCharacters(in: .whitespaces)) else {
            throw DataImportError.parseError(line: line, text: raw)
        }
        return year
    }

    /// Parses `hh:mm:ss AM` or `hh:mm:ss PM` (11 characters).
    /// Converts 12-hour clock to 24-hour: 12 AM → 0, 12 PM → 12.
    private func parseTime(_ raw: String, line: Int) throws -> (hour: Int, minute: Int, second: Int) {
        // Split on ':' → ["hh", "mm", "ss AM"] or ["hh", "mm", "ss PM"]
        let parts = raw.components(separatedBy: ":")
        guard parts.count == 3,
              let hourRaw = Int(parts[0].trimmingCharacters(in: .whitespaces)),
              let minute  = Int(parts[1].trimmingCharacters(in: .whitespaces)) else {
            throw DataImportError.parseError(line: line, text: raw)
        }
        // parts[2] is "ss AM" or "ss PM"
        let secAmPm = parts[2].trimmingCharacters(in: .whitespaces)
        let secTokens = secAmPm.components(separatedBy: " ").filter { !$0.isEmpty }
        guard let second = Int(secTokens[0]) else {
            throw DataImportError.parseError(line: line, text: raw)
        }
        let amPm = secTokens.count >= 2 ? secTokens[1].uppercased() : "AM"

        var hour = hourRaw
        if      amPm == "PM" && hour != 12 { hour += 12 }
        else if amPm == "AM" && hour == 12 { hour  =  0 }

        if hour   < 0 || hour   > 23 { throw DataImportError.valueOutOfRange(line: line, field: "hour",   value: "\(hourRaw)") }
        if minute < 0 || minute > 59 { throw DataImportError.valueOutOfRange(line: line, field: "minute", value: parts[1]) }
        if second < 0 || second > 59 { throw DataImportError.valueOutOfRange(line: line, field: "second", value: secTokens[0]) }
        return (hour, minute, second)
    }

    /// Parses geographic longitude `dddDmm'ss` (D = E or W), e.g. `002E21'00`.
    /// Returns decimal degrees; West is negative.
    private func parseLongitude(_ raw: String, line: Int) throws -> Double {
        let s = Array(raw)
        // Minimum length: 3 (deg) + 1 (dir) + 2 (min) + 1 (') + 2 (sec) = 9
        guard s.count >= 9,
              let deg = Int(String(s[0..<3])),
              let min = Int(String(s[4..<6])),
              let sec = Int(String(s[7..<9])) else {
            throw DataImportError.parseError(line: line, text: raw)
        }
        let dir = String(s[3]).uppercased()
        guard dir == "E" || dir == "W" else {
            throw DataImportError.parseError(line: line, text: raw)
        }
        let decimal = Double(deg) + Double(min) / 60.0 + Double(sec) / 3600.0
        return dir == "W" ? -decimal : decimal
    }

    /// Parses geographic latitude `ddDmm'ss` (D = N or S), e.g. `48N51'00`.
    /// Returns decimal degrees; South is negative.
    private func parseLatitude(_ raw: String, line: Int) throws -> Double {
        let s = Array(raw)
        // Minimum length: 2 (deg) + 1 (dir) + 2 (min) + 1 (') + 2 (sec) = 8
        guard s.count >= 8,
              let deg = Int(String(s[0..<2])),
              let min = Int(String(s[3..<5])),
              let sec = Int(String(s[6..<8])) else {
            throw DataImportError.parseError(line: line, text: raw)
        }
        let dir = String(s[2]).uppercased()
        guard dir == "N" || dir == "S" else {
            throw DataImportError.parseError(line: line, text: raw)
        }
        let decimal = Double(deg) + Double(min) / 60.0 + Double(sec) / 3600.0
        return dir == "S" ? -decimal : decimal
    }

    /// Parses a UTC offset `±hh:mm` (6 characters), e.g. `-01:00` or `-00:28`.
    /// Returns decimal hours; East (positive longitude) is positive.
    private func parseOffset(_ raw: String, line: Int) throws -> Double {
        let s = raw.trimmingCharacters(in: .whitespaces)
        guard !s.isEmpty else { return 0.0 }

        let sign: Double
        let rest: String
        if s.hasPrefix("-") {
            sign = -1.0; rest = String(s.dropFirst())
        } else if s.hasPrefix("+") {
            sign =  1.0; rest = String(s.dropFirst())
        } else {
            sign =  1.0; rest = s
        }

        let parts = rest.components(separatedBy: ":")
        guard parts.count == 2,
              let hours   = Double(parts[0].trimmingCharacters(in: .whitespaces)),
              let minutes = Double(parts[1].trimmingCharacters(in: .whitespaces)) else {
            throw DataImportError.parseError(line: line, text: raw)
        }
        return sign * (hours + minutes / 60.0)
    }
}
