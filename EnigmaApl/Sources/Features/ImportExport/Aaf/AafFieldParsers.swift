// AafFieldParsers.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Field-level parsers for the AAF'97 #A93/#B93 chunks. Each parser is
/// independently testable and reports its own warnings/fatal errors.
enum AafFieldParsers {

    struct DateResult {
        let day: Int
        let month: Int
        let year: Int
        let isGregorian: Bool
    }

    /// Parses "day.month.year[g|j]", e.g. "29.1.1953", "24.12.-6g", "7.10.1582j".
    /// BCE years use astronomical year numbering already, matching `AstronomicalDate.Year` directly.
    /// Without a calendar suffix, AAF's own fallback rule applies: before the
    /// Gregorian cutover (1582-10-15) defaults to Julian, on/after defaults to Gregorian.
    static func parseDate(_ raw: String, recordNumber: Int, messages: inout [ExchangeMessage]) -> DateResult? {
        let parts = raw.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
        guard parts.count == 3, let day = Int(parts[0]), let month = Int(parts[1]) else {
            messages.append(.fatal("Invalid AAF date: '\(raw)'.", recordNumber: recordNumber, field: "date"))
            return nil
        }

        var yearText = parts[2]
        var suffix: Character?
        if let last = yearText.last, last == "g" || last == "G" || last == "j" || last == "J" {
            suffix = Character(last.lowercased())
            yearText.removeLast()
        }
        guard let year = Int(yearText) else {
            messages.append(.fatal("Invalid AAF year: '\(parts[2])'.", recordNumber: recordNumber, field: "date"))
            return nil
        }

        let isGregorian = suffix.map { $0 == "g" } ?? !GregorianCutover.isBeforeCutover(year: year, month: month, day: day)

        let validation = AstronomicalDateValidation.validateDateComponents(year: year, month: month, day: day, gregorian: isGregorian)
        guard validation.isValid else {
            messages.append(.fatal(validation.message ?? "Invalid date.", recordNumber: recordNumber, field: "date"))
            return nil
        }

        return DateResult(day: day, month: month, year: year, isGregorian: isGregorian)
    }

    struct TimeResult {
        let hour: Int
        let minute: Int
        let second: Int
    }

    /// Parses civil time: "16:55", "22:30:12", "19", "22h30:12". No AM/PM.
    static func parseTime(_ raw: String, recordNumber: Int, messages: inout [ExchangeMessage]) -> TimeResult? {
        let normalized = raw.replacingOccurrences(of: "h", with: ":").replacingOccurrences(of: "H", with: ":")
        let parts = normalized.split(separator: ":").map(String.init)
        guard !parts.isEmpty, parts.count <= 3, let hour = Int(parts[0]) else {
            messages.append(.fatal("Invalid AAF time: '\(raw)'.", recordNumber: recordNumber, field: "time"))
            return nil
        }
        let minute = parts.count >= 2 ? Int(parts[1]) : 0
        let second = parts.count >= 3 ? Int(parts[2]) : 0
        guard let minute, let second else {
            messages.append(.fatal("Invalid AAF time: '\(raw)'.", recordNumber: recordNumber, field: "time"))
            return nil
        }
        guard hour >= 0 && hour <= 23, minute >= 0 && minute <= 59, second >= 0 && second <= 59 else {
            messages.append(.fatal("AAF time out of range: '\(raw)'.", recordNumber: recordNumber, field: "time"))
            return nil
        }
        return TimeResult(hour: hour, minute: minute, second: second)
    }

    /// Parses a latitude "DDnMM[:SS]"/"DDsMM[:SS]" or longitude "DDDeMM[:SS]"/"DDDwMM[:SS]".
    /// `positiveChar`/`negativeChar` are lowercase direction letters (n/s or e/w).
    static func parseCoordinate(
        _ raw: String, positiveChar: Character, negativeChar: Character,
        isLongitude: Bool, recordNumber: Int, field: String, messages: inout [ExchangeMessage]
    ) -> Double? {
        let lower = raw.lowercased()
        guard let directionIndex = lower.firstIndex(where: { $0 == positiveChar || $0 == negativeChar }) else {
            messages.append(.fatal("Invalid AAF coordinate: '\(raw)'.", recordNumber: recordNumber, field: field))
            return nil
        }
        let degreesText = String(lower[lower.startIndex..<directionIndex])
        let isPositive = lower[directionIndex] == positiveChar
        var rest = String(lower[lower.index(after: directionIndex)...])

        var secondsText = "0"
        if let colonIndex = rest.firstIndex(of: ":") {
            secondsText = String(rest[rest.index(after: colonIndex)...])
            rest = String(rest[rest.startIndex..<colonIndex])
        }
        let minutesText = rest

        guard let degrees = Int(degreesText), let minutes = Int(minutesText), let seconds = Int(secondsText) else {
            messages.append(.fatal("Invalid AAF coordinate: '\(raw)'.", recordNumber: recordNumber, field: field))
            return nil
        }

        let isValid = isLongitude
            ? GeoCoordinateConversion.isValidLongitude(degrees: degrees, minutes: minutes, seconds: seconds)
            : GeoCoordinateConversion.isValidLatitude(degrees: degrees, minutes: minutes, seconds: seconds)
        guard isValid else {
            messages.append(.fatal("AAF coordinate out of range: '\(raw)'.", recordNumber: recordNumber, field: field))
            return nil
        }

        return GeoCoordinateConversion.decimalDegrees(degrees: degrees, minutes: minutes, seconds: seconds, isPositiveDirection: isPositive)
    }

    /// Parses the Greenwich offset field: "1he", "5hw", "5he30", "0he32:06", or "*" (nil).
    /// East is positive modern UTC-offset, no sign inversion (unlike QCK).
    static func parseGreenwichOffset(_ raw: String, recordNumber: Int, messages: inout [ExchangeMessage]) -> Int?? {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed == "*" { return .some(nil) }

        let lower = trimmed.lowercased()
        guard let hIndex = lower.firstIndex(of: "h") else {
            messages.append(.fatal("Invalid AAF Greenwich offset: '\(raw)'.", recordNumber: recordNumber, field: "greenwichOffset"))
            return nil
        }
        let hoursText = String(lower[lower.startIndex..<hIndex])
        let afterH = lower[lower.index(after: hIndex)...]
        guard let directionChar = afterH.first, directionChar == "e" || directionChar == "w" else {
            messages.append(.fatal("Invalid AAF Greenwich offset direction: '\(raw)'.", recordNumber: recordNumber, field: "greenwichOffset"))
            return nil
        }
        var rest = String(afterH.dropFirst())

        var secondsText = "0"
        if let colonIndex = rest.firstIndex(of: ":") {
            secondsText = String(rest[rest.index(after: colonIndex)...])
            rest = String(rest[rest.startIndex..<colonIndex])
        }
        let minutesText = rest.isEmpty ? "0" : rest

        guard let hours = Int(hoursText), let minutes = Int(minutesText), let seconds = Int(secondsText) else {
            messages.append(.fatal("Invalid AAF Greenwich offset: '\(raw)'.", recordNumber: recordNumber, field: "greenwichOffset"))
            return nil
        }
        let magnitude = hours * 3600 + minutes * 60 + seconds
        return .some(directionChar == "e" ? magnitude : -magnitude)
    }
}
