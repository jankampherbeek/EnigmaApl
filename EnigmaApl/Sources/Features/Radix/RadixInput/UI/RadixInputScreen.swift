//
//  RadixInputScreen.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 23/02/2026.
//

import SwiftUI
import SwiftData

private func ri(_ key: String) -> String {
    NSLocalizedString(key, tableName: "RadixInput", bundle: .main, comment: "")
}




// Reusable numeric picker that combines a TextField (type directly) with a
// chevron button that opens a popover list – HIG-compliant on macOS.
private struct NumericPickerField: View {
    let range: ClosedRange<Int>
    let fieldWidth: CGFloat
    let format: (Int) -> String
    @Binding var selection: Int
    @State private var text = ""
    @State private var showPopover = false
    @FocusState private var isFocused: Bool

    private var isValid: Bool {
        guard let value = Int(text) else { return false }
        return range.contains(value)
    }

    var body: some View {
        HStack(spacing: 0) {
            TextField("", text: $text)
                .textFieldStyle(.roundedBorder)
                .frame(width: fieldWidth)
                .multilineTextAlignment(.center)
                .focused($isFocused)
                .onAppear { text = format(selection) }
                .onChange(of: selection) { _, newValue in text = format(newValue) }
                .onChange(of: isFocused) { _, focused in
                    guard !focused else { return }
                    if isValid, let value = Int(text) {
                        selection = value
                    } else {
                        text = format(selection)
                    }
                }
            Button {
                showPopover.toggle()
            } label: {
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.leading, 3)
            .focusable(false)
            .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(range, id: \.self) { value in
                                Button {
                                    selection = value
                                    showPopover = false
                                } label: {
                                    Text(format(value))
                                        .frame(minWidth: 60, alignment: .center)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(
                                            selection == value
                                                ? Color.accentColor.opacity(0.2)
                                                : Color.clear
                                        )
                                }
                                .buttonStyle(.plain)
                                .id(value)
                            }
                        }
                    }
                    .frame(height: min(200, CGFloat(range.count) * 24 + 8))
                    .onAppear { proxy.scrollTo(selection, anchor: .center) }
                }
            }
        }
    }
}

// Reusable DMS part picker used to compose geo-coordinate input.
private struct DMSComponentPicker: View {
    let symbol: String
    let range: ClosedRange<Int>
    @Binding var selection: Int
    @State private var text = ""
    @FocusState private var isFocused: Bool

    private var isValid: Bool {
        guard let value = Int(text) else { return false }
        return range.contains(value)
    }

    var body: some View {
        HStack(spacing: 2) {
            TextField("", text: $text)
                .textFieldStyle(.roundedBorder)
                .frame(width: 40)
                .multilineTextAlignment(.center)
                .focused($isFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(!isFocused && !isValid ? Color.red : Color.clear, lineWidth: 1.5)
                )
                .onAppear { text = String(selection) }
                .onChange(of: selection) { _, newValue in text = String(newValue) }
                .onChange(of: isFocused) { _, focused in
                    guard !focused else { return }
                    if isValid, let value = Int(text) {
                        selection = value
                    } else {
                        text = String(selection)
                    }
                }
                .accessibilityLabel(symbol)
            Text(symbol)
                .foregroundStyle(.secondary)
        }
    }
}

private struct FieldBlock<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RadixInputHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    GroupBox(ri("view.radixinputscreen.aboutchart")) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(ri("view.radixinputscreen.help.aboutchart.line1"))
                            Text(ri("view.radixinputscreen.help.aboutchart.line2"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox(ri("view.radixinputscreen.location")) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(ri("view.radixinputscreen.help.location.line1"))
                            Text(ri("view.radixinputscreen.help.location.line2"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox(ri("view.radixinputscreen.datetime")) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(ri("view.radixinputscreen.help.datetime.line1"))
                            Text(ri("view.radixinputscreen.help.datetime.line2"))
                            Text(ri("view.radixinputscreen.help.datetime.line3"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .navigationTitle(ri("view.radixinputscreen.help.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(ri("view.radixinputscreen.help.close")) { dismiss() }
                }
            }
        }
    }
}

// MARK: - Section: Chart Info

private struct ChartInfoSection: View {
    @Binding var chartName: String
    @Binding var chartDescription: String
    @Binding var source: String
    @Binding var roddenRating: RoddenRating
    @Binding var chartInfoSubmitted: Bool
    @FocusState private var nameFieldFocused: Bool

    private var nameIsEmpty: Bool {
        chartName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldBlock(ri("view.radixinputscreen.name")) {
                TextField("", text: $chartName)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .adaptiveBorder()
                    .focused($nameFieldFocused)
                    .onChange(of: nameFieldFocused) { _, focused in
                        if !focused { chartInfoSubmitted = true }
                    }
                if chartInfoSubmitted && nameIsEmpty {
                    Text(ri("view.radixinputscreen.validation.nameempty"))
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            FieldBlock(ri("view.radixinputscreen.description")) {
                TextField("", text: $chartDescription)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .adaptiveBorder()
            }
            FieldBlock(ri("view.radixinputscreen.source")) {
                TextField("", text: $source)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .adaptiveBorder()
            }
            FieldBlock(ri("view.radixinputscreen.roddenrating")) {
                Picker(ri("view.radixinputscreen.roddenrating"), selection: $roddenRating) {
                    ForEach(RoddenRating.allCases) { rating in
                        Text(rating.displayText).tag(rating)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .focusable(true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Section: Location

private struct LocationSection: View {
    @Binding var locationName: String
    @Binding var latitudeDegrees: Int
    @Binding var latitudeMinutes: Int
    @Binding var latitudeSeconds: Int
    @Binding var longitudeDegrees: Int
    @Binding var longitudeMinutes: Int
    @Binding var longitudeSeconds: Int
    @Binding var latHemi: LatitudeHemisphere
    @Binding var lonHemi: LongitudeHemisphere

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldBlock(ri("view.radixinputscreen.nameoflocation")) {
                TextField("", text: $locationName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
                    .adaptiveBorder()
            }

            Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 6, verticalSpacing: 4) {
                GridRow {
                    Text(ri("view.radixinputscreen.longitude"))
                        .foregroundStyle(.secondary)
                        .gridColumnAlignment(.leading)
                    DMSComponentPicker(symbol: "°", range: 0...180, selection: $longitudeDegrees)
                    DMSComponentPicker(symbol: "′", range: 0...59, selection: $longitudeMinutes)
                    DMSComponentPicker(symbol: "″", range: 0...59, selection: $longitudeSeconds)
                    Picker(ri("view.radixinputscreen.accessibility.longitudehemisphere"), selection: $lonHemi) {
                        ForEach(LongitudeHemisphere.allCases) { hemisphere in
                            Text(LocalizedStringKey(hemisphere.rbKey)).tag(hemisphere)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .focusable(true)
                }
                GridRow {
                    Text(ri("view.radixinputscreen.latitude"))
                        .foregroundStyle(.secondary)
                    DMSComponentPicker(symbol: "°", range: 0...90, selection: $latitudeDegrees)
                    DMSComponentPicker(symbol: "′", range: 0...59, selection: $latitudeMinutes)
                    DMSComponentPicker(symbol: "″", range: 0...59, selection: $latitudeSeconds)
                    Picker(ri("view.radixinputscreen.accessibility.latitudehemisphere"), selection: $latHemi) {
                        ForEach(LatitudeHemisphere.allCases) { hemisphere in
                            Text(LocalizedStringKey(hemisphere.rbKey)).tag(hemisphere)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .focusable(true)
                }
            }
            .fixedSize()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Section: Date & Time

private struct DateTimeSection: View {
    @Binding var yearText: String
    @Binding var month: Int
    @Binding var day: Int
    @Binding var hour: Int
    @Binding var minute: Int
    @Binding var second: Int
    @Binding var offsetHour: Int
    @Binding var offsetMinute: Int
    @Binding var offsetSecond: Int
    @Binding var calendarStyle: CalendarStyle
    @Binding var yearCount: YearCount
    @Binding var utOffsetDirection: UTOffsetDirection
    @Binding var dstOption: DSTOption

    let dateValidationResult: DateComponentsValidationResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
                FieldBlock(ri("view.radixinputscreen.date")) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(ri("view.radixinputscreen.year"))
                                .foregroundStyle(.secondary)
                            TextField("", text: $yearText)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 100)
                                .adaptiveBorder()

                            Text(ri("view.radixinputscreen.month"))
                                .foregroundStyle(.secondary)
                            NumericPickerField(range: 1...12, fieldWidth: 35,
                                              format: { String($0) }, selection: $month)

                            Text(ri("view.radixinputscreen.day"))
                                .foregroundStyle(.secondary)
                            NumericPickerField(range: 1...31, fieldWidth: 35,
                                              format: { String($0) }, selection: $day)
                        }
                        .fixedSize(horizontal: true, vertical: false)

                        if let message = dateValidationResult.message {
                            Text(message)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                FieldBlock(ri("view.radixinputscreen.calendaryearcount")) {
                    HStack(spacing: 8) {
                        Picker(ri("view.radixinputscreen.calendaryearcount"), selection: $calendarStyle) {
                            ForEach(CalendarStyle.allCases) { style in
                                Text(LocalizedStringKey(style.rbKey)).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 160)
                        .labelsHidden()
                        .focusable(true)

                        Picker(ri("view.radixinputscreen.year"), selection: $yearCount) {
                            ForEach(YearCount.allCases) { count in
                                Text(LocalizedStringKey(count.rbKey)).tag(count)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .focusable(true)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
                FieldBlock(ri("view.radixinputscreen.timedst")) {
                    HStack(spacing: 8) {
                        NumericPickerField(range: 0...23, fieldWidth: 40,
                                          format: { String(format: "%02d", $0) }, selection: $hour)
                        NumericPickerField(range: 0...59, fieldWidth: 35,
                                          format: { String(format: "%02d", $0) }, selection: $minute)
                        NumericPickerField(range: 0...59, fieldWidth: 35,
                                          format: { String(format: "%02d", $0) }, selection: $second)

                        Picker(ri("view.radixinputscreen.dst"), selection: $dstOption) {
                            ForEach(DSTOption.allCases) { option in
                                Text(LocalizedStringKey(option.rbKey)).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 140)
                        .labelsHidden()
                        .focusable(true)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
                FieldBlock(ri("view.radixinputscreen.offsetut")) {
                    HStack(spacing: 8) {
                        NumericPickerField(range: 0...23, fieldWidth: 40,
                                          format: { String(format: "%02d", $0) }, selection: $offsetHour)
                        NumericPickerField(range: 0...59, fieldWidth: 35,
                                          format: { String(format: "%02d", $0) }, selection: $offsetMinute)
                        NumericPickerField(range: 0...59, fieldWidth: 35,
                                          format: { String(format: "%02d", $0) }, selection: $offsetSecond)

                        Picker(ri("view.radixinputscreen.offsetut"), selection: $utOffsetDirection) {
                            ForEach(UTOffsetDirection.allCases) { relation in
                                Text(LocalizedStringKey(relation.rbKey)).tag(relation)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 160)
                        .labelsHidden()
                        .focusable(true)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Screen

private enum AccordionSection: Hashable {
    case chartInfo, location, dateTime
}

struct RadixInputScreen: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var radixNav: RadixNavigator
    @Environment(\.modelContext) private var modelContext
    @StateObject private var inputModel = RadixInputModel()
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

    // Domain-oriented date/time input:
    // year remains free numeric text to support very large ranges and BCE use cases.
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
    @State private var showHelp = false
    @State private var showSaveWarning = false
    @State private var expandedSection: AccordionSection = .chartInfo
    @State private var chartInfoSubmitted = false
    @FocusState private var focusedHeader: AccordionSection?

    private var astronomicalYearForValidation: Int? {
        guard let enteredYear = Int(yearText) else { return nil }

        switch yearCount {
        case .astronomical:
            return enteredYear
        case .ce:
            // Civil CE does not have year 0.
            return enteredYear > 0 ? enteredYear : nil
        case .bc:
            // Convert BCE to astronomical year numbering: 1 BCE -> 0, 2 BCE -> -1.
            return enteredYear > 0 ? 1 - enteredYear : nil
        }
    }

    private var dateValidationResult: DateComponentsValidationResult {
        guard let year = astronomicalYearForValidation else {
            return DateComponentsValidationResult(
                isValid: false,
                message: ri("view.radixinputscreen.validation.invalidyear")
            )
        }

        return AstronomicalDateValidation.validateDateComponents(
            year: year,
            month: month,
            day: day,
            gregorian: calendarStyle == .gregorian
        )
    }

    private var chartNameIsEmpty: Bool {
        chartName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var canCreateRequest: Bool {
        !chartNameIsEmpty && dateValidationResult.isValid && astronomicalYearForValidation != nil
    }

    private var modelInput: RadixInputModel.Input? {
        guard let year = astronomicalYearForValidation else { return nil }

        return RadixInputModel.Input(
            astronomicalYear: year,
            month: month,
            day: day,
            gregorian: calendarStyle == .gregorian,
            hour: hour,
            minute: minute,
            second: second,
            offsetHour: offsetHour,
            offsetMinute: offsetMinute,
            offsetSecond: offsetSecond,
            utOffsetEarlier: utOffsetDirection == .earlier,
            dstActive: dstOption == .dst,
            latitudeDegrees: latitudeDegrees,
            latitudeMinutes: latitudeMinutes,
            latitudeSeconds: latitudeSeconds,
            latitudeSouth: latHemi == .south,
            longitudeDegrees: longitudeDegrees,
            longitudeMinutes: longitudeMinutes,
            longitudeSeconds: longitudeSeconds,
            longitudeWest: lonHemi == .west
        )
    }

    private func calculate() {
        guard let modelInput else { return }
        inputModel.calculate(from: modelInput)
        if let chart = inputModel.lastChart, let request = inputModel.lastRequest {
            app.latestRadixChart = chart
            radixNav.setInspector(.positions)
            saveHoroscope(julianDate: request.JulianDay)
        }
    }

    private func saveHoroscope(julianDate: Double) {
        let repository = HoroscopeRepository(context: modelContext)
        let lat = dmsToDecimal(deg: latitudeDegrees, min: latitudeMinutes, sec: latitudeSeconds, negative: latHemi == .south)
        let lon = dmsToDecimal(deg: longitudeDegrees, min: longitudeMinutes, sec: longitudeSeconds, negative: lonHemi == .west)
        do {
            let horoscope = try repository.add(
                name: chartName,
                notes: chartDescription.isEmpty ? nil : chartDescription,
                source: source.isEmpty ? nil : source,
                roddenRating: roddenRating.rawValue,
                placeName: locationName.isEmpty ? nil : locationName,
                latitude: lat,
                longitude: lon
            )
            try repository.addDateTime(
                to: horoscope,
                julianDate: julianDate,
                timeZoneIdentifier: utOffsetIdentifier(),
                originalInput: originalInputString()
            )
        } catch {
            showSaveWarning = true
        }
    }

    /// Constructs a fixed UTC-offset identifier (e.g. "+01:00") from the entered offset and DST setting.
    private func utOffsetIdentifier() -> String {
        let sign = utOffsetDirection == .earlier ? "+" : "-"
        var totalMinutes = offsetHour * 60 + offsetMinute
        if dstOption == .dst { totalMinutes += 60 }
        return String(format: "\(sign)%02d:%02d", totalMinutes / 60, totalMinutes % 60)
    }

    /// Composes a human-readable string of the original date/time input for feedback purposes.
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(ri("view.radixinputscreen.title"))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: { expandedSection = .chartInfo }) {
                    HStack(spacing: 6) {
                        Image(systemName: expandedSection == .chartInfo ? "chevron.down" : "chevron.right")
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                        Text(ri("view.radixinputscreen.aboutchart"))
                            .font(.headline)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .focusable(true)
                .focused($focusedHeader, equals: .chartInfo)
                .accessibilityAddTraits(.isHeader)

                if expandedSection == .chartInfo {
                    ChartInfoSection(
                        chartName: $chartName,
                        chartDescription: $chartDescription,
                        source: $source,
                        roddenRating: $roddenRating,
                        chartInfoSubmitted: $chartInfoSubmitted
                    )
                    .padding(.top, 4)
                }

                Button(action: {
                    chartInfoSubmitted = true
                    if !chartNameIsEmpty { expandedSection = .location }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: expandedSection == .location ? "chevron.down" : "chevron.right")
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                        Text(ri("view.radixinputscreen.location"))
                            .font(.headline)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .focusable(true)
                .focused($focusedHeader, equals: .location)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHint(chartNameIsEmpty ? ri("view.radixinputscreen.accessibility.requiresname") : "")

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
                        lonHemi: $lonHemi
                    )
                    .padding(.top, 4)
                }

                Button(action: {
                    chartInfoSubmitted = true
                    if !chartNameIsEmpty { expandedSection = .dateTime }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: expandedSection == .dateTime ? "chevron.down" : "chevron.right")
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                        Text(ri("view.radixinputscreen.datetime"))
                            .font(.headline)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .focusable(true)
                .focused($focusedHeader, equals: .dateTime)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHint(chartNameIsEmpty ? ri("view.radixinputscreen.accessibility.requiresname") : "")

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
                    )
                    .padding(.top, 4)
                }

                Button(ri("view.radixinputscreen.calculate")) {
                    calculate()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .disabled(!canCreateRequest)

                if let error = inputModel.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                if showSaveWarning {
                    Label(ri("view.radixinputscreen.warning.savefailed"), systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: focusedHeader) { _, header in
                guard let header else { return }
                switch header {
                case .chartInfo:
                    expandedSection = .chartInfo
                case .location:
                    chartInfoSubmitted = true
                    if !chartNameIsEmpty { expandedSection = .location }
                case .dateTime:
                    chartInfoSubmitted = true
                    if !chartNameIsEmpty { expandedSection = .dateTime }
                }
            }
        }
        .controlSize(.small)
        .navigationTitle(ri("view.radixinputscreen.title"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(ri("view.radixinputscreen.help.close")) {
                    radixNav.setInspector(.horoscope)
                    app.setInspectorSheet(false)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showHelp = true
                } label: {
                    Label(ri("view.radixinputscreen.help.title"), systemImage: "questionmark.circle")
                }
                .help(ri("view.radixinputscreen.help.tooltip"))
            }
        }
        .sheet(isPresented: $showHelp) {
            RadixInputHelpView()
        }
    }
}

#Preview {
    RadixInputScreen()
}
