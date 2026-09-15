// QckMapper.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Maps between `QckRecord` (what is physically present in a QCK file) and
/// the data needed to build/read Enigma's existing `HoroscopeModel` /
/// `HoroscopeDateTimeModel`. No astrological calculation happens here beyond
/// the date/time -> Julian Day conversion every other Enigma feature already
/// uses (`SEWrapper.julianDay`), and no IANA timezone is guessed from a QCK
/// abbreviation, per the format specification.
enum QckMapper {

    /// Data needed to create a `HoroscopeModel` + preferred `HoroscopeDateTimeModel`
    /// from one imported QCK record.
    struct MappedChart {
        var name: String
        var placeName: String?
        var latitude: Double
        var longitude: Double
        var julianDate: Double
        var originalInput: String
    }

    // MARK: - Import

    static func toMappedChart(record: QckRecord, recordNumber: Int, seWrapper: SEWrapper) -> (chart: MappedChart, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []

        let localDate = AstronomicalDate(Year: record.year, Month: record.month, Day: record.day, Gregorian: true)
        let localTime = AstronomicalTime(Hour: record.hour, Minute: record.minute, Second: record.second)
        let offsetMinutes = record.effectiveUtcOffsetMinutes

        if record.isLmt {
            let longitudeDerivedMinutes = record.longitude / 15.0 * 60.0
            if abs(longitudeDerivedMinutes - Double(offsetMinutes)) > 2.0 {
                messages.append(.warning(
                    "LMT correction (\(offsetMinutes) min) differs from the longitude-derived offset (\(String(format: "%.1f", longitudeDerivedMinutes)) min) by more than rounding.",
                    recordNumber: recordNumber, field: "lmt"
                ))
            }
        } else if !record.timeZoneAbbreviation.isEmpty {
            messages.append(.warning(
                "Timezone abbreviation '\(record.timeZoneAbbreviation)' could not be translated to an IANA timezone; the numeric QCK correction was used for the calculation and the chart's timezone identifier was set to \"UTC\".",
                recordNumber: recordNumber, field: "timezone"
            ))
        }

        let julianDate = LocalToUtJulianDay.convert(localDate: localDate, localTime: localTime, offsetSeconds: offsetMinutes * 60, seWrapper: seWrapper)

        let chart = MappedChart(
            name: record.name,
            placeName: record.place.isEmpty ? nil : record.place,
            latitude: record.latitude,
            longitude: record.longitude,
            julianDate: julianDate,
            originalInput: originalInputText(for: record)
        )
        return (chart, messages)
    }

    private static func originalInputText(for record: QckRecord) -> String {
        let monthText = QckLineParser.months.first { $0.value == record.month }?.key ?? "\(record.month)"
        let ampm = record.isPM ? "PM" : "AM"
        var hour12 = record.hour % 12
        if hour12 == 0 { hour12 = 12 }
        let timeText = String(format: "%02d:%02d:%02d %@", hour12, record.minute, record.second, ampm)
        let sign = record.qckCorrectionMinutes < 0 ? "-" : "+"
        let magnitude = abs(record.qckCorrectionMinutes)
        let correctionText = String(format: "QCK %@%02d:%02d", sign, magnitude / 60, magnitude % 60)
        let tzPart = record.timeZoneAbbreviation.isEmpty ? "" : " \(record.timeZoneAbbreviation)"
        return "\(record.day) \(monthText) \(record.year), \(timeText)\(tzPart) (\(correctionText))"
    }

    // MARK: - Export

    /// Builds the QCK record for one chart. Enigma stores only the resolved
    /// Julian Day (UT) plus, optionally, an IANA timezone identifier used for
    /// display — never a separate standard/DST offset. QCK needs a fixed
    /// local offset, so export always writes the time as UT; the represented
    /// astronomical instant (the Julian Day) is therefore always preserved
    /// exactly, only the local display/timezone identity is not.
    static func toRecord(
        name: String,
        placeName: String?,
        latitude: Double,
        longitude: Double,
        julianDate: Double,
        timeZoneIdentifier: String,
        recordNumber: Int,
        seWrapper: SEWrapper
    ) -> (record: QckRecord, messages: [ExchangeMessage]) {
        var messages: [ExchangeMessage] = []
        if timeZoneIdentifier != "UTC" {
            messages.append(.warning(
                "The chart's timezone identifier '\(timeZoneIdentifier)' was not preserved; QCK requires a fixed local offset that Enigma does not store, so the time was written as UT.",
                recordNumber: recordNumber, field: "timezone"
            ))
        }

        let dateTime = seWrapper.dateFromJulianDay(julianDate, gregorian: true)
        let record = QckRecord(
            name: name,
            month: dateTime.Date.Month,
            day: dateTime.Date.Day,
            year: dateTime.Date.Year,
            hour: dateTime.Time.Hour,
            minute: dateTime.Time.Minute,
            second: dateTime.Time.Second,
            isPM: dateTime.Time.Hour >= 12,
            timeZoneAbbreviation: "",
            qckCorrectionMinutes: 0,
            longitude: longitude,
            latitude: latitude,
            place: placeName ?? ""
        )
        return (record, messages)
    }
}
