// RadixInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

// MARK: - Screen

struct RadixInputScreen: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var radixNav: RadixNavigator
    @Environment(\.modelContext) private var modelContext
    @StateObject private var inputModel = RadixInputModel()
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]
    @State private var chartName: String = ""
    @State private var chartDescription = ""
    @State private var source = ""
    @State private var roddenRating: RoddenRating = .aa

    @State private var locationName: String = ""
    @State private var latitudeDegrees = 0
    @State private var latitudeMinutes = 0
    @State private var latitudeSeconds = 0
    @State private var longitudeDegrees = 0
    @State private var longitudeMinutes = 0
    @State private var longitudeSeconds = 0
    @State private var latHemi: LatitudeHemisphere = .north
    @State private var lonHemi: LongitudeHemisphere = .east

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
    @State private var selectedCity: LocationCity? = nil
    @State private var showHelp = false
    @State private var showSaveWarning = false
    @State private var expandedSection: AccordionSection = .chartInfo
    @State private var chartInfoSubmitted = false
    @FocusState private var focusedHeader: AccordionSection?

    private var astronomicalYearForValidation: Int? {
        guard let enteredYear = Int(yearText) else { return nil }
        switch yearCount {
        case .astronomical: return enteredYear
        case .ce: return enteredYear > 0 ? enteredYear : nil
        case .bc: return enteredYear > 0 ? 1 - enteredYear : nil
        }
    }

    private var dateValidationResult: DateComponentsValidationResult {
        guard let year = astronomicalYearForValidation else {
            return DateComponentsValidationResult(isValid: false, message: ri("view.radixinputscreen.validation.invalidyear"))
        }
        return AstronomicalDateValidation.validateDateComponents(year: year, month: month, day: day, gregorian: calendarStyle == .gregorian)
    }

    private var chartNameIsEmpty: Bool { chartName.trimmingCharacters(in: .whitespaces).isEmpty }
    private var canCreateRequest: Bool { !chartNameIsEmpty && dateValidationResult.isValid && astronomicalYearForValidation != nil }

    private var configFactors: [Factors] {
        guard let config = activeConfigs.first else { return [] }
        return config.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor }
    }

    private var modelInput: RadixInputModel.Input? {
        guard let year = astronomicalYearForValidation else { return nil }
        var input = RadixInputModel.Input(
            astronomicalYear: year, month: month, day: day, gregorian: calendarStyle == .gregorian,
            hour: hour, minute: minute, second: second,
            offsetHour: offsetHour, offsetMinute: offsetMinute, offsetSecond: offsetSecond,
            utOffsetEarlier: utOffsetDirection == .earlier, dstActive: dstOption == .dst,
            latitudeDegrees: latitudeDegrees, latitudeMinutes: latitudeMinutes, latitudeSeconds: latitudeSeconds, latitudeSouth: latHemi == .south,
            longitudeDegrees: longitudeDegrees, longitudeMinutes: longitudeMinutes, longitudeSeconds: longitudeSeconds, longitudeWest: lonHemi == .west
        )
        if !configFactors.isEmpty { input.factorsToUse = configFactors }
        input.calculationConfig = activeConfigs.first?.calculationConfig ?? CalculationConfig()
        return input
    }

    private func recalculateOffset() {
        guard let city = selectedCity,
              let year = astronomicalYearForValidation else { return }
        let dateTime = AstronomicalDateTime(
            Date: AstronomicalDate(Year: year, Month: month, Day: day, Gregorian: calendarStyle == .gregorian),
            Time: AstronomicalTime(Hour: hour, Minute: minute, Second: second)
        )
        guard let orch = try? LocationOrchestrator(seWrapper: SEWrapper()),
              let zone = try? orch.timezoneInfo(tzName: city.timezoneName, dateTime: dateTime, longitude: city.longitude)
        else { return }
        let totalSec = abs(zone.offsetSeconds)
        offsetHour = totalSec / 3600
        offsetMinute = (totalSec % 3600) / 60
        utOffsetDirection = zone.offsetSeconds >= 0 ? .later : .earlier
        dstOption = zone.dstUsed ? .dst : .noDST
    }

    private func calculate() {
        guard let modelInput else { return }
        inputModel.calculate(from: modelInput)
        if let chart = inputModel.lastChart, let request = inputModel.lastRequest {
            chartSession.add(name: chartName, chart: chart, baseRequest: request, timeZoneOffsetHours: utOffsetDecimalHours())
            radixNav.setInspector(.positions)
            saveHoroscope(julianDate: request.JulianDay)
        }
    }

    private func utOffsetDecimalHours() -> Double {
        var totalMinutes = offsetHour * 60 + offsetMinute
        if dstOption == .dst { totalMinutes += 60 }
        let hours = Double(totalMinutes) / 60.0
        return utOffsetDirection == .earlier ? hours : -hours
    }

    private func saveHoroscope(julianDate: Double) {
        let repository = HoroscopeRepository(context: modelContext)
        let lat = dmsToDecimal(deg: latitudeDegrees, min: latitudeMinutes, sec: latitudeSeconds, negative: latHemi == .south)
        let lon = dmsToDecimal(deg: longitudeDegrees, min: longitudeMinutes, sec: longitudeSeconds, negative: lonHemi == .west)
        do {
            let horoscope = try repository.add(name: chartName, notes: chartDescription.isEmpty ? nil : chartDescription, source: source.isEmpty ? nil : source, roddenRating: roddenRating.rawValue, placeName: locationName.isEmpty ? nil : locationName, latitude: lat, longitude: lon)
            try repository.addDateTime(to: horoscope, julianDate: julianDate, timeZoneIdentifier: utOffsetIdentifier(), originalInput: originalInputString())
        } catch { showSaveWarning = true }
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
        case .ce: yearDisplay = "\(yearText) CE"
        case .bc: yearDisplay = "\(yearText) BC"
        }
        let cal = calendarStyle == .gregorian ? "Greg." : "Jul."
        let offset = utOffsetIdentifier()
        let dst = dstOption == .dst ? " DST" : ""
        return String(format: "%@ %02d-%02d %02d:%02d:%02d (UT%@%@) %@", yearDisplay, month, day, hour, minute, second, offset, dst, cal)
    }

    private func dmsToDecimal(deg: Int, min: Int, sec: Int, negative: Bool) -> Double {
        let value = Double(deg) + Double(min) / 60.0 + Double(sec) / 3600.0
        return negative ? -value : value
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(ri("view.radixinputscreen.title"))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: { expandedSection = .chartInfo }) {
                    HStack(spacing: 6) {
                        Image(systemName: expandedSection == .chartInfo ? "chevron.down" : "chevron.right").imageScale(.small).foregroundStyle(.secondary)
                        Text(ri("view.radixinputscreen.aboutchart")).font(.headline)
                        Spacer()
                    }
                }
                .buttonStyle(.plain).focusable(true).focused($focusedHeader, equals: .chartInfo).accessibilityAddTraits(.isHeader)

                if expandedSection == .chartInfo {
                    ChartInfoSection(chartName: $chartName, chartDescription: $chartDescription, source: $source, roddenRating: $roddenRating, chartInfoSubmitted: $chartInfoSubmitted).padding(.top, 4)
                }

                Button(action: { chartInfoSubmitted = true; if !chartNameIsEmpty { expandedSection = .location } }) {
                    HStack(spacing: 6) {
                        Image(systemName: expandedSection == .location ? "chevron.down" : "chevron.right").imageScale(.small).foregroundStyle(.secondary)
                        Text(ri("view.radixinputscreen.location")).font(.headline)
                        Spacer()
                    }
                }
                .buttonStyle(.plain).focusable(true).focused($focusedHeader, equals: .location).accessibilityAddTraits(.isHeader).accessibilityHint(chartNameIsEmpty ? ri("view.radixinputscreen.accessibility.requiresname") : "")

                if expandedSection == .location {
                    LocationSection(locationName: $locationName, latitudeDegrees: $latitudeDegrees, latitudeMinutes: $latitudeMinutes, latitudeSeconds: $latitudeSeconds, longitudeDegrees: $longitudeDegrees, longitudeMinutes: $longitudeMinutes, longitudeSeconds: $longitudeSeconds, latHemi: $latHemi, lonHemi: $lonHemi, offsetHour: $offsetHour, offsetMinute: $offsetMinute, utOffsetDirection: $utOffsetDirection, dstOption: $dstOption, selectedCity: $selectedCity).padding(.top, 4)
                }

                Button(action: { chartInfoSubmitted = true; if !chartNameIsEmpty { expandedSection = .dateTime } }) {
                    HStack(spacing: 6) {
                        Image(systemName: expandedSection == .dateTime ? "chevron.down" : "chevron.right").imageScale(.small).foregroundStyle(.secondary)
                        Text(ri("view.radixinputscreen.datetime")).font(.headline)
                        Spacer()
                    }
                }
                .buttonStyle(.plain).focusable(true).focused($focusedHeader, equals: .dateTime).accessibilityAddTraits(.isHeader).accessibilityHint(chartNameIsEmpty ? ri("view.radixinputscreen.accessibility.requiresname") : "")

                if expandedSection == .dateTime {
                    DateTimeSection(yearText: $yearText, month: $month, day: $day, hour: $hour, minute: $minute, second: $second, offsetHour: $offsetHour, offsetMinute: $offsetMinute, offsetSecond: $offsetSecond, calendarStyle: $calendarStyle, yearCount: $yearCount, utOffsetDirection: $utOffsetDirection, dstOption: $dstOption, dateValidationResult: dateValidationResult).padding(.top, 4)
                }

                Button(ri("view.radixinputscreen.calculate")) { calculate() }
                    .buttonStyle(.borderedProminent).controlSize(.regular).disabled(!canCreateRequest)

                if let error = inputModel.lastError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
                if showSaveWarning {
                    Label(ri("view.radixinputscreen.warning.savefailed"), systemImage: "exclamationmark.triangle").font(.caption).foregroundStyle(.orange)
                }
            }
            .frame(maxWidth: 900, alignment: .leading).padding().frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: focusedHeader) { _, header in
                guard let header else { return }
                switch header {
                case .chartInfo: expandedSection = .chartInfo
                case .location: chartInfoSubmitted = true; if !chartNameIsEmpty { expandedSection = .location }
                case .dateTime: chartInfoSubmitted = true; if !chartNameIsEmpty { expandedSection = .dateTime }
                }
            }
            .onChange(of: yearText) { _, _ in recalculateOffset() }
            .onChange(of: month)    { _, _ in recalculateOffset() }
            .onChange(of: day)      { _, _ in recalculateOffset() }
        }
        .controlSize(.small)
        .navigationTitle(ri("view.radixinputscreen.title"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(ri("view.radixinputscreen.help.close")) { radixNav.setInspector(.horoscope); app.setInspectorSheet(false) }
            }
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: { Label(ri("view.radixinputscreen.help.title"), systemImage: "questionmark.circle") }
                .help(ri("view.radixinputscreen.help.tooltip"))
            }
        }
        .sheet(isPresented: $showHelp) { RadixChartHelpView() }
    }
}
