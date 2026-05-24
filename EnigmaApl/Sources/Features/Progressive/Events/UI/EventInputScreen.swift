// EventInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "EventInput", bundle: .main, comment: "")
}

struct EventInputScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var model = EventInputModel()

    let horoscope: HoroscopeModel
    var onCreated: (() -> Void)?

    // Event fields
    @State private var eventTitle = ""
    @State private var eventDescription = ""
    @State private var titleSubmitted = false

    // Location fields
    @State private var locationName = ""
    @State private var latitudeDegrees = 0
    @State private var latitudeMinutes = 0
    @State private var latitudeSeconds = 0
    @State private var longitudeDegrees = 0
    @State private var longitudeMinutes = 0
    @State private var longitudeSeconds = 0
    @State private var latHemi: LatitudeHemisphere = .north
    @State private var lonHemi: LongitudeHemisphere = .east
    @State private var selectedCity: LocationCity? = nil

    // Date/time fields
    @State private var yearText = "2026"
    @State private var month = 1
    @State private var day = 1
    @State private var hour = 12
    @State private var minute = 0
    @State private var second = 0
    @State private var offsetHour = 0
    @State private var offsetMinute = 0
    @State private var offsetSecond = 0
    @State private var calendarStyle: CalendarStyle = .gregorian
    @State private var yearCount: YearCount = .ce
    @State private var utOffsetDirection: UTOffsetDirection = .later
    @State private var dstOption: DSTOption = .noDST

    // UI state
    @State private var expandedSection: AccordionSection = .location
    @State private var showHelp = false
    @FocusState private var focusedHeader: AccordionSection?

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
                                                  message: t(EventInputKeys.validationInvalidYear))
        }
        return AstronomicalDateValidation.validateDateComponents(
            year: year, month: month, day: day, gregorian: calendarStyle == .gregorian
        )
    }

    private var titleIsEmpty: Bool {
        eventTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var canCreate: Bool {
        !titleIsEmpty && dateValidationResult.isValid && astronomicalYear != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(t(EventInputKeys.title))
                    .font(.title2.weight(.semibold))

                FieldBlock(t(EventInputKeys.eventTitle)) {
                    TextField("", text: $eventTitle)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                        .adaptiveBorder()
                }
                if titleSubmitted && titleIsEmpty {
                    Text(t(EventInputKeys.validationTitleEmpty))
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                FieldBlock(t(EventInputKeys.eventDescription)) {
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
                        Text(t(EventInputKeys.location)).font(.headline)
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
                        selectedCity: $selectedCity
                    ).padding(.top, 4)
                }

                // Date & Time accordion
                Button(action: { expandedSection = .dateTime }) {
                    HStack(spacing: 6) {
                        Image(systemName: expandedSection == .dateTime ? "chevron.down" : "chevron.right")
                            .imageScale(.small).foregroundStyle(.secondary)
                        Text(t(EventInputKeys.dateTime)).font(.headline)
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

                Button(t(EventInputKeys.create)) {
                    titleSubmitted = true
                    if canCreate { saveEvent() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .disabled(!canCreate)

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
        .navigationTitle(t(EventInputKeys.title))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(t(EventInputKeys.cancel)) { dismiss() }
            }
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: {
                    Label(t(EventInputKeys.helpTitle), systemImage: "questionmark.circle")
                }
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(EventInputKeys.help))
        }
    }

    // MARK: - Helpers

    private func recalculateOffset() {
        guard let city = selectedCity,
              let year = astronomicalYear else { return }
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

    private func saveEvent() {
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

        let success = model.createEvent(
            title: eventTitle,
            eventDescription: eventDescription.isEmpty ? nil : eventDescription,
            julianDate: jd,
            timeZoneIdentifier: utOffsetIdentifier(),
            originalInput: originalInputString(),
            placeName: hasLocation ? locationName : nil,
            latitude: lat,
            longitude: lon,
            horoscope: horoscope,
            context: modelContext
        )
        if success {
            onCreated?()
            dismiss()
        }
    }
}
