//
//  RadixInputScreen.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 23/02/2026.
//

import SwiftUI

enum LatitudeHemisphere: String, CaseIterable, Identifiable {
    case north = "N"
    case south = "Z"
    var id: String { rawValue }
}

enum LongitudeHemisphere: String, CaseIterable, Identifiable {
    case east = "O"
    case west = "W"
    var id: String { rawValue }
}

enum CalendarStyle: String, CaseIterable, Identifiable {
    case gregorian = "Gregorian"
    case julian = "Julian"
    var id: String { rawValue }
}

enum YearCount: String, CaseIterable, Identifiable {
    case ce = "CE"
    case bc = "BCE"
    case astronomical = "Astronomical"
    var id: String { rawValue }
}

enum UTOffsetDirection: String, CaseIterable, Identifiable {
    case later = "Later"
    case earlier = "Earlier"
    var id: String { rawValue }
}

enum DSTOption: String, CaseIterable, Identifiable {
    case dst = "DST"
    case noDST = "no DST"
    var id: String { rawValue }
}

enum RoddenRating: String, CaseIterable, Identifiable {
    case aa = "AA"
    case a = "A"
    case b = "B"
    case c = "C"
    case dd = "DD"
    case x = "X"
    case xx = "XX"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .aa: return "Very high"
        case .a: return "High"
        case .b: return "Reasonable"
        case .c: return "Not sure"
        case .dd: return "Dirty Data"
        case .x: return "Unknown time"
        case .xx: return "Unknown Data"
        }
    }

    var displayText: String { "\(rawValue) - \(description)" }
}

// Reusable DMS part picker used to compose geo-coordinate input.
private struct DMSComponentPicker: View {
    let title: String
    let range: ClosedRange<Int>
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .foregroundStyle(.secondary)
            Picker(title, selection: $selection) {
                ForEach(Array(range), id: \.self) { value in
                    Text(String(value)).tag(value)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .focusable(true)
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
                    GroupBox("About the chart") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Use Name, Description and Source to identify your chart.")
                            Text("Rodden Rating indicates source reliability.")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox("Location") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Enter longitude and latitude in degrees, minutes and seconds.")
                            Text("Use O/W for longitude hemisphere and N/Z for latitude hemisphere.")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox("Date and Time") {
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

    private var canCreateRequest: Bool {
        dateValidationResult.isValid && astronomicalYearForValidation != nil
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Data for a new chart")
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                GroupBox("About the chart") {
                    VStack(alignment: .leading, spacing: 8) {
                        FieldBlock("Name") {
                            TextField("", text: $chartName)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        FieldBlock("Description") {
                            TextField("", text: $chartDescription)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        FieldBlock("Source") {
                            TextField("", text: $source)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        FieldBlock("Rodden Rating") {
                            Picker("Rodden Rating", selection: $roddenRating) {
                                ForEach(RoddenRating.allCases) { rating in
                                    Text(rating.displayText).tag(rating)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            .focusable(true)
                            .help("Reliability rating of the birth data source.")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox("Location") {
                    VStack(alignment: .leading, spacing: 8) {
                        FieldBlock("Name of location") {
                            TextField("", text: $locationName)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        FieldBlock("Longitude") {
                            HStack(spacing: 8) {
                                DMSComponentPicker(title: "Deg", range: 0...180, selection: $longitudeDegrees)
                                DMSComponentPicker(title: "Min", range: 0...59, selection: $longitudeMinutes)
                                DMSComponentPicker(title: "Sec", range: 0...59, selection: $longitudeSeconds)
                                Picker("Longitude Hemisphere", selection: $lonHemi) {
                                    ForEach(LongitudeHemisphere.allCases) { hemisphere in
                                        Text(hemisphere.rawValue).tag(hemisphere)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .labelsHidden()
                                .focusable(true)
                            }
                        }
                        FieldBlock("Latitude") {
                            HStack(spacing: 8) {
                                DMSComponentPicker(title: "Deg", range: 0...90, selection: $latitudeDegrees)
                                DMSComponentPicker(title: "Min", range: 0...59, selection: $latitudeMinutes)
                                DMSComponentPicker(title: "Sec", range: 0...59, selection: $latitudeSeconds)
                                Picker("Latitude Hemisphere", selection: $latHemi) {
                                    ForEach(LatitudeHemisphere.allCases) { hemisphere in
                                        Text(hemisphere.rawValue).tag(hemisphere)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .labelsHidden()
                                .focusable(true)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox("Date and Time") {
                    VStack(alignment: .leading, spacing: 8) {
                        FieldBlock("Date") {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Text("Year")
                                        .foregroundStyle(.secondary)
                                    TextField("", text: $yearText)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(maxWidth: 100)

                                    Text("Month")
                                        .foregroundStyle(.secondary)
                                    Picker("Month", selection: $month) {
                                        ForEach(1...12, id: \.self) { value in
                                            Text(String(value)).tag(value)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .focusable(true)

                                    Text("Day")
                                        .foregroundStyle(.secondary)
                                    Picker("Day", selection: $day) {
                                        ForEach(1...31, id: \.self) { value in
                                            Text(String(value)).tag(value)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .focusable(true)
                                }

                                if let message = dateValidationResult.message {
                                    Text(message)
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        FieldBlock("Calendar / Year Count") {
                            HStack(spacing: 8) {
                                Picker("Calendar", selection: $calendarStyle) {
                                    ForEach(CalendarStyle.allCases) { style in
                                        Text(style.rawValue).tag(style)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(maxWidth: 160)
                                .labelsHidden()
                                .focusable(true)
                                .help("Choose Gregorian or Julian calendar for the entered date.")

                                Picker("Year Count", selection: $yearCount) {
                                    ForEach(YearCount.allCases) { count in
                                        Text(count.rawValue).tag(count)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .focusable(true)
                                .help("CE/BCE or astronomical year numbering.")
                            }
                        }
                        FieldBlock("Time / DST") {
                            HStack(spacing: 8) {
                                Picker("Hour", selection: $hour) {
                                    ForEach(0...23, id: \.self) { value in
                                        Text(localizedHourLabel(for: value)).tag(value)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .focusable(true)

                                Picker("Minute", selection: $minute) {
                                    ForEach(0...59, id: \.self) { value in
                                        Text(String(format: "%02d", value)).tag(value)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .focusable(true)

                                Picker("Second", selection: $second) {
                                    ForEach(0...59, id: \.self) { value in
                                        Text(String(format: "%02d", value)).tag(value)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .focusable(true)

                                Picker("DST", selection: $dstOption) {
                                    ForEach(DSTOption.allCases) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(maxWidth: 140)
                                .labelsHidden()
                                .focusable(true)
                                .help("Set to DST when daylight saving time was in effect.")
                            }
                        }
                        FieldBlock("Offset UT") {
                            HStack(spacing: 8) {
                                Picker("Offset Hour", selection: $offsetHour) {
                                    ForEach(0...23, id: \.self) { value in
                                        Text(String(format: "%02d", value)).tag(value)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .focusable(true)

                                Picker("Offset Minute", selection: $offsetMinute) {
                                    ForEach(0...59, id: \.self) { value in
                                        Text(String(format: "%02d", value)).tag(value)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .focusable(true)

                                Picker("Offset Second", selection: $offsetSecond) {
                                    ForEach(0...59, id: \.self) { value in
                                        Text(String(format: "%02d", value)).tag(value)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .focusable(true)

                                Picker("UT Relation", selection: $utOffsetDirection) {
                                    ForEach(UTOffsetDirection.allCases) { relation in
                                        Text(relation.rawValue).tag(relation)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(maxWidth: 160)
                                .labelsHidden()
                                .focusable(true)
                                .help("Indicates whether local time is earlier or later than UT.")
                            }
                        }

                        Button("Calculate") {
                            guard let modelInput else { return }
                            inputModel.calculate(from: modelInput)
                            if let chart = inputModel.lastChart {
                                app.latestRadixChart = chart
                                radixNav.setInspector(.positions)
                            }
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
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
