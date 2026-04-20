// TzResolver.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Resolves the full timezone + DST information for a given date/time and IANA zone name.
/// Mirrors the logic of the Windows TzHandler / DstHandler classes, but reads from enigma.db via LocationDb.
struct TzResolver {

    private let db: LocationDb
    private let seWrapper: SEWrapper

    init(db: LocationDb, seWrapper: SEWrapper) {
        self.db = db
        self.seWrapper = seWrapper
    }

    // MARK: - Public API

    /// Returns a `ZoneInfo` for the supplied local date/time in the given IANA zone.
    /// - Parameters:
    ///   - dateTime:  The local date and time (not UT).
    ///   - zoneName:  IANA zone identifier, e.g. "Europe/Amsterdam".
    ///   - longitude: Optional geographic longitude. When supplied, LMT (Local Mean Time)
    ///                zones are handled by computing offset = longitude / 15.
    func resolve(dateTime: AstronomicalDateTime, zoneName: String, longitude: Double? = nil) throws -> ZoneInfo {
        let tzRows = try db.tzDataRows(zoneName: zoneName)
        guard !tzRows.isEmpty else {
            return ZoneInfo(offsetSeconds: 0, tzName: zoneName, dstUsed: false, isInvalid: false, isAmbiguous: false)
        }

        let requestJd = julianDay(for: dateTime)
        let tzRow = applicableTzRow(tzRows, requestJd: requestJd, dateTime: dateTime)

        // LMT override
        if tzRow.format.contains("LMT") || tzRow.rule == "LMT", let lon = longitude {
            let offsetSec = Int((lon / 15.0) * 3600.0)
            return ZoneInfo(offsetSeconds: offsetSec, tzName: "LMT", dstUsed: false, isInvalid: false, isAmbiguous: false)
        }

        let stdOffsetSec = tzRow.standardOffsetSeconds
        let ruleName = tzRow.rule

        // No DST rule
        guard ruleName != "-", !ruleName.isEmpty else {
            let name = resolvedTzName(format: tzRow.format, letter: "", stdOffsetSec: stdOffsetSec)
            return ZoneInfo(offsetSeconds: stdOffsetSec, tzName: name, dstUsed: false, isInvalid: false, isAmbiguous: false)
        }

        // Resolve DST
        let dstInfo = try resolveDst(ruleName: ruleName, dateTime: dateTime, stdOffsetSec: stdOffsetSec, requestJd: requestJd)
        let totalOffset = stdOffsetSec + dstInfo.saveSeconds
        let name = resolvedTzName(format: tzRow.format, letter: dstInfo.letter, stdOffsetSec: totalOffset)

        return ZoneInfo(
            offsetSeconds: totalOffset,
            tzName:        name,
            dstUsed:       dstInfo.saveSeconds != 0,
            isInvalid:     dstInfo.isInvalid,
            isAmbiguous:   dstInfo.isAmbiguous
        )
    }

    // MARK: - TzData resolution

    /// Finds the TzData row that applies to `requestJd`.
    /// Each row's `until` date marks the *end* of validity.
    /// The last row (sentinel untilYear == 0) always matches as a fallback.
    private func applicableTzRow(_ rows: [TzDataRow], requestJd: Double, dateTime: AstronomicalDateTime) -> TzDataRow {
        for row in rows {
            // untilYear == 0 means "forever" (sentinel / last row)
            guard row.untilYear != 0 else { return row }

            let untilDay = DayDefinitionResolver.resolveIana(expression: row.untilDay, year: row.untilYear, month: row.untilMonth) ?? 1
            let untilDate = AstronomicalDate(Year: row.untilYear, Month: row.untilMonth, Day: untilDay)
            let untilTime = AstronomicalTime(Hour: row.atH, Minute: row.atM, Second: row.atS)
            let untilJd = seWrapper.julianDay(date: untilDate, time: untilTime)

            if requestJd < untilJd { return row }
        }
        return rows.last!
    }

    // MARK: - DST resolution

    private struct DstResult {
        let saveSeconds: Int
        let letter: String
        let isInvalid: Bool
        let isAmbiguous: Bool
    }

    private func resolveDst(ruleName: String, dateTime: AstronomicalDateTime, stdOffsetSec: Int, requestJd: Double) throws -> DstResult {
        let rows = try db.dstDataRows(ruleName: ruleName)
        guard !rows.isEmpty else {
            return DstResult(saveSeconds: 0, letter: "", isInvalid: false, isAmbiguous: false)
        }

        // requestJd was computed from local clock numbers treated as UT by swe_julday.
        // We compare it against transition JDs also expressed as local clock numbers
        // (i.e. UT transition time + stdOffset), so the comparison is on a consistent scale.
        let year = dateTime.Date.Year
        var events = expandedDstEvents(rows: rows, aroundYear: year, stdOffsetSec: stdOffsetSec)
        events.sort { $0.jdLocal < $1.jdLocal }

        var currentSave = 0
        var currentLetter = ""

        var isInvalid = false
        var isAmbiguous = false

        for event in events {
            if event.jdLocal > requestJd { break }

            // Detect gap (spring-forward) and overlap (fall-back) at this transition.
            let delta = event.saveSeconds - currentSave   // positive = spring forward, negative = fall back
            let transitionJd = event.jdLocal

            if delta > 0 {
                // Clocks spring forward: local times in [transition, transition + delta/86400) don't exist.
                let gapEndJd = transitionJd + Double(delta) / 86400.0
                if requestJd >= transitionJd && requestJd < gapEndJd {
                    isInvalid = true
                }
            } else if delta < 0 {
                // Clocks fall back: the local interval [transition, transition + |delta|/86400) occurs twice —
                // once before the transition (in summer time) and once after (in standard time).
                let overlapEndJd = transitionJd + Double(-delta) / 86400.0
                if requestJd >= transitionJd && requestJd < overlapEndJd {
                    isAmbiguous = true
                }
            }

            currentSave = event.saveSeconds
            currentLetter = event.letter
        }

        return DstResult(saveSeconds: currentSave, letter: currentLetter, isInvalid: isInvalid, isAmbiguous: isAmbiguous)
    }

    // MARK: - DST event expansion

    private struct DstEvent {
        /// Transition moment expressed on the same scale as requestJd (local clock numbers as JD).
        let jdLocal: Double
        let saveSeconds: Int
        let letter: String
    }

    /// Expands DstDataRows to concrete events for the years surrounding the requested year.
    /// Each event's `jdLocal` is the UT transition time shifted by `stdOffsetSec` so it can be
    /// compared directly against `requestJd` (which is also the local clock time as a JD number).
    private func expandedDstEvents(rows: [DstDataRow], aroundYear: Int, stdOffsetSec: Int) -> [DstEvent] {
        let startYear = aroundYear - 1
        let endYear   = aroundYear + 1

        var events: [DstEvent] = []
        for row in rows {
            let fromYear = row.fromYear
            let toYearResolved: Int
            switch row.toYear.lowercased() {
            case "only": toYearResolved = fromYear
            case "max":  toYearResolved = endYear
            default:     toYearResolved = Int(row.toYear) ?? fromYear
            }

            let lo = max(fromYear, startYear)
            let hi = min(toYearResolved, endYear)
            guard lo <= hi else { continue }

            for y in lo...hi {
                guard let day = DayDefinitionResolver.resolveIana(expression: row.day, year: y, month: row.month) else { continue }
                let date = AstronomicalDate(Year: y, Month: row.month, Day: day)
                let time = AstronomicalTime(Hour: row.atH, Minute: row.atM, Second: row.atS)
                // jdUt: the transition time in UT
                var jdUt = seWrapper.julianDay(date: date, time: time)
                if row.useUt.lowercased() != "u" {
                    // Time given in local wall-clock; subtract std offset to normalise to UT.
                    jdUt -= Double(stdOffsetSec) / 86400.0
                }
                // Shift to local-clock scale for comparison with requestJd.
                let jdLocal = jdUt + Double(stdOffsetSec) / 86400.0
                events.append(DstEvent(jdLocal: jdLocal, saveSeconds: row.saveSeconds, letter: row.letter))
            }
        }
        return events
    }

    // MARK: - Helpers

    private func julianDay(for dt: AstronomicalDateTime) -> Double {
        seWrapper.julianDay(date: dt.Date, time: dt.Time)
    }

    /// Formats the timezone name from the `format` column, replacing `%s` with the DST letter
    /// and `%z` / `%Z` with a numeric offset string.
    private func resolvedTzName(format: String, letter: String, stdOffsetSec: Int) -> String {
        // In IANA tz data, "-" as the DST letter means "no abbreviation change"; treat as empty.
        let effectiveLetter = letter == "-" ? "" : letter

        var result = format
        if result.contains("%s") {
            result = result.replacingOccurrences(of: "%s", with: effectiveLetter)
        }
        if result.contains("%z") || result.contains("%Z") {
            let sign   = stdOffsetSec >= 0 ? "+" : "-"
            let total  = abs(stdOffsetSec)
            let h      = total / 3600
            let m      = (total % 3600) / 60
            let offset = m == 0 ? "\(sign)\(h)" : String(format: "%@%d:%02d", sign, h, m)
            result = result
                .replacingOccurrences(of: "%z", with: offset)
                .replacingOccurrences(of: "%Z", with: offset)
        }
        return result
    }
}
