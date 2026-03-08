//
//  RadixInputScreen.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 23/02/2026.
//

import SwiftUI




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
                .onChange(of: selection) { text = String($0) }
                .onChange(of: isFocused) { focused in
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
    let title: LocalizedStringKey
    let content: Content

    init(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
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
                    GroupBox(LocalizedStringKey("view.radixinputscreen.aboutchart")) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Use Name, Description and Source to identify your chart.")
                            Text("Rodden Rating indicates source reliability.")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox(LocalizedStringKey("view.radixinputscreen.location")) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Enter longitude and latitude in degrees, minutes and seconds.")
                            Text("Use O/W for longitude hemisphere and N/Z for latitude hemisphere.")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox(LocalizedStringKey("view.radixinputscreen.datetime")) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Year count supports CE/BCE and astronomical numbering.")
                            Text("Offset UT converts local time to Universal Time.")
                            Text("Use DST when daylight saving was active at the chart moment.")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .navigationTitle("Help")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
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
            FieldBlock(LocalizedStringKey("view.radixinputscreen.name")) {
                TextField("", text: $chartName)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .adaptiveBorder()
                    .focused($nameFieldFocused)
                    .onChange(of: nameFieldFocused) { focused in
                        if !focused { chartInfoSubmitted = true }
                    }
                if chartInfoSubmitted && nameIsEmpty {
                    Text(LocalizedStringKey("view.radixinputscreen.validation.nameempty"))
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            FieldBlock(LocalizedStringKey("view.radixinputscreen.description")) {
                TextField("", text: $chartDescription)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .adaptiveBorder()
            }
            FieldBlock(LocalizedStringKey("view.radixinputscreen.source")) {
                TextField("", text: $source)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .adaptiveBorder()
            }
            FieldBlock(LocalizedStringKey("view.radixinputscreen.roddenrating")) {
                Picker(LocalizedStringKey("view.radixinputscreen.roddenrating"), selection: $roddenRating) {
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
            FieldBlock(LocalizedStringKey("view.radixinputscreen.nameoflocation")) {
                TextField("", text: $locationName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
                    .adaptiveBorder()
            }

            Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 6, verticalSpacing: 4) {
                GridRow {
                    Text(LocalizedStringKey("view.radixinputscreen.longitude"))
                        .foregroundStyle(.secondary)
                        .gridColumnAlignment(.leading)
                    DMSComponentPicker(symbol: "°", range: 0...180, selection: $longitudeDegrees)
                    DMSComponentPicker(symbol: "′", range: 0...59, selection: $longitudeMinutes)
                    DMSComponentPicker(symbol: "″", range: 0...59, selection: $longitudeSeconds)
                    Picker("Longitude Hemisphere", selection: $lonHemi) {
                        ForEach(LongitudeHemisphere.allCases) { hemisphere in
                            Text(LocalizedStringKey(hemisphere.rawValue)).tag(hemisphere)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .focusable(true)
                }
                GridRow {
                    Text(LocalizedStringKey("view.radixinputscreen.latitude"))
                        .foregroundStyle(.secondary)
                    DMSComponentPicker(symbol: "°", range: 0...90, selection: $latitudeDegrees)
                    DMSComponentPicker(symbol: "′", range: 0...59, selection: $latitudeMinutes)
                    DMSComponentPicker(symbol: "″", range: 0...59, selection: $latitudeSeconds)
                    Picker("Latitude Hemisphere", selection: $latHemi) {
                        ForEach(LatitudeHemisphere.allCases) { hemisphere in
                            Text(LocalizedStringKey(hemisphere.rawValue)).tag(hemisphere)
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
    let localizedHourLabel: (Int) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
                FieldBlock("Date") {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(LocalizedStringKey("view.radixinputscreen.year"))
                                .foregroundStyle(.secondary)
                            TextField("", text: $yearText)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 100)
                                .adaptiveBorder()

                            Text(LocalizedStringKey("view.radixinputscreen.month"))
                                .foregroundStyle(.secondary)
                            Picker(LocalizedStringKey("view.radixinputscreen.month"), selection: $month) {
                                ForEach(1...12, id: \.self) { value in
                                    Text(String(value)).tag(value)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            .focusable(true)

                            Text(LocalizedStringKey("view.radixinputscreen.day"))
                                .foregroundStyle(.secondary)
                            Picker(LocalizedStringKey("view.radixinputscreen.day"), selection: $day) {
                                ForEach(1...31, id: \.self) { value in
                                    Text(String(value)).tag(value)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            .focusable(true)
                        }
                        .fixedSize(horizontal: true, vertical: false)

                        if let message = dateValidationResult.message {
                            Text(message)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                FieldBlock(LocalizedStringKey("view.radixinputscreen.calendaryearcount")) {
                    HStack(spacing: 8) {
                        Picker("Calendar", selection: $calendarStyle) {
                            ForEach(CalendarStyle.allCases) { style in
                                Text(LocalizedStringKey(style.rawValue)).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 160)
                        .labelsHidden()
                        .focusable(true)

                        Picker("Year Count", selection: $yearCount) {
                            ForEach(YearCount.allCases) { count in
                                Text(LocalizedStringKey(count.rawValue)).tag(count)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .focusable(true)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
                FieldBlock(LocalizedStringKey("view.radixinputscreen.timedst")) {
                    HStack(spacing: 8) {
                        Picker(LocalizedStringKey("view.radixinputscreen.hour"), selection: $hour) {
                            ForEach(0...23, id: \.self) { value in
                                Text(localizedHourLabel(value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .focusable(true)

                        Picker(LocalizedStringKey("view.radixinputscreen.minute"), selection: $minute) {
                            ForEach(0...59, id: \.self) { value in
                                Text(String(format: "%02d", value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .focusable(true)

                        Picker(LocalizedStringKey("view.radixinputscreen.second"), selection: $second) {
                            ForEach(0...59, id: \.self) { value in
                                Text(String(format: "%02d", value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .focusable(true)

                        Picker("DST", selection: $dstOption) {
                            ForEach(DSTOption.allCases) { option in
                                Text(LocalizedStringKey(option.rawValue)).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 140)
                        .labelsHidden()
                        .focusable(true)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
                FieldBlock(LocalizedStringKey("view.radixinputscreen.offsetut")) {
                    HStack(spacing: 8) {
                        Picker(LocalizedStringKey("view.radixinputscreen.offsethour"), selection: $offsetHour) {
                            ForEach(0...23, id: \.self) { value in
                                Text(String(format: "%02d", value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .focusable(true)

                        Picker(LocalizedStringKey("view.radixinputscreen.offsetminute"), selection: $offsetMinute) {
                            ForEach(0...59, id: \.self) { value in
                                Text(String(format: "%02d", value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .focusable(true)

                        Picker(LocalizedStringKey("view.radixinputscreen.offsetsecond"), selection: $offsetSecond) {
                            ForEach(0...59, id: \.self) { value in
                                Text(String(format: "%02d", value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .focusable(true)

                        Picker("UT Relation", selection: $utOffsetDirection) {
                            ForEach(UTOffsetDirection.allCases) { relation in
                                Text(LocalizedStringKey(relation.rawValue)).tag(relation)
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
    @State private var expandedSection: AccordionSection = .chartInfo
    @State private var chartInfoSubmitted = false
    @FocusState private var focusedHeader: AccordionSection?

    private var uses24HourClock: Bool {
        let format = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: .autoupdatingCurrent) ?? "H"
        return !format.contains("a")
    }

    private var amSymbol: String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        return formatter.amSymbol
    }

    private var pmSymbol: String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        return formatter.pmSymbol
    }

    private func localizedHourLabel(for value: Int) -> String {
        if uses24HourClock {
            return String(format: "%02d", value)
        }

        let hour12 = value % 12 == 0 ? 12 : value % 12
        let period = value < 12 ? amSymbol : pmSymbol
        return "\(hour12) \(period)"
    }

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
                message: "Enter a valid year for the selected year count"
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
        if let chart = inputModel.lastChart {
            app.latestRadixChart = chart
            radixNav.setInspector(.positions)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizedStringKey("view.radixinputscreen.title"))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: { expandedSection = .chartInfo }) {
                    HStack(spacing: 6) {
                        Image(systemName: expandedSection == .chartInfo ? "chevron.down" : "chevron.right")
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                        Text(LocalizedStringKey("view.radixinputscreen.aboutchart"))
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
                        Text("Location")
                            .font(.headline)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .focusable(true)
                .focused($focusedHeader, equals: .location)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHint(chartNameIsEmpty ? LocalizedStringKey("view.radixinputscreen.accessibility.requiresname") : LocalizedStringKey(""))

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
                        Text(LocalizedStringKey("view.radixinputscreen.datetime"))
                            .font(.headline)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .focusable(true)
                .focused($focusedHeader, equals: .dateTime)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHint(chartNameIsEmpty ? LocalizedStringKey("view.radixinputscreen.accessibility.requiresname") : LocalizedStringKey(""))

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
                        dateValidationResult: dateValidationResult,
                        localizedHourLabel: localizedHourLabel(for:)
                    )
                    .padding(.top, 4)
                }

                Button("Calculate") {
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
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: focusedHeader) { header in
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
        .navigationTitle("Data for a new chart")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    radixNav.setInspector(.horoscope)
                    app.setInspectorSheet(false)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showHelp = true
                } label: {
                    Label("Help", systemImage: "questionmark.circle")
                }
                .help("Open help for this screen.")
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
