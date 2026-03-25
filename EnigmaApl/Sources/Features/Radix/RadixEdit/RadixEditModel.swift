// RadixEditModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine
import SwiftData

final class RadixEditModel: ObservableObject {

    let horoscope: HoroscopeModel

    // Initial field values derived from HoroscopeModel
    let initialChartName: String
    let initialChartDescription: String
    let initialSource: String
    let initialRoddenRating: RoddenRating
    let initialLocationName: String
    let initialLatDegrees: Int
    let initialLatMinutes: Int
    let initialLatSeconds: Int
    let initialLatHemi: LatitudeHemisphere
    let initialLonDegrees: Int
    let initialLonMinutes: Int
    let initialLonSeconds: Int
    let initialLonHemi: LongitudeHemisphere
    let initialYearText: String
    let initialYearCount: YearCount
    let initialMonth: Int
    let initialDay: Int
    let initialHour: Int
    let initialMinute: Int
    let initialSecond: Int
    let initialOffsetHour: Int
    let initialOffsetMinute: Int
    let initialCalendarStyle: CalendarStyle
    let initialUTOffsetDirection: UTOffsetDirection
    let initialDSTOption: DSTOption

    @Published private(set) var lastChart: FullChart?
    @Published private(set) var lastRequest: CalcRequest?
    @Published private(set) var lastError: String?

    private let calcModel = RadixInputModel()

    init(horoscope: HoroscopeModel) {
        self.horoscope = horoscope

        // Metadata
        initialChartName = horoscope.name
        initialChartDescription = horoscope.notes ?? ""
        initialSource = horoscope.source ?? ""
        initialRoddenRating = RoddenRating(rawValue: horoscope.roddenRating) ?? .none
        initialLocationName = horoscope.placeName ?? ""

        // Lat/Lon DMS
        let (latDeg, latMin, latSec, latNeg) = Self.decimalToDMS(horoscope.latitude ?? 0)
        initialLatDegrees = latDeg
        initialLatMinutes = latMin
        initialLatSeconds = latSec
        initialLatHemi = latNeg ? .south : .north

        let (lonDeg, lonMin, lonSec, lonNeg) = Self.decimalToDMS(horoscope.longitude ?? 0)
        initialLonDegrees = lonDeg
        initialLonMinutes = lonMin
        initialLonSeconds = lonSec
        initialLonHemi = lonNeg ? .west : .east

        // Date/time from preferred dateTime's originalInput
        let preferredDT = horoscope.dateTimes.first(where: { $0.isPreferred }) ?? horoscope.dateTimes.first
        if let originalInput = preferredDT?.originalInput,
           let parsed = Self.parseOriginalInput(originalInput) {
            initialYearText = parsed.yearText
            initialYearCount = parsed.yearCount
            initialMonth = parsed.month
            initialDay = parsed.day
            initialHour = parsed.hour
            initialMinute = parsed.minute
            initialSecond = parsed.second
            initialOffsetHour = parsed.offsetHour
            initialOffsetMinute = parsed.offsetMinute
            initialCalendarStyle = parsed.calendarStyle
            initialUTOffsetDirection = parsed.utOffsetDirection
            initialDSTOption = parsed.dstOption
        } else {
            initialYearText = "2026"
            initialYearCount = .ce
            initialMonth = 1
            initialDay = 1
            initialHour = 12
            initialMinute = 0
            initialSecond = 0
            initialOffsetHour = 0
            initialOffsetMinute = 0
            initialCalendarStyle = .gregorian
            initialUTOffsetDirection = .earlier
            initialDSTOption = .noDST
        }
    }

    func calculate(from input: RadixInputModel.Input) {
        calcModel.calculate(from: input)
        lastChart = calcModel.lastChart
        lastRequest = calcModel.lastRequest
        lastError = calcModel.lastError
    }

    func update(
        chartName: String,
        chartDescription: String,
        source: String,
        roddenRating: RoddenRating,
        locationName: String,
        latitude: Double,
        longitude: Double,
        julianDate: Double,
        timeZoneIdentifier: String,
        originalInput: String,
        repository: HoroscopeRepository
    ) throws {
        horoscope.name = chartName
        horoscope.notes = chartDescription.isEmpty ? nil : chartDescription
        horoscope.source = source.isEmpty ? nil : source
        horoscope.roddenRating = roddenRating.rawValue
        horoscope.placeName = locationName.isEmpty ? nil : locationName
        horoscope.latitude = latitude
        horoscope.longitude = longitude

        if let preferred = horoscope.dateTimes.first(where: { $0.isPreferred }) {
            preferred.julianDate = julianDate
            preferred.timeZoneIdentifier = timeZoneIdentifier
            preferred.originalInput = originalInput
        }

        try repository.update(horoscope)
    }

    // MARK: - Helpers

    private struct ParsedInput {
        var yearText: String
        var yearCount: YearCount
        var month: Int
        var day: Int
        var hour: Int
        var minute: Int
        var second: Int
        var calendarStyle: CalendarStyle
        var utOffsetDirection: UTOffsetDirection
        var dstOption: DSTOption
        var offsetHour: Int
        var offsetMinute: Int
    }

    /// Parses originalInput strings formatted by RadixInputScreen.originalInputString().
    /// Format: "{year[ CE| BC]} {mm}-{dd} {HH}:{mm}:{ss} (UT{sign}{HH}:{mm}[ DST]) {Cal.}"
    private static func parseOriginalInput(_ s: String) -> ParsedInput? {
        let tokens = s.components(separatedBy: " ")
        guard tokens.count >= 5 else { return nil }

        // Calendar: last token
        let calToken = tokens.last ?? ""
        let calendarStyle: CalendarStyle = calToken.hasPrefix("Greg") ? .gregorian : .julian

        // Find date token: "mm-dd" (5 chars, one hyphen, digits on each side)
        guard let dateIdx = tokens.indices.first(where: {
            let t = tokens[$0]
            return t.count == 5 && t.contains("-")
                && t.prefix(2).allSatisfy(\.isNumber) && t.suffix(2).allSatisfy(\.isNumber)
        }) else { return nil }

        // Find time token: "hh:mm:ss" (8 chars, two colons)
        guard tokens.indices.contains(dateIdx + 1) else { return nil }
        let timeToken = tokens[dateIdx + 1]
        guard timeToken.count == 8, timeToken.filter({ $0 == ":" }).count == 2 else { return nil }

        // Parse date
        let dateParts = tokens[dateIdx].split(separator: "-")
        guard dateParts.count == 2,
              let month = Int(dateParts[0]), let day = Int(dateParts[1]) else { return nil }

        // Parse time
        let timeParts = timeToken.split(separator: ":")
        guard timeParts.count == 3,
              let hour = Int(timeParts[0]), let minute = Int(timeParts[1]),
              let second = Int(timeParts[2]) else { return nil }

        // Find UT token: starts with "(UT"
        guard let utIdx = tokens.indices.first(where: { tokens[$0].hasPrefix("(UT") }) else { return nil }

        // DST: check if next token contains "DST"
        var dstOption: DSTOption = .noDST
        if utIdx + 1 < tokens.count && tokens[utIdx + 1].contains("DST") {
            dstOption = .dst
        }

        // Extract offset string
        let utStr = tokens[utIdx].trimmingCharacters(in: CharacterSet(charactersIn: "()"))
        guard utStr.hasPrefix("UT") else { return nil }
        let offsetStr = String(utStr.dropFirst(2))  // e.g. "+01:00"
        guard offsetStr.count >= 6 else { return nil }

        let utOffsetDirection: UTOffsetDirection = offsetStr.first == "-" ? .later : .earlier
        let offsetParts = offsetStr.dropFirst().split(separator: ":")
        guard offsetParts.count >= 2,
              var offsetHour = Int(offsetParts[0]),
              var offsetMinute = Int(offsetParts[1]) else { return nil }

        // DST was baked into the stored offset — subtract 1 hour if DST was active
        if dstOption == .dst {
            let total = offsetHour * 60 + offsetMinute - 60
            offsetHour = max(0, total / 60)
            offsetMinute = max(0, total % 60)
        }

        // Parse year info (tokens before dateIdx)
        let yearTokens = Array(tokens[0..<dateIdx])
        let yearText: String
        let yearCount: YearCount
        if yearTokens.count >= 2 {
            let era = yearTokens[1]
            if era == "CE" { yearText = yearTokens[0]; yearCount = .ce }
            else if era == "BC" { yearText = yearTokens[0]; yearCount = .bc }
            else { yearText = yearTokens[0]; yearCount = .astronomical }
        } else if yearTokens.count == 1 {
            yearText = yearTokens[0]; yearCount = .astronomical
        } else { return nil }

        return ParsedInput(
            yearText: yearText, yearCount: yearCount,
            month: month, day: day,
            hour: hour, minute: minute, second: second,
            calendarStyle: calendarStyle,
            utOffsetDirection: utOffsetDirection,
            dstOption: dstOption,
            offsetHour: offsetHour, offsetMinute: offsetMinute
        )
    }

    static func decimalToDMS(_ decimal: Double) -> (degrees: Int, minutes: Int, seconds: Int, negative: Bool) {
        let negative = decimal < 0
        let absolute = abs(decimal)
        let degrees = Int(absolute)
        let minutesFrac = (absolute - Double(degrees)) * 60
        let minutes = Int(minutesFrac)
        let seconds = Int((minutesFrac - Double(minutes)) * 60)
        return (degrees, minutes, seconds, negative)
    }
}
