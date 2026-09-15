// AafWriter.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Writes one `AafRecord` as an "#A93"/"#B93" (+ optional metadata chunks)
/// text block. Field-based chunks are comma-separated with no quoting
/// mechanism, so any comma surviving into a field-based value is replaced
/// with a space and reported as a warning; free-text chunks (#SRC/#VIA/#COM)
/// are written verbatim, commas included.
enum AafWriter {

    static func write(record: AafRecord, recordNumber: Int) -> (text: String, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []

        let lastName = sanitizeField(record.lastName, field: "lastName", recordNumber: recordNumber, messages: &messages)
        let firstName = sanitizeField(record.firstName, field: "firstName", recordNumber: recordNumber, messages: &messages)
        let place = sanitizeField(record.place, field: "place", recordNumber: recordNumber, messages: &messages)
        let country = sanitizeField(record.country, field: "country", recordNumber: recordNumber, messages: &messages)

        let calendarSuffix = record.isGregorian ? "g" : "j"
        let dateText = "\(record.day).\(record.month).\(record.year)\(calendarSuffix)"
        let timeText = String(format: "%02d:%02d:%02d", record.hour, record.minute, record.second)

        let a93 = "#A93:\(lastName),\(firstName),\(record.type),\(dateText),\(timeText),\(place),\(country)"

        let latText = coordinateText(decimalDegrees: record.latitude, positiveChar: "n", negativeChar: "s")
        let lonText = coordinateText(decimalDegrees: record.longitude, positiveChar: "e", negativeChar: "w")
        let greenwichText = greenwichOffsetText(seconds: record.greenwichOffsetSeconds)
        let b93 = "#B93:\(record.julianDayRaw),\(latText),\(lonText),\(greenwichText),\(record.timeType)"

        var lines = [a93, b93]
        if let zoneName = record.zoneName, !zoneName.isEmpty { lines.append("#ZNAM:\(zoneName)") }
        if let source = record.source, !source.isEmpty { lines.append("#SRC:\(source)") }
        if let via = record.via, !via.isEmpty { lines.append("#VIA:\(via)") }
        if let comment = record.comment, !comment.isEmpty { lines.append("#COM:\(comment)") }

        return (lines.joined(separator: "\n"), messages)
    }

    private static func sanitizeField(_ value: String, field: String, recordNumber: Int, messages: inout [ExchangeMessage]) -> String {
        guard value.contains(",") else { return value }
        messages.append(.warning(
            "Field '\(field)' contained a comma, which AAF cannot use inside a field-based chunk; it was replaced with a space.",
            recordNumber: recordNumber, field: field
        ))
        return value.replacingOccurrences(of: ",", with: " ")
    }

    private static func coordinateText(decimalDegrees: Double, positiveChar: Character, negativeChar: Character) -> String {
        let components = GeoCoordinateConversion.components(fromDecimalDegrees: decimalDegrees)
        let dir = components.isPositiveDirection ? positiveChar : negativeChar
        if components.seconds == 0 {
            return "\(components.degrees)\(dir)\(String(format: "%02d", components.minutes))"
        }
        return "\(components.degrees)\(dir)\(String(format: "%02d", components.minutes)):\(String(format: "%02d", components.seconds))"
    }

    private static func greenwichOffsetText(seconds: Int?) -> String {
        guard let seconds else { return "*" }
        let dir: Character = seconds < 0 ? "w" : "e"
        let magnitude = abs(seconds)
        let hours = magnitude / 3600
        let minutes = (magnitude % 3600) / 60
        let secs = magnitude % 60
        if minutes == 0 && secs == 0 { return "\(hours)h\(dir)" }
        if secs == 0 { return "\(hours)h\(dir)\(String(format: "%02d", minutes))" }
        return "\(hours)h\(dir)\(String(format: "%02d", minutes)):\(String(format: "%02d", secs))"
    }
}
