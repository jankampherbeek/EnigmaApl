//
//  RadixEditScreen.swift
//  EnigmaApl
//

import SwiftUI
import SwiftData

private func re(_ key: String) -> String {
    NSLocalizedString(key, tableName: "RadixEdit", bundle: .main, comment: "")
}

struct RadixEditScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var radixNav: RadixNavigator
    @Environment(\.modelContext) private var modelContext

    @StateObject private var editModel: RadixEditModel

    // Form state — initialized from editModel in init
    @State private var chartName: String
    @State private var chartDescription: String
    @State private var source: String
    @State private var roddenRating: RoddenRating
    @State private var locationName: String
    @State private var latitudeDegrees: Int
    @State private var latitudeMinutes: Int
    @State private var latitudeSeconds: Int
    @State private var longitudeDegrees: Int
    @State private var longitudeMinutes: Int
    @State private var longitudeSeconds: Int
    @State private var latHemi: LatitudeHemisphere
    @State private var lonHemi: LongitudeHemisphere
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
    @State private var showHelp = false
    @State private var showSaveWarning = false
    @State private var expandedSection: AccordionSection = .chartInfo
    @State private var chartInfoSubmitted = false
    @FocusState private var focusedHeader: AccordionSection?

    init(horoscope: HoroscopeModel) {
        let model = RadixEditModel(horoscope: horoscope)
        _editModel = StateObject(wrappedValue: model)
        _chartName = State(initialValue: model.initialChartName)
        _chartDescription = State(initialValue: model.initialChartDescription)
        _source = State(initialValue: model.initialSource)
        _roddenRating = State(initialValue: model.initialRoddenRating)
        _locationName = State(initialValue: model.initialLocationName)
        _latitudeDegrees = State(initialValue: model.initialLatDegrees)
        _latitudeMinutes = State(initialValue: model.initialLatMinutes)
        _latitudeSeconds = State(initialValue: model.initialLatSeconds)
        _longitudeDegrees = State(initialValue: model.initialLonDegrees)
        _longitudeMinutes = State(initialValue: model.initialLonMinutes)
        _longitudeSeconds = State(initialValue: model.initialLonSeconds)
        _latHemi = State(initialValue: model.initialLatHemi)
        _lonHemi = State(initialValue: model.initialLonHemi)
        _yearText = State(initialValue: model.initialYearText)
        _month = State(initialValue: model.initialMonth)
        _day = State(initialValue: model.initialDay)
        _hour = State(initialValue: model.initialHour)
        _minute = State(initialValue: model.initialMinute)
        _second = State(initialValue: model.initialSecond)
        _offsetHour = State(initialValue: model.initialOffsetHour)
        _offsetMinute = State(initialValue: model.initialOffsetMinute)
        _offsetSecond = State(initialValue: 0)
        _calendarStyle = State(initialValue: model.initialCalendarStyle)
        _yearCount = State(initialValue: model.initialYearCount)
        _utOffsetDirection = State(initialValue: model.initialUTOffsetDirection)
        _dstOption = State(initialValue: model.initialDSTOption)
    }

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
    private var canApply: Bool { !chartNameIsEmpty && dateValidationResult.isValid && astronomicalYearForValidation != nil }

    private var modelInput: RadixInputModel.Input? {
        guard let year = astronomicalYearForValidation else { return nil }
        return RadixInputModel.Input(
            astronomicalYear: year, month: month, day: day, gregorian: calendarStyle == .gregorian,
            hour: hour, minute: minute, second: second,
            offsetHour: offsetHour, offsetMinute: offsetMinute, offsetSecond: offsetSecond,
            utOffsetEarlier: utOffsetDirection == .earlier, dstActive: dstOption == .dst,
            latitudeDegrees: latitudeDegrees, latitudeMinutes: latitudeMinutes, latitudeSeconds: latitudeSeconds, latitudeSouth: latHemi == .south,
            longitudeDegrees: longitudeDegrees, longitudeMinutes: longitudeMinutes, longitudeSeconds: longitudeSeconds, longitudeWest: lonHemi == .west
        )
    }

    private func applyChanges() {
        guard let input = modelInput else { return }
        editModel.calculate(from: input)
        guard let chart = editModel.lastChart, let request = editModel.lastRequest else { return }

        let lat = dmsToDecimal(deg: latitudeDegrees, min: latitudeMinutes, sec: latitudeSeconds, negative: latHemi == .south)
        let lon = dmsToDecimal(deg: longitudeDegrees, min: longitudeMinutes, sec: longitudeSeconds, negative: lonHemi == .west)

        let repository = HoroscopeRepository(context: modelContext)
        do {
            try editModel.update(
                chartName: chartName,
                chartDescription: chartDescription,
                source: source,
                roddenRating: roddenRating,
                locationName: locationName,
                latitude: lat,
                longitude: lon,
                julianDate: request.JulianDay,
                timeZoneIdentifier: utOffsetIdentifier(),
                originalInput: originalInputString(),
                repository: repository
            )
        } catch {
            showSaveWarning = true
            return
        }

        let newNamed = NamedChart(name: chartName, chart: chart)
        if let editing = chartSession.editingNamedChart {
            chartSession.replace(editing, with: newNamed)
        } else {
            chartSession.add(name: chartName, chart: chart)
        }
        chartSession.editingHoroscope = nil
        chartSession.editingNamedChart = nil
        radixNav.setInspector(.overview)
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
                Text(re("view.radixeditscreen.title"))
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
                    LocationSection(locationName: $locationName, latitudeDegrees: $latitudeDegrees, latitudeMinutes: $latitudeMinutes, latitudeSeconds: $latitudeSeconds, longitudeDegrees: $longitudeDegrees, longitudeMinutes: $longitudeMinutes, longitudeSeconds: $longitudeSeconds, latHemi: $latHemi, lonHemi: $lonHemi).padding(.top, 4)
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

                Button(re("view.radixeditscreen.apply")) { applyChanges() }
                    .buttonStyle(.borderedProminent).controlSize(.regular).disabled(!canApply)

                if let error = editModel.lastError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
                if showSaveWarning {
                    Label(re("view.radixeditscreen.savefailed"), systemImage: "exclamationmark.triangle").font(.caption).foregroundStyle(.orange)
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
        }
        .controlSize(.small)
        .navigationTitle(re("view.radixeditscreen.title"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(re("view.radixeditscreen.help.close")) {
                    chartSession.editingHoroscope = nil
                    chartSession.editingNamedChart = nil
                    radixNav.setInspector(.overview)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: {
                    Label(re("view.radixeditscreen.help.title"), systemImage: "questionmark.circle")
                }
            }
        }
        .sheet(isPresented: $showHelp) { RadixChartHelpView() }
    }
}
