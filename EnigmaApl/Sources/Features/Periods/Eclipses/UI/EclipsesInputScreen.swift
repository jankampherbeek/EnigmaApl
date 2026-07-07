// EclipsesInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func ec(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Eclipses", bundle: .main, comment: "")
}

struct EclipsesInputScreen: View {
    @EnvironmentObject private var eclipsesModel: EclipsesModel

    private let seWrapper = SEWrapper()

    // MARK: - Start date
    @State private var startYearText  = "2024"
    @State private var startMonth     = 1
    @State private var startDay       = 1
    @State private var startCalendar  : CalendarStyle = .gregorian
    @State private var startYearCount : YearCount = .ce

    // MARK: - End date
    @State private var endYearText  = "2026"
    @State private var endMonth     = 12
    @State private var endDay       = 31
    @State private var endCalendar  : CalendarStyle = .gregorian
    @State private var endYearCount : YearCount = .ce

    // MARK: - Eclipse type
    @State private var eclipseSearchType: EclipseSearchType = .all

    // MARK: - Location (optional)
    @State private var locationName      = ""
    @State private var latitudeDegrees   = 0
    @State private var latitudeMinutes   = 0
    @State private var latitudeSeconds   = 0
    @State private var longitudeDegrees  = 0
    @State private var longitudeMinutes  = 0
    @State private var longitudeSeconds  = 0
    @State private var latHemi           : LatitudeHemisphere  = .north
    @State private var lonHemi           : LongitudeHemisphere = .east
    @State private var selectedCity      : LocationCity?       = nil
    // Time-zone bindings required by LocationSection but unused for eclipse calculation
    @State private var offsetHour        = 0
    @State private var offsetMinute      = 0
    @State private var utOffsetDirection : UTOffsetDirection = .earlier
    @State private var dstOption         : DSTOption = .noDST

    @State private var showHelp = false

    // MARK: - Computed properties

    private var startAstrYear: Int? {
        guard let y = Int(startYearText) else { return nil }
        switch startYearCount {
        case .astronomical: return y
        case .ce:           return y > 0 ? y : nil
        case .bc:           return y > 0 ? 1 - y : nil
        }
    }

    private var endAstrYear: Int? {
        guard let y = Int(endYearText) else { return nil }
        switch endYearCount {
        case .astronomical: return y
        case .ce:           return y > 0 ? y : nil
        case .bc:           return y > 0 ? 1 - y : nil
        }
    }

    private var startValidation: DateComponentsValidationResult {
        guard let y = startAstrYear else {
            return DateComponentsValidationResult(isValid: false,
                                                  message: ec(EclipsesKeys.invalidYear))
        }
        return AstronomicalDateValidation.validateDateComponents(
            year: y, month: startMonth, day: startDay,
            gregorian: startCalendar == .gregorian)
    }

    private var endValidation: DateComponentsValidationResult {
        guard let y = endAstrYear else {
            return DateComponentsValidationResult(isValid: false,
                                                  message: ec(EclipsesKeys.invalidYear))
        }
        return AstronomicalDateValidation.validateDateComponents(
            year: y, month: endMonth, day: endDay,
            gregorian: endCalendar == .gregorian)
    }

    private var endAfterStart: Bool {
        guard startValidation.isValid, endValidation.isValid,
              let sy = startAstrYear, let ey = endAstrYear else { return true }
        let midnight = AstronomicalTime(HourDecimal: 0.0)
        let jdStart = seWrapper.julianDay(
            date: AstronomicalDate(Year: sy, Month: startMonth, Day: startDay,
                                  Gregorian: startCalendar == .gregorian),
            time: midnight)
        let jdEnd = seWrapper.julianDay(
            date: AstronomicalDate(Year: ey, Month: endMonth, Day: endDay,
                                  Gregorian: endCalendar == .gregorian),
            time: midnight)
        return jdEnd > jdStart
    }

    private var canCalculate: Bool {
        startValidation.isValid && endValidation.isValid && endAfterStart
    }

    private var hasCoordinates: Bool {
        latitudeDegrees != 0 || latitudeMinutes != 0 || latitudeSeconds != 0 ||
        longitudeDegrees != 0 || longitudeMinutes != 0 || longitudeSeconds != 0
    }

    private var decimalLat: Double {
        let v = Double(latitudeDegrees) + Double(latitudeMinutes) / 60.0 + Double(latitudeSeconds) / 3600.0
        return latHemi == .south ? -v : v
    }

    private var decimalLon: Double {
        let v = Double(longitudeDegrees) + Double(longitudeMinutes) / 60.0 + Double(longitudeSeconds) / 3600.0
        return lonHemi == .west ? -v : v
    }

    private func coordText(_ value: Double, isLat: Bool) -> String {
        let abs = Swift.abs(value)
        let deg = Int(abs)
        let minFrac = (abs - Double(deg)) * 60.0
        let min = Int(minFrac)
        let sec = Int((minFrac - Double(min)) * 60.0)
        let hemi: String
        if isLat { hemi = value >= 0 ? "N" : "S" }
        else      { hemi = value >= 0 ? "E" : "W" }
        return String(format: "%d° %02d′ %02d″ %@", deg, min, sec, hemi)
    }

    // MARK: - Calculate

    private func calculate() {
        guard let sy = startAstrYear, let ey = endAstrYear else { return }
        let midnight = AstronomicalTime(HourDecimal: 0.0)
        let jdStart = seWrapper.julianDay(
            date: AstronomicalDate(Year: sy, Month: startMonth, Day: startDay,
                                  Gregorian: startCalendar == .gregorian),
            time: midnight)
        let jdEnd = seWrapper.julianDay(
            date: AstronomicalDate(Year: ey, Month: endMonth, Day: endDay,
                                  Gregorian: endCalendar == .gregorian),
            time: midnight)

        let orchGeoLon: Double? = hasCoordinates ? decimalLon : nil
        let orchGeoLat: Double? = hasCoordinates ? decimalLat : nil

        let orchestrator = EclipsesOrchestrator(seWrapper: seWrapper)
        let events = orchestrator.findEclipses(
            startJD: jdStart, endJD: jdEnd,
            type: eclipseSearchType,
            geoLon: orchGeoLon, geoLat: orchGeoLat)

        eclipsesModel.hasLocation = hasCoordinates
        eclipsesModel.results = events
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(ec(EclipsesKeys.title))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Start date
                GroupBox(ec(EclipsesKeys.startDate)) {
                    dateRow(yearText: $startYearText, month: $startMonth, day: $startDay,
                            calendar: $startCalendar, yearCount: $startYearCount,
                            validation: startValidation)
                }

                // End date
                GroupBox(ec(EclipsesKeys.endDate)) {
                    dateRow(yearText: $endYearText, month: $endMonth, day: $endDay,
                            calendar: $endCalendar, yearCount: $endYearCount,
                            validation: endValidation)
                }

                if startValidation.isValid && endValidation.isValid && !endAfterStart {
                    Text(ec(EclipsesKeys.endDateOrder))
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                // Eclipse type
                FieldBlock(ec(EclipsesKeys.eclipseType)) {
                    Picker(ec(EclipsesKeys.eclipseType), selection: $eclipseSearchType) {
                        Text(ec(EclipsesKeys.solar)).tag(EclipseSearchType.solar)
                        Text(ec(EclipsesKeys.lunar)).tag(EclipseSearchType.lunar)
                        Text(ec(EclipsesKeys.all)).tag(EclipseSearchType.all)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .focusable(true)
                }

                // Location (optional)
                GroupBox(ec(EclipsesKeys.location)) {
                    LocationSection(
                        locationName:      $locationName,
                        latitudeDegrees:   $latitudeDegrees,
                        latitudeMinutes:   $latitudeMinutes,
                        latitudeSeconds:   $latitudeSeconds,
                        longitudeDegrees:  $longitudeDegrees,
                        longitudeMinutes:  $longitudeMinutes,
                        longitudeSeconds:  $longitudeSeconds,
                        latHemi:           $latHemi,
                        lonHemi:           $lonHemi,
                        offsetHour:        $offsetHour,
                        offsetMinute:      $offsetMinute,
                        utOffsetDirection: $utOffsetDirection,
                        dstOption:         $dstOption,
                        selectedCity:      $selectedCity,
                        onCitySelected:    { city in applyCity(city) }
                    )
                    if hasCoordinates {
                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ec(EclipsesKeys.coordinates))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(coordText(decimalLat, isLat: true))
                                .font(.system(.body, design: .monospaced))
                            Text(coordText(decimalLon, isLat: false))
                                .font(.system(.body, design: .monospaced))
                        }
                        .padding(.top, 4)
                    }
                }

                // Calculate button
                Button(ec(EclipsesKeys.calculate)) { calculate() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .disabled(!canCalculate)
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: selectedCity) { _, city in
            if let city { applyCity(city) }
        }
        .controlSize(.small)
        .navigationTitle(ec(EclipsesKeys.title))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: {
                    Label("Help", systemImage: "questionmark.circle")
                }
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: ec(EclipsesKeys.help))
        }
    }

    // MARK: - Helpers

    private func decimalToDms(_ decimal: Double) -> (Int, Int, Int, Bool) {
        let negative = decimal < 0
        let abs = Swift.abs(decimal)
        let degrees = Int(abs)
        let minutesFrac = (abs - Double(degrees)) * 60
        let minutes = Int(minutesFrac)
        let seconds = Int((minutesFrac - Double(minutes)) * 60)
        return (degrees, minutes, seconds, negative)
    }

    private func applyCity(_ city: LocationCity) {
        let (latDeg, latMin, latSec, latNeg) = decimalToDms(city.latitude)
        latitudeDegrees = latDeg
        latitudeMinutes = latMin
        latitudeSeconds = latSec
        latHemi = latNeg ? .south : .north
        let (lonDeg, lonMin, lonSec, lonNeg) = decimalToDms(city.longitude)
        longitudeDegrees = lonDeg
        longitudeMinutes = lonMin
        longitudeSeconds = lonSec
        lonHemi = lonNeg ? .west : .east
    }

    // MARK: - Date row helper

    @ViewBuilder
    private func dateRow(
        yearText: Binding<String>,
        month:    Binding<Int>,
        day:      Binding<Int>,
        calendar: Binding<CalendarStyle>,
        yearCount: Binding<YearCount>,
        validation: DateComponentsValidationResult
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(ec(EclipsesKeys.year)).foregroundStyle(.secondary)
                TextField("", text: yearText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 100)
                    .adaptiveBorder()
                Text(ec(EclipsesKeys.month)).foregroundStyle(.secondary)
                NumericPickerField(range: 1...12, fieldWidth: 35,
                                   format: { String($0) }, selection: month)
                Text(ec(EclipsesKeys.day)).foregroundStyle(.secondary)
                NumericPickerField(range: 1...31, fieldWidth: 35,
                                   format: { String($0) }, selection: day)
            }
            .fixedSize(horizontal: true, vertical: false)

            HStack(spacing: 8) {
                Picker(ec(EclipsesKeys.calendar), selection: calendar) {
                    ForEach(CalendarStyle.allCases) { style in
                        Text(LocalizedStringKey(style.rbKey)).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)
                .labelsHidden()
                .focusable(true)

                Picker(ec(EclipsesKeys.yearCount), selection: yearCount) {
                    ForEach(YearCount.allCases) { count in
                        Text(LocalizedStringKey(count.rbKey)).tag(count)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .focusable(true)
            }
            .fixedSize(horizontal: true, vertical: false)

            if let msg = validation.message {
                Text(msg).font(.caption).foregroundStyle(.red)
            }
        }
    }
}
