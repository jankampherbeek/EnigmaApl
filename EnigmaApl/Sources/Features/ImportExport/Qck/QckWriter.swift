// QckWriter.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Writes one `QckRecord` as a 100-character fixed-width QCK line. Truncation
/// of name or place is never silent: it is always reported as a warning.
/// The exporter always writes a normal 12-hour time (e.g. "12:00:00 AM"),
/// never the historical "00:00:00 PM" form the parser tolerates on import.
enum QckWriter {

    private static let monthAbbreviations: [Int: String] = [
        1: "JAN", 2: "FEB", 3: "MAR", 4: "APR", 5: "MAY", 6: "JUN",
        7: "JUL", 8: "AUG", 9: "SEP", 10: "OCT", 11: "NOV", 12: "DEC"
    ]

    /// Returns the 100-character line, or `nil` with a fatal message when the
    /// record cannot be represented in QCK at all (e.g. year out of range).
    static func write(record: QckRecord, recordNumber: Int) -> (line: String?, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []

        guard record.year >= -9999 && record.year <= 99999 else {
            messages.append(.fatal("Year \(record.year) is outside the range QCK can represent (-9999...99999); record skipped.", recordNumber: recordNumber, field: "year"))
            return (nil, messages)
        }
        guard let monthText = monthAbbreviations[record.month] else {
            messages.append(.fatal("Month \(record.month) is not valid; record skipped.", recordNumber: recordNumber, field: "month"))
            return (nil, messages)
        }

        let name = fixedWidth(record.name, width: 23, field: "name", recordNumber: recordNumber, messages: &messages)
        let dayText = String(format: "%3d", record.day)
        let yearText = String(format: "%5d", record.year)
        let timeText = formattedTime(hour: record.hour, minute: record.minute, second: record.second) + " "

        let tzText = String(record.timeZoneAbbreviation.prefix(3)).padding(toLength: 3, withPad: " ", startingAt: 0)

        let correctionSign = record.qckCorrectionMinutes < 0 ? "-" : "+"
        let correctionMagnitude = abs(record.qckCorrectionMinutes)
        let correctionText = String(format: "%@%02d:%02d", correctionSign, correctionMagnitude / 60, correctionMagnitude % 60)

        let lonComponents = GeoCoordinateConversion.components(fromDecimalDegrees: record.longitude)
        let longitudeText = String(
            format: "%03d%@%02d'%02d ",
            lonComponents.degrees, lonComponents.isPositiveDirection ? "E" : "W", lonComponents.minutes, lonComponents.seconds
        )

        let latComponents = GeoCoordinateConversion.components(fromDecimalDegrees: record.latitude)
        let latitudeText = String(
            format: "%02d%@%02d'%02d ",
            latComponents.degrees, latComponents.isPositiveDirection ? "N" : "S", latComponents.minutes, latComponents.seconds
        )

        let place = fixedWidth(record.place, width: 25, field: "place", recordNumber: recordNumber, messages: &messages)

        let line = name + monthText + dayText + "," + yearText + timeText + tzText + correctionText + longitudeText + latitudeText + place
        assert(line.count == 100)
        return (line, messages)
    }

    private static func formattedTime(hour: Int, minute: Int, second: Int) -> String {
        var hour12 = hour % 12
        if hour12 == 0 { hour12 = 12 }
        let ampm = hour >= 12 ? "PM" : "AM"
        return String(format: "%02d:%02d:%02d %@", hour12, minute, second, ampm)
    }

    /// Left-aligns and pads `value` to `width`, truncating and warning when longer.
    private static func fixedWidth(_ value: String, width: Int, field: String, recordNumber: Int, messages: inout [ExchangeMessage]) -> String {
        if value.count > width {
            messages.append(.warning(
                "Field '\(field)' was truncated from \(value.count) to \(width) characters: '\(value)' -> '\(String(value.prefix(width)))'.",
                recordNumber: recordNumber, field: field
            ))
            return String(value.prefix(width))
        }
        return value.padding(toLength: width, withPad: " ", startingAt: 0)
    }
}
