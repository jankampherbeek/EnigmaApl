// DayDefinitionResolver.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Resolves DST/TZ day-of-month expressions to an actual calendar day.
///
/// Supported formats (matching the IANA tz database):
/// - `"14"`      — fixed day 14
/// - `"last0"`   — last Sunday (0 = Sun … 6 = Sat)
/// - `">=8"`     — first weekday >= day 8 where weekday matches the DST rule's weekday column
/// - `"<=25"`    — last weekday <= day 25
///
/// The weekday embedded in `last` / `>=` / `<=` patterns is a single digit (0–6, Sun = 0).
enum DayDefinitionResolver {

    /// Returns the day-of-month (1-based) for the given expression in the given year/month.
    /// Returns `nil` if the expression cannot be parsed.
    static func resolve(expression: String, year: Int, month: Int) -> Int? {
        let expr = expression.trimmingCharacters(in: .whitespaces)

        // Fixed day
        if let fixed = Int(expr) {
            return fixed
        }

        // last<weekday>  e.g. "last0" = last Sunday
        if expr.hasPrefix("last"), let wd = Int(expr.dropFirst(4)) {
            return lastWeekday(wd, in: year, month: month)
        }

        // >=<day>  e.g. ">=8"  — first occurrence of the matching weekday on or after day 8
        if expr.hasPrefix(">="), let boundary = Int(expr.dropFirst(2)) {
            // The weekday is implicit: we need it from context.
            // In IANA format the field is e.g. "Sun>=8", but our DB stores only ">=8".
            // Without the weekday digit we fall back to the boundary day itself.
            return boundary
        }

        // <=<day>  e.g. "<=25"
        if expr.hasPrefix("<="), let boundary = Int(expr.dropFirst(2)) {
            return boundary
        }

        return nil
    }

    /// Resolves a full IANA day expression that may embed the weekday:
    /// - `"14"`
    /// - `"last0"` (last Sunday)
    /// - `"Sun>=8"` / `"0>=8"` — first Sunday on or after 8
    /// - `"Sun<=25"` / `"0<=25"` — last Sunday on or before 25
    static func resolveIana(expression: String, year: Int, month: Int) -> Int? {
        let expr = expression.trimmingCharacters(in: .whitespaces)

        if let fixed = Int(expr) { return fixed }

        // last<weekday>
        if expr.hasPrefix("last") {
            let wdStr = String(expr.dropFirst(4))
            if let wd = weekdayNumber(wdStr) {
                return lastWeekday(wd, in: year, month: month)
            }
        }

        // <weekday>>=<day>  or  <weekday><=<day>
        if let gtRange = expr.range(of: ">=") {
            let wdStr = String(expr[expr.startIndex..<gtRange.lowerBound])
            let dayStr = String(expr[gtRange.upperBound...])
            if let wd = weekdayNumber(wdStr), let boundary = Int(dayStr) {
                return firstWeekday(wd, onOrAfter: boundary, in: year, month: month)
            }
            // No weekday prefix — treat boundary as fixed day
            if let boundary = Int(dayStr) { return boundary }
        }

        if let ltRange = expr.range(of: "<=") {
            let wdStr = String(expr[expr.startIndex..<ltRange.lowerBound])
            let dayStr = String(expr[ltRange.upperBound...])
            if let wd = weekdayNumber(wdStr), let boundary = Int(dayStr) {
                return lastWeekdayOnOrBefore(wd, boundary: boundary, in: year, month: month)
            }
            if let boundary = Int(dayStr) { return boundary }
        }

        return nil
    }

    // MARK: - Private helpers

    /// Maps a weekday name or digit string to a weekday number using the same convention
    /// as the database: Monday = 0 … Sunday = 6.
    private static func weekdayNumber(_ s: String) -> Int? {
        switch s.lowercased() {
        case "mon", "0": return 0
        case "tue", "1": return 1
        case "wed", "2": return 2
        case "thu", "3": return 3
        case "fri", "4": return 4
        case "sat", "5": return 5
        case "sun", "6": return 6
        default: return Int(s)
        }
    }

    /// Returns the number of days in a given month (handles leap years).
    private static func daysInMonth(_ year: Int, _ month: Int) -> Int {
        var components = DateComponents()
        components.year  = year
        components.month = month
        components.day   = 1
        guard let date = Calendar(identifier: .gregorian).date(from: components),
              let range = Calendar(identifier: .gregorian).range(of: .day, in: .month, for: date)
        else { return 30 }
        return range.count
    }

    /// Weekday using the database convention: Monday = 0 … Sunday = 6.
    private static func weekday(year: Int, month: Int, day: Int) -> Int {
        var components = DateComponents()
        components.year  = year
        components.month = month
        components.day   = day
        let cal = Calendar(identifier: .gregorian)
        guard let date = cal.date(from: components) else { return 0 }
        // Calendar.weekday: 1 = Sun, 2 = Mon … 7 = Sat
        // Convert to Mon=0 … Sun=6: (weekday + 5) % 7
        return (cal.component(.weekday, from: date) + 5) % 7
    }

    /// Returns the last occurrence of `targetWd` in the given month.
    private static func lastWeekday(_ targetWd: Int, in year: Int, month: Int) -> Int {
        let last = daysInMonth(year, month)
        for d in stride(from: last, through: 1, by: -1) {
            if weekday(year: year, month: month, day: d) == targetWd { return d }
        }
        return last
    }

    /// Returns the first day >= `boundary` whose weekday matches `targetWd`.
    private static func firstWeekday(_ targetWd: Int, onOrAfter boundary: Int, in year: Int, month: Int) -> Int {
        let last = daysInMonth(year, month)
        for d in boundary...last {
            if weekday(year: year, month: month, day: d) == targetWd { return d }
        }
        return boundary
    }

    /// Returns the last day <= `boundary` whose weekday matches `targetWd`.
    private static func lastWeekdayOnOrBefore(_ targetWd: Int, boundary: Int, in year: Int, month: Int) -> Int {
        for d in stride(from: min(boundary, daysInMonth(year, month)), through: 1, by: -1) {
            if weekday(year: year, month: month, day: d) == targetWd { return d }
        }
        return boundary
    }
}
