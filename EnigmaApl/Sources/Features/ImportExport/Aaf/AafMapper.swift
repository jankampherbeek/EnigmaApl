// AafMapper.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Maps between `AafRecord` and the data needed to build/read Enigma's
/// existing `HoroscopeModel` / `HoroscopeDateTimeModel`. No astrological
/// calculation happens here beyond the date/time -> Julian Day conversion
/// every other Enigma feature already uses.
///
/// `EventModel` is deliberately never created from AAF: an Enigma event must
/// already be linked to one or more existing charts (an application-level
/// invariant), and a bare AAF record carries no such link. AAF's "type"
/// field ('e' for event, 'l' for country, 'o' for organisation) is instead
/// preserved in `HoroscopeModel.category`, an existing free-text field whose
/// own doc comment already gives "natal"/"mundane"/"horary" as example
/// values of exactly this kind.
enum AafMapper {

    struct MappedChart {
        var name: String
        var category: String
        var source: String?
        var notes: String?
        var placeName: String?
        var latitude: Double
        var longitude: Double
        var julianDate: Double
        var originalInput: String
        /// Enigma's own chart id, from the "#ENID" extension chunk. Nil when
        /// absent (a file from another AAF tool, or an older Enigma export),
        /// in which case the orchestrator generates a fresh id.
        var id: UUID?
    }

    // MARK: - Import

    static func toMappedChart(record: AafRecord, recordNumber: Int, seWrapper: SEWrapper) -> (chart: MappedChart, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []

        let (offsetSeconds, offsetMessages) = resolveOffsetSeconds(record: record, recordNumber: recordNumber)
        messages.append(contentsOf: offsetMessages)
        guard let offsetSeconds else {
            // Fatal already appended; the caller drops this record. A dummy
            // instant is still produced so the (chart, messages) tuple type stays simple;
            // callers must check for a fatal message before using `chart`.
            return (MappedChart(name: "", category: "", placeName: nil, latitude: 0, longitude: 0, julianDate: 0, originalInput: "", id: nil), messages)
        }

        let localDate = AstronomicalDate(Year: record.year, Month: record.month, Day: record.day, Gregorian: record.isGregorian)
        let localTime = AstronomicalTime(Hour: record.hour, Minute: record.minute, Second: record.second)
        let julianDate = LocalToUtJulianDay.convert(localDate: localDate, localTime: localTime, offsetSeconds: offsetSeconds, seWrapper: seWrapper)

        if record.julianDayRaw != "*", let providedJd = Double(record.julianDayRaw) {
            if abs(providedJd - julianDate) > 0.001 {
                messages.append(.warning(
                    "The '#B93' Julian Day (\(providedJd)) differs from the Julian Day computed from date/time/offset (\(julianDate)) by more than rounding; the computed value was used.",
                    recordNumber: recordNumber, field: "julianDay"
                ))
            }
        }

        if record.type == "m" || record.type == "f" || record.type == "w" {
            messages.append(.warning(
                "AAF gender information ('\(record.type)') has no equivalent field in the Enigma domain model and was not preserved.",
                recordNumber: recordNumber, field: "type"
            ))
        }

        let name = combinedName(lastName: record.lastName, firstName: record.firstName)
        let category = categoryFor(type: record.type)

        var notes = record.comment
        if let via = record.via, !via.isEmpty {
            let viaLine = "Via: \(via)"
            notes = notes.map { "\($0)\n\(viaLine)" } ?? viaLine
        }

        let place = record.place
        let country = record.country
        let placeName: String?
        if place.isEmpty {
            placeName = nil
        } else if country.isEmpty || country == "*" {
            placeName = place
        } else {
            placeName = "\(place),\(country)"
        }

        let chart = MappedChart(
            name: name,
            category: category,
            source: (record.source?.isEmpty ?? true) ? nil : record.source,
            notes: notes,
            placeName: placeName,
            latitude: record.latitude,
            longitude: record.longitude,
            julianDate: julianDate,
            originalInput: originalInputText(for: record),
            id: record.enigmaId
        )
        return (chart, messages)
    }

    private static func combinedName(lastName: String, firstName: String) -> String {
        let last = lastName == "*" ? "" : lastName
        let first = (firstName == "*" || firstName.isEmpty) ? "" : firstName
        if first.isEmpty { return last }
        if last.isEmpty { return first }
        return "\(first) \(last)"
    }

    private static func categoryFor(type: String) -> String {
        switch type {
        case "e": return "event"
        case "l": return "country"
        case "o": return "organisation"
        default: return ""
        }
    }

    private static func resolveOffsetSeconds(record: AafRecord, recordNumber: Int) -> (offsetSeconds: Int?, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []
        switch record.timeType {
        case "l":
            return (Int((record.longitude / 15.0 * 3600.0).rounded()), messages)
        case "m":
            if let greenwich = record.greenwichOffsetSeconds { return (greenwich, messages) }
            return (Int((record.longitude / 15.0 * 3600.0).rounded()), messages)
        default:
            guard let base = record.greenwichOffsetSeconds else {
                messages.append(.fatal(
                    "Greenwich offset is unknown ('*') and time type '\(record.timeType)' is not LMT; the instant cannot be computed.",
                    recordNumber: recordNumber, field: "greenwichOffset"
                ))
                return (nil, messages)
            }
            let dstSeconds: Int
            switch record.timeType {
            case "1", "w": dstSeconds = 3600
            case "2": dstSeconds = 7200
            case "h": dstSeconds = 1800
            case "0", "": dstSeconds = 0
            default:
                messages.append(.warning("Unrecognized AAF time type '\(record.timeType)'; treated as standard time.", recordNumber: recordNumber, field: "timeType"))
                dstSeconds = 0
            }
            return (base + dstSeconds, messages)
        }
    }

    private static func originalInputText(for record: AafRecord) -> String {
        let calendar = record.isGregorian ? "g" : "j"
        let dateText = "\(record.day).\(record.month).\(record.year)\(calendar)"
        let timeText = String(format: "%02d:%02d:%02d", record.hour, record.minute, record.second)
        return "AAF \(dateText) \(timeText) (type \(record.type), timeType \(record.timeType))"
    }

    // MARK: - Export

    /// Builds the AAF record for one chart. Enigma stores only the resolved
    /// Julian Day (UT) and, optionally, an IANA timezone identifier used for
    /// display — never a separate standard/DST offset. AAF export therefore
    /// always writes a zero Greenwich offset with time type "0" (standard
    /// time); the represented astronomical instant is always preserved
    /// exactly, only the local display/timezone identity is not.
    static func toRecord(
        id: UUID,
        name: String,
        category: String,
        source: String?,
        notes: String?,
        placeName: String?,
        latitude: Double,
        longitude: Double,
        julianDate: Double,
        timeZoneIdentifier: String,
        recordNumber: Int,
        seWrapper: SEWrapper
    ) -> (record: AafRecord, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []
        if timeZoneIdentifier != "UTC" {
            messages.append(.warning(
                "The chart's timezone identifier '\(timeZoneIdentifier)' was not preserved; AAF export always writes UT with a zero Greenwich offset.",
                recordNumber: recordNumber, field: "timezone"
            ))
        }

        let (lastName, firstName) = splitName(name)
        let type = typeFor(category: category)

        // HoroscopeModel has no separate country field (unlike EventModel), so
        // import merges "place,country" into one placeName string. AAF's
        // dedicated country field cannot be reconstructed from that reliably
        // (a comma may just be part of the place name, e.g. "Staten Island,
        // New York"), so export always writes country "*" and instead
        // sanitizes any comma out of the place text itself, per the format's
        // own example ("Staten Island, New York" -> "Staten Island (New York)").
        let rawPlace = placeName ?? ""
        let place = sanitizePlace(rawPlace)
        let country = "*"
        if rawPlace.contains(",") {
            messages.append(.warning(
                "Place '\(rawPlace)' contains a comma, which AAF cannot use as a field separator; it was rewritten to '\(place)'.",
                recordNumber: recordNumber, field: "place"
            ))
        }

        let dateTime = seWrapper.dateFromJulianDay(julianDate, gregorian: true)

        let record = AafRecord(
            lastName: lastName,
            firstName: firstName,
            type: type,
            day: dateTime.Date.Day, month: dateTime.Date.Month, year: dateTime.Date.Year, isGregorian: true,
            hour: dateTime.Time.Hour, minute: dateTime.Time.Minute, second: dateTime.Time.Second,
            place: place,
            country: country,
            julianDayRaw: "*",
            latitude: latitude,
            longitude: longitude,
            greenwichOffsetSeconds: 0,
            timeType: "0",
            zoneName: "UTC",
            source: (source?.isEmpty ?? true) ? nil : source,
            via: nil,
            comment: (notes?.isEmpty ?? true) ? nil : notes,
            enigmaId: id
        )
        return (record, messages)
    }

    /// Heuristic inverse of `combinedName`: "Last, First" or "First Last" ->
    /// (last, first). Enigma stores a single free-text name, so this split is
    /// necessarily a best effort; it is documented, tested, and never crashes.
    private static func splitName(_ name: String) -> (lastName: String, firstName: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return ("*", "*") }
        if let commaIndex = trimmed.firstIndex(of: ",") {
            let last = trimmed[trimmed.startIndex..<commaIndex].trimmingCharacters(in: .whitespaces)
            let first = trimmed[trimmed.index(after: commaIndex)...].trimmingCharacters(in: .whitespaces)
            return (last.isEmpty ? "*" : last, first.isEmpty ? "*" : first)
        }
        if let spaceIndex = trimmed.lastIndex(of: " ") {
            let first = trimmed[trimmed.startIndex..<spaceIndex].trimmingCharacters(in: .whitespaces)
            let last = trimmed[trimmed.index(after: spaceIndex)...].trimmingCharacters(in: .whitespaces)
            return (last.isEmpty ? "*" : last, first.isEmpty ? "*" : first)
        }
        return (trimmed, "*")
    }

    private static func typeFor(category: String) -> String {
        switch category.lowercased() {
        case "event": return "e"
        case "country": return "l"
        case "organisation": return "o"
        default: return "*"
        }
    }

    /// AAF has no CSV-style quoting, so a comma inside a free field must be
    /// sanitized; the format spec's own example turns "Staten Island, New
    /// York" into "Staten Island (New York)".
    private static func sanitizePlace(_ place: String) -> String {
        guard place.contains(",") else { return place }
        let parts = place.split(separator: ",", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 2, !parts[1].isEmpty else {
            return place.replacingOccurrences(of: ",", with: " ")
        }
        return "\(parts[0]) (\(parts[1]))"
    }
}
