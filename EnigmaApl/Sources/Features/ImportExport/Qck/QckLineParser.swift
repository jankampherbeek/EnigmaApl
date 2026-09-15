// QckLineParser.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Parses a single fixed-width Quick*Chart / QCK record (100 or 101
/// characters) into a `QckRecord`. Offsets are zero-based, per the QCK
/// recordindeling: only CR/LF is stripped before the length check; the line
/// is never fully trimmed first, since that would shift every fixed field.
enum QckLineParser {

    static let months = [
        "JAN": 1, "FEB": 2, "MAR": 3, "APR": 4, "MAY": 5, "JUN": 6,
        "JUL": 7, "AUG": 8, "SEP": 9, "OCT": 10, "NOV": 11, "DEC": 12
    ]

    /// Parses one record. Returns `nil` for the record together with at least
    /// one fatal message when the record cannot be represented; otherwise
    /// returns the record together with zero or more warnings.
    static func parse(line: String, recordNumber: Int) -> (record: QckRecord?, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []

        let stripped = stripTrailingLineEndings(line)
        let chars = Array(stripped)

        guard chars.count == 100 || (chars.count == 101 && chars[100] == " ") else {
            messages.append(.fatal(
                "Invalid record length: expected 100 or 101 characters, got \(chars.count).",
                recordNumber: recordNumber
            ))
            return (nil, messages)
        }

        let name = trimmingTrailingWhitespace(String(chars[0..<23]))

        guard let month = parseMonth(String(chars[23..<26]), recordNumber: recordNumber, messages: &messages) else {
            return (nil, messages)
        }
        guard let day = parseInt(String(chars[26..<29]), field: "day", recordNumber: recordNumber, messages: &messages) else {
            return (nil, messages)
        }
        guard let year = parseYear(String(chars[30..<35]), recordNumber: recordNumber, messages: &messages) else {
            return (nil, messages)
        }

        let dateValidation = AstronomicalDateValidation.validateDateComponents(year: year, month: month, day: day, gregorian: true)
        guard dateValidation.isValid else {
            messages.append(.fatal(dateValidation.message ?? "Invalid date.", recordNumber: recordNumber, field: "date"))
            return (nil, messages)
        }
        if GregorianCutover.isBeforeCutover(year: year, month: month, day: day) {
            messages.append(.warning(
                "Date is before the Gregorian cutover (1582-10-15); QCK has no explicit calendar attribute, Gregorian was assumed.",
                recordNumber: recordNumber, field: "date"
            ))
        }

        guard let (hour, minute, second, isPM) = parseTime(String(chars[35..<47]), recordNumber: recordNumber, messages: &messages) else {
            return (nil, messages)
        }

        let tzAbbreviation = String(chars[47..<50]).trimmingCharacters(in: .whitespaces).uppercased()

        guard let correctionMinutes = parseCorrection(String(chars[50..<56]), recordNumber: recordNumber, messages: &messages) else {
            return (nil, messages)
        }

        guard let longitude = parseLongitude(chars, base: 56, recordNumber: recordNumber, messages: &messages) else {
            return (nil, messages)
        }
        guard let latitude = parseLatitude(chars, base: 66, recordNumber: recordNumber, messages: &messages) else {
            return (nil, messages)
        }

        let place = trimmingTrailingWhitespace(String(chars[75..<100]))

        let record = QckRecord(
            name: name,
            month: month,
            day: day,
            year: year,
            hour: hour,
            minute: minute,
            second: second,
            isPM: isPM,
            timeZoneAbbreviation: tzAbbreviation,
            qckCorrectionMinutes: correctionMinutes,
            longitude: longitude,
            latitude: latitude,
            place: place
        )
        return (record, messages)
    }

    // MARK: - Field parsers

    private static func parseMonth(_ raw: String, recordNumber: Int, messages: inout [ExchangeMessage]) -> Int? {
        let key = raw.trimmingCharacters(in: .whitespaces).uppercased()
        guard let month = months[key] else {
            messages.append(.fatal("Unrecognized month abbreviation '\(raw)'.", recordNumber: recordNumber, field: "month"))
            return nil
        }
        return month
    }

    private static func parseInt(_ raw: String, field: String, recordNumber: Int, messages: inout [ExchangeMessage]) -> Int? {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        guard let value = Int(trimmed) else {
            messages.append(.fatal("Field '\(field)' is not a valid number: '\(raw)'.", recordNumber: recordNumber, field: field))
            return nil
        }
        return value
    }

    private static func parseYear(_ raw: String, recordNumber: Int, messages: inout [ExchangeMessage]) -> Int? {
        guard let year = parseInt(raw, field: "year", recordNumber: recordNumber, messages: &messages) else { return nil }
        guard year >= -9999 && year <= 99999 else {
            messages.append(.fatal("Year \(year) is outside the supported QCK range (-9999...99999).", recordNumber: recordNumber, field: "year"))
            return nil
        }
        return year
    }

    /// Parses "hh:mm:ss AM"/"hh:mm:ss PM", tolerant of the historical "00:00:00 PM" bug.
    private static func parseTime(_ raw: String, recordNumber: Int, messages: inout [ExchangeMessage]) -> (hour: Int, minute: Int, second: Int, isPM: Bool)? {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        let parts = trimmed.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard parts.count == 2 else {
            messages.append(.fatal("Invalid time format: '\(raw)'.", recordNumber: recordNumber, field: "time"))
            return nil
        }
        let ampm = parts[1].uppercased()
        guard ampm == "AM" || ampm == "PM" else {
            messages.append(.fatal("Invalid AM/PM indicator: '\(parts[1])'.", recordNumber: recordNumber, field: "time"))
            return nil
        }
        let clock = parts[0].split(separator: ":").map(String.init)
        guard clock.count == 3,
              let hour12Raw = Int(clock[0]), let minute = Int(clock[1]), let second = Int(clock[2]) else {
            messages.append(.fatal("Invalid time format: '\(raw)'.", recordNumber: recordNumber, field: "time"))
            return nil
        }
        guard hour12Raw >= 0 && hour12Raw <= 12, minute >= 0 && minute <= 59, second >= 0 && second <= 59 else {
            messages.append(.fatal("Time components out of range: '\(raw)'.", recordNumber: recordNumber, field: "time"))
            return nil
        }
        let isPM = ampm == "PM"
        // Tolerate the historical "00:hh:ss" bug by treating hour 0 like hour 12.
        let hour12 = hour12Raw == 0 ? 12 : hour12Raw
        let hour24: Int
        if hour12 == 12 {
            hour24 = isPM ? 12 : 0
        } else {
            hour24 = isPM ? hour12 + 12 : hour12
        }
        if hour12Raw == 0 {
            messages.append(.warning("Time field used the historical '00:mm:ss' form; interpreted as 12:mm:ss.", recordNumber: recordNumber, field: "time"))
        }
        return (hour24, minute, second, isPM)
    }

    /// Parses the QCK correction "±hh:mm" (QCK's own sign convention, UT = LocalTime + correction).
    private static func parseCorrection(_ raw: String, recordNumber: Int, messages: inout [ExchangeMessage]) -> Int? {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return 0 }
        var rest = Substring(trimmed)
        var sign = 1
        if rest.hasPrefix("-") { sign = -1; rest = rest.dropFirst() }
        else if rest.hasPrefix("+") { rest = rest.dropFirst() }
        let parts = rest.split(separator: ":").map(String.init)
        guard parts.count == 2, let hours = Int(parts[0]), let minutes = Int(parts[1]), minutes >= 0 && minutes <= 59 else {
            messages.append(.fatal("Invalid QCK correction: '\(raw)'.", recordNumber: recordNumber, field: "correction"))
            return nil
        }
        return sign * (hours * 60 + minutes)
    }

    /// Longitude "DDD[E|W]MM'SS" at fixed sub-offsets relative to `base`.
    private static func parseLongitude(_ chars: [Character], base: Int, recordNumber: Int, messages: inout [ExchangeMessage]) -> Double? {
        guard chars.count >= base + 9 else {
            messages.append(.fatal("Longitude field is too short.", recordNumber: recordNumber, field: "longitude"))
            return nil
        }
        let degStr = String(chars[base..<(base + 3)])
        let dirChar = chars[base + 3]
        let minStr = String(chars[(base + 4)..<(base + 6)])
        let secStr = String(chars[(base + 7)..<(base + 9)])
        guard let degrees = Int(degStr), let minutes = Int(minStr), let seconds = Int(secStr) else {
            messages.append(.fatal("Invalid longitude: '\(String(chars[base..<(base + 9)]))'.", recordNumber: recordNumber, field: "longitude"))
            return nil
        }
        let dir = String(dirChar).uppercased()
        guard dir == "E" || dir == "W" else {
            messages.append(.fatal("Invalid longitude direction: '\(dirChar)'.", recordNumber: recordNumber, field: "longitude"))
            return nil
        }
        guard GeoCoordinateConversion.isValidLongitude(degrees: degrees, minutes: minutes, seconds: seconds) else {
            messages.append(.fatal("Longitude out of range: '\(String(chars[base..<(base + 9)]))'.", recordNumber: recordNumber, field: "longitude"))
            return nil
        }
        return GeoCoordinateConversion.decimalDegrees(degrees: degrees, minutes: minutes, seconds: seconds, isPositiveDirection: dir == "E")
    }

    /// Latitude "DD[N|S]MM'SS" at fixed sub-offsets relative to `base`.
    private static func parseLatitude(_ chars: [Character], base: Int, recordNumber: Int, messages: inout [ExchangeMessage]) -> Double? {
        guard chars.count >= base + 8 else {
            messages.append(.fatal("Latitude field is too short.", recordNumber: recordNumber, field: "latitude"))
            return nil
        }
        let degStr = String(chars[base..<(base + 2)])
        let dirChar = chars[base + 2]
        let minStr = String(chars[(base + 3)..<(base + 5)])
        let secStr = String(chars[(base + 6)..<(base + 8)])
        guard let degrees = Int(degStr), let minutes = Int(minStr), let seconds = Int(secStr) else {
            messages.append(.fatal("Invalid latitude: '\(String(chars[base..<(base + 8)]))'.", recordNumber: recordNumber, field: "latitude"))
            return nil
        }
        let dir = String(dirChar).uppercased()
        guard dir == "N" || dir == "S" else {
            messages.append(.fatal("Invalid latitude direction: '\(dirChar)'.", recordNumber: recordNumber, field: "latitude"))
            return nil
        }
        guard GeoCoordinateConversion.isValidLatitude(degrees: degrees, minutes: minutes, seconds: seconds) else {
            messages.append(.fatal("Latitude out of range: '\(String(chars[base..<(base + 8)]))'.", recordNumber: recordNumber, field: "latitude"))
            return nil
        }
        return GeoCoordinateConversion.decimalDegrees(degrees: degrees, minutes: minutes, seconds: seconds, isPositiveDirection: dir == "N")
    }

    // MARK: - Helpers

    private static func stripTrailingLineEndings(_ line: String) -> String {
        var result = Substring(line)
        while let last = result.last, last == "\r" || last == "\n" {
            result = result.dropLast()
        }
        return String(result)
    }

    private static func trimmingTrailingWhitespace(_ value: String) -> String {
        var result = Substring(value)
        while let last = result.last, last == " " {
            result = result.dropLast()
        }
        return String(result)
    }

}
