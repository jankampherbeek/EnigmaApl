// AdbXmlMapper.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Maps an `AdbXmlRecord` to the data needed to build Enigma's existing
/// `HoroscopeModel` / `HoroscopeDateTimeModel`. Import-only: Astro-Databank
/// XML is designed as Astro-Databank's own export format, not a general
/// interchange standard Enigma should also produce.
enum AdbXmlMapper {

    struct MappedChart {
        var name: String
        var category: String
        var roddenRating: String
        var notes: String?
        var placeName: String?
        var latitude: Double
        var longitude: Double
        var julianDate: Double
        var timeIsUnknown: Bool
        var originalInput: String
    }

    static func toMappedChart(record: AdbXmlRecord, recordNumber: Int, seWrapper: SEWrapper) -> (chart: MappedChart, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []

        let name = resolveName(record)
        let category = record.genderCode == "e" ? "event" : ""
        if record.genderCode == "m" || record.genderCode == "f" {
            messages.append(.warning(
                "Astro-Databank gender information ('\(record.genderCode ?? "")') has no equivalent field in the Enigma domain model and was not preserved.",
                recordNumber: recordNumber, field: "gender"
            ))
        }

        let (roddenRating, ratingMessages) = resolveRoddenRating(record.roddenRating, recordNumber: recordNumber)
        messages.append(contentsOf: ratingMessages)

        let placeName = resolvePlaceName(record)

        let julianDate: Double
        let timeIsUnknown: Bool
        if record.hasTime {
            timeIsUnknown = false
            let (offsetSeconds, offsetMessages) = resolveOffsetSeconds(record: record, recordNumber: recordNumber)
            messages.append(contentsOf: offsetMessages)
            guard let offsetSeconds else {
                return (MappedChart(name: name, category: category, roddenRating: roddenRating, notes: nil, placeName: placeName, latitude: 0, longitude: 0, julianDate: 0, timeIsUnknown: true, originalInput: ""), messages)
            }
            let localDate = AstronomicalDate(Year: record.year, Month: record.month, Day: record.day, Gregorian: record.isGregorian)
            let localTime = AstronomicalTime(Hour: record.hour, Minute: record.minute, Second: record.second)
            julianDate = LocalToUtJulianDay.convert(localDate: localDate, localTime: localTime, offsetSeconds: offsetSeconds, seWrapper: seWrapper)

            if let jdUt = record.jdUt, abs(jdUt - julianDate) > 0.001 {
                messages.append(.warning(
                    "The 'jd_ut' attribute (\(jdUt)) differs from the Julian Day computed from date/time/meridian (\(julianDate)) by more than rounding; the computed value was used.",
                    recordNumber: recordNumber, field: "jd_ut"
                ))
            }
        } else {
            // No birth time: julianDate conventionally represents noon, per
            // HoroscopeDateTimeModel's own documented convention for timeIsUnknown.
            timeIsUnknown = true
            let localDate = AstronomicalDate(Year: record.year, Month: record.month, Day: record.day, Gregorian: record.isGregorian)
            julianDate = seWrapper.julianDay(date: localDate, time: AstronomicalTime(Hour: 12, Minute: 0, Second: 0))
        }

        var notes: [String] = []
        if let sourceNotes = record.sourceNotes, !sourceNotes.isEmpty { notes.append(sourceNotes) }
        if let adbId = record.adbId, !adbId.isEmpty { notes.append("Astro-Databank ID: \(adbId)") }

        let chart = MappedChart(
            name: name,
            category: category,
            roddenRating: roddenRating,
            notes: notes.isEmpty ? nil : notes.joined(separator: "\n"),
            placeName: placeName,
            latitude: record.latitude ?? 0,
            longitude: record.longitude ?? 0,
            julianDate: julianDate,
            timeIsUnknown: timeIsUnknown,
            originalInput: originalInputText(for: record)
        )
        return (chart, messages)
    }

    private static func resolveName(_ record: AdbXmlRecord) -> String {
        if let sflname = record.sflname, !sflname.isEmpty { return sflname }
        if let name = record.name, !name.isEmpty { return name }
        if let birthname = record.birthname, !birthname.isEmpty { return birthname }
        return ""
    }

    private static func resolveRoddenRating(_ raw: String?, recordNumber: Int) -> (String, [ExchangeMessage]) {
        guard let raw, !raw.isEmpty else { return (RoddenRating.none.rawValue, []) }
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if let known = RoddenRating.allCases.first(where: { $0.rawValue.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            return (known.rawValue, [])
        }
        return (trimmed, [.warning(
            "Rodden rating '\(trimmed)' is not one of Enigma's known ratings; the value was kept as-is.",
            recordNumber: recordNumber, field: "roddenrating"
        )])
    }

    private static func resolvePlaceName(_ record: AdbXmlRecord) -> String? {
        let place = record.placeName ?? ""
        let country = record.countryName ?? record.countryCode ?? ""
        if place.isEmpty { return country.isEmpty ? nil : country }
        return country.isEmpty ? place : "\(place),\(country)"
    }

    /// Resolves the effective UTC offset from `ctimetype` + `stmerid`, mirroring AAF's time-type handling.
    private static func resolveOffsetSeconds(record: AdbXmlRecord, recordNumber: Int) -> (offsetSeconds: Int?, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []
        let timeType = record.timeTypeCode ?? "u"

        if timeType == "l" {
            let longitude = record.longitude ?? 0
            return (Int((longitude / 15.0 * 3600.0).rounded()), messages)
        }

        guard let stmerid = record.stmerid, let base = AdbXmlFieldParsers.parseMeridianOffsetSeconds(stmerid) else {
            messages.append(.warning(
                "No usable 'stmerid' meridian/offset was found; Universal Time (UTC+0) was assumed.",
                recordNumber: recordNumber, field: "stmerid"
            ))
            return (0, messages)
        }

        let dstSeconds: Int
        switch timeType {
        case "d", "w": dstSeconds = 3600
        case "2": dstSeconds = 7200
        case "h": dstSeconds = 1800
        case "s", "u": dstSeconds = 0
        default:
            messages.append(.warning("Unrecognized time type '\(timeType)'; treated as standard time.", recordNumber: recordNumber, field: "ctimetype"))
            dstSeconds = 0
        }
        return (base + dstSeconds, messages)
    }

    private static func originalInputText(for record: AdbXmlRecord) -> String {
        let calendar = record.isGregorian ? "g" : "j"
        let dateText = "\(record.year)-\(record.month)-\(record.day)\(calendar)"
        let timeText = record.hasTime ? String(format: "%02d:%02d:%02d", record.hour, record.minute, record.second) : "unknown time"
        return "ADB \(dateText) \(timeText) (adb_id \(record.adbId ?? "?"))"
    }
}
