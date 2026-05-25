// EventEditScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "EventEdit", bundle: .main, comment: "")
}

struct EventEditScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var model: EventEditModel

    let event: EventModel
    var onUpdated: (() -> Void)?

    // Event fields
    @State private var eventTitle: String
    @State private var eventDescription: String
    @State private var titleSubmitted: Bool

    // Location fields
    @State private var locationName: String
    @State private var country: String
    @State private var latitudeDegrees: Int
    @State private var latitudeMinutes: Int
    @State private var latitudeSeconds: Int
    @State private var longitudeDegrees: Int
    @State private var longitudeMinutes: Int
    @State private var longitudeSeconds: Int
    @State private var latHemi: LatitudeHemisphere
    @State private var lonHemi: LongitudeHemisphere
    @State private var selectedCity: LocationCity?

    // Date/time fields
    @State private var yearText: String
    @State private var month: Int
    @State private var day: Int
    @State private var hour: Int
    @State private var minute: Int
    @State private var second: Int
    @State private var offsetHour: Int
    @State private var offsetMinute: Int
    @State private var offsetSecond: Int
    @State private var calendarStyle: CalendarStyle
    @State private var yearCount: YearCount
    @State private var utOffsetDirection: UTOffsetDirection
    @State private var dstOption: DSTOption

    // UI state
    @State private var expandedSection: AccordionSection
    @State private var showHelp: Bool
    @FocusState private var focusedHeader: AccordionSection?

    // MARK: - Init

    init(event: EventModel, onUpdated: (() -> Void)? = nil) {
        self.event = event
        self.onUpdated = onUpdated
        _model = StateObject(wrappedValue: EventEditModel())

        // Reconstruct local date/time from UT Julian Day and stored offset.
        let (dir, offH, offM) = Self.parseTZ(event.timeZoneIdentifier)
        let offsetFraction = Double(offH * 3600 + offM * 60) / 86_400.0
        let localJD = dir == .later
            ? event.julianDate + offsetFraction
            : event.julianDate - offsetFraction
        let localDT = SEWrapper().dateFromJulianDay(localJD)

        // Derive year text and count from astronomical year.
        let astroYear = localDT.Date.Year
        let yCount: YearCount
        let yText: String
        if astroYear > 0 {
            yCount = .ce
            yText  = String(astroYear)
        } else {
            // 0 = 1 BC, -1 = 2 BC, etc.
            yCount = .bc
            yText  = String(1 - astroYear)
        }

        // Decompose optional decimal coordinates to DMS.
        let (latDeg, latMin, latSec, latNeg) = event.latitude.map(Self.toDms) ?? (0, 0, 0, false)
        let (lonDeg, lonMin, lonSec, lonNeg) = event.longitude.map(Self.toDms) ?? (0, 0, 0, false)

        // Initialise @State from derived values.
        _eventTitle       = State(initialValue: event.title)
        _eventDescription = State(initialValue: event.eventDescription ?? "")
        _titleSubmitted   = State(initialValue: false)

        _locationName      = State(initialValue: event.location ?? event.placeName ?? "")
        _country           = State(initialValue: event.country ?? "")
        _latitudeDegrees   = State(initialValue: latDeg)
        _latitudeMinutes   = State(initialValue: latMin)
        _latitudeSeconds   = State(initialValue: latSec)
        _longitudeDegrees  = State(initialValue: lonDeg)
        _longitudeMinutes  = State(initialValue: lonMin)
        _longitudeSeconds  = State(initialValue: lonSec)
        _latHemi           = State(initialValue: latNeg ? .south : .north)
        _lonHemi           = State(initialValue: lonNeg ? .west  : .east)
        _selectedCity      = State(initialValue: nil)

        _yearText          = State(initialValue: yText)
        _month             = State(initialValue: localDT.Date.Month)
        _day               = State(initialValue: localDT.Date.Day)
        _hour              = State(initialValue: localDT.Time.Hour)
        _minute            = State(initialValue: localDT.Time.Minute)
        _second            = State(initialValue: localDT.Time.Second)
        _offsetHour        = State(initialValue: offH)
        _offsetMinute      = State(initialValue: offM)
        _offsetSecond      = State(initialValue: 0)
        _calendarStyle     = State(initialValue: .gregorian)
        _yearCount         = State(initialValue: yCount)
        _utOffsetDirection = State(initialValue: dir)
        _dstOption         = State(initialValue: .noDST)

        _expandedSection   = State(initialValue: .dateTime)
        _showHelp          = State(initialValue: false)
    }

    // MARK: - Computed

    private var astronomicalYear: Int? {
        guard let year = Int(yearText) else { return nil }
        switch yearCount {
        case .astronomical: return year
        case .ce:           return year > 0 ? year : nil
        case .bc:           return year > 0 ? 1 - year : nil
        }
    }

    private var dateValidationResult: DateComponentsValidationResult {
        guard let year = astronomicalYear else {
            return DateComponentsValidationResult(isValid: false,
                                                  message: t(EventEditKeys.validationInvalidYear))
        }
        return AstronomicalDateValidation.validateDateComponents(
            year: year, month: month, day: day, gregorian: calendarStyle == .gregorian
        )
    }

    private var titleIsEmpty: Bool {
        eventTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var canSave: Bool {
        !titleIsEmpty && dateValidationResult.isValid && astronomicalYear != nil
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(t(EventEditKeys.title))
                    .font(.title2.weight(.semibold))

                FieldBlock(t(EventEditKeys.eventTitle)) {
                    TextField("", text: $eventTitle)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                        .adaptiveBorder()
                }
                if titleSubmitted && titleIsEmpty {
                    Text(t(EventEditKeys.validationTitleEmpty))
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                FieldBlock(t(EventEditKeys.eventDescription)) {
                    TextField("", text: $eventDescription)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                        .adaptiveBorder()
                }

                // Location accordion
                Button(action: { expandedSection = .location }) {
                    HStack(spacing: 6) {
                        Image(systemName: expandedSection == .location ? "chevron.down" : "chevron.right")
                            .imageScale(.small).foregroundStyle(.secondary)
                        Text(t(EventEditKeys.location)).font(.headline)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .focusable(true)
                .focused($focusedHeader, equals: .location)
                .accessibilityAddTraits(.isHeader)

                if expandedSection == .location {
                    LocationSection(
                        locationName: $locationName,
                        latitudeDegrees: $latitudeDegrees,
                        latitudeMinutes: $latitudeMinutes,
                        latitudeSeconds: $latitudeSeconds,
                        longitudeDegrees: $longitudeDegrees,
                        longitudeMinutes: $longitudeMinutes,
                        longitudeSeconds: $longitudeSeconds,
                        latHemi: $latHemi,
                        lonHemi: $lonHemi,
                        offsetHour: $offsetHour,
                        offsetMinute: $offsetMinute,
                        utOffsetDirection: $utOffsetDirection,
                        dstOption: $dstOption,
                        selectedCity: $selectedCity,
                        initialCountry: event.country,
                        initialCity: event.location ?? event.placeName,
                        selectedCountryName: $country
                    ).padding(.top, 4)
                }

                // Date & Time accordion
                Button(action: { expandedSection = .dateTime }) {
                    HStack(spacing: 6) {
                        Image(systemName: expandedSection == .dateTime ? "chevron.down" : "chevron.right")
                            .imageScale(.small).foregroundStyle(.secondary)
                        Text(t(EventEditKeys.dateTime)).font(.headline)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .focusable(true)
                .focused($focusedHeader, equals: .dateTime)
                .accessibilityAddTraits(.isHeader)

                if expandedSection == .dateTime {
                    DateTimeSection(
                        yearText: $yearText,
                        month: $month,
                        day: $day,
                        hour: $hour,
                        minute: $minute,
                        second: $second,
                        offsetHour: $offsetHour,
                        offsetMinute: $offsetMinute,
                        offsetSecond: $offsetSecond,
                        calendarStyle: $calendarStyle,
                        yearCount: $yearCount,
                        utOffsetDirection: $utOffsetDirection,
                        dstOption: $dstOption,
                        dateValidationResult: dateValidationResult
                    ).padding(.top, 4)
                }

                Button(t(EventEditKeys.save)) {
                    titleSubmitted = true
                    if canSave { saveChanges() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .disabled(!canSave)

                if let error = model.errorMessage {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: focusedHeader) { _, header in
                guard let header else { return }
                switch header {
                case .chartInfo: break
                case .location:  expandedSection = .location
                case .dateTime:  expandedSection = .dateTime
                }
            }
            .onChange(of: yearText) { _, _ in recalculateOffset() }
            .onChange(of: month)    { _, _ in recalculateOffset() }
            .onChange(of: day)      { _, _ in recalculateOffset() }
        }
        .controlSize(.small)
        .navigationTitle(t(EventEditKeys.title))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(t(EventEditKeys.cancel)) { dismiss() }
            }
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: {
                    Label(t(EventEditKeys.helpTitle), systemImage: "questionmark.circle")
                }
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(EventEditKeys.help))
        }
    }

    // MARK: - Helpers

    private func recalculateOffset() {
        guard let city = selectedCity, let year = astronomicalYear else { return }
        let dateTime = AstronomicalDateTime(
            Date: AstronomicalDate(Year: year, Month: month, Day: day, Gregorian: calendarStyle == .gregorian),
            Time: AstronomicalTime(Hour: hour, Minute: minute, Second: second)
        )
        guard let orch = try? LocationOrchestrator(seWrapper: SEWrapper()),
              let zone = try? orch.timezoneInfo(tzName: city.timezoneName,
                                                dateTime: dateTime,
                                                longitude: city.longitude)
        else { return }
        let totalSec = abs(zone.offsetSeconds)
        offsetHour = totalSec / 3600
        offsetMinute = (totalSec % 3600) / 60
        utOffsetDirection = zone.offsetSeconds >= 0 ? .later : .earlier
        dstOption = zone.dstUsed ? .dst : .noDST
    }

    private func utOffsetIdentifier() -> String {
        let sign = utOffsetDirection == .earlier ? "+" : "-"
        var totalMinutes = offsetHour * 60 + offsetMinute
        if dstOption == .dst { totalMinutes += 60 }
        return String(format: "\(sign)%02d:%02d", totalMinutes / 60, totalMinutes % 60)
    }

    private func originalInputString() -> String {
        let yearDisplay: String
        switch yearCount {
        case .astronomical: yearDisplay = yearText
        case .ce:           yearDisplay = "\(yearText) CE"
        case .bc:           yearDisplay = "\(yearText) BC"
        }
        let cal = calendarStyle == .gregorian ? "Greg." : "Jul."
        let offset = utOffsetIdentifier()
        let dst = dstOption == .dst ? " DST" : ""
        return String(format: "%@ %02d-%02d %02d:%02d:%02d (UT%@%@) %@",
                      yearDisplay, month, day, hour, minute, second, offset, dst, cal)
    }

    private func dmsToDecimal(deg: Int, min: Int, sec: Int, negative: Bool) -> Double {
        let value = Double(deg) + Double(min) / 60.0 + Double(sec) / 3600.0
        return negative ? -value : value
    }

    private func saveChanges() {
        guard let year = astronomicalYear else { return }

        let jd = model.computeJulianDay(
            astronomicalYear: year, month: month, day: day, gregorian: calendarStyle == .gregorian,
            hour: hour, minute: minute, second: second,
            offsetHour: offsetHour, offsetMinute: offsetMinute, offsetSecond: offsetSecond,
            utOffsetEarlier: utOffsetDirection == .earlier, dstActive: dstOption == .dst
        )

        let hasLocation = !locationName.trimmingCharacters(in: .whitespaces).isEmpty
        let lat: Double? = hasLocation ? dmsToDecimal(deg: latitudeDegrees, min: latitudeMinutes, sec: latitudeSeconds, negative: latHemi == .south) : nil
        let lon: Double? = hasLocation ? dmsToDecimal(deg: longitudeDegrees, min: longitudeMinutes, sec: longitudeSeconds, negative: lonHemi == .west) : nil

        let success = model.updateEvent(
            event: event,
            title: eventTitle,
            eventDescription: eventDescription.isEmpty ? nil : eventDescription,
            julianDate: jd,
            timeZoneIdentifier: utOffsetIdentifier(),
            originalInput: originalInputString(),
            placeName: hasLocation ? locationName : nil,
            latitude: lat,
            longitude: lon,
            country: country.trimmingCharacters(in: .whitespaces).isEmpty ? nil : country,
            location: hasLocation ? locationName : nil,
            context: modelContext
        )
        if success {
            onUpdated?()
            dismiss()
        }
    }

    // MARK: - Static helpers for init

    /// Parses a stored timezone identifier like "+01:00" or "-05:30".
    /// Convention: "+" → .earlier (local behind UT), "-" → .later (local ahead of UT).
    private static func parseTZ(_ tzId: String) -> (UTOffsetDirection, Int, Int) {
        guard !tzId.isEmpty else { return (.later, 0, 0) }
        let dir: UTOffsetDirection = tzId.hasPrefix("+") ? .earlier : .later
        let tail = String(tzId.dropFirst())
        let parts = tail.split(separator: ":")
        let h = Int(parts.first ?? "") ?? 0
        let m = parts.count > 1 ? (Int(parts[1]) ?? 0) : 0
        return (dir, h, m)
    }

    /// Converts a decimal coordinate to degrees, minutes, seconds, and a negative flag.
    private static func toDms(_ decimal: Double) -> (Int, Int, Int, Bool) {
        let negative = decimal < 0
        let abs = Swift.abs(decimal)
        let deg  = Int(abs)
        let mf   = (abs - Double(deg)) * 60
        let min  = Int(mf)
        let sec  = Int((mf - Double(min)) * 60)
        return (deg, min, sec, negative)
    }
}
