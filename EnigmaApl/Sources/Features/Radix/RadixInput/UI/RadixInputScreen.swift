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
    case earlier = "Earlier"
    case later = "Later"
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
        }
    }
}

struct RadixInputScreen: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var radixNav: RadixNavigator
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
    @State private var utOffsetDirection: UTOffsetDirection = .earlier
    @State private var dstOption: DSTOption = .noDST

    var body: some View {
        Form {
            Section("About the chart") {
                LabeledContent("Name") {
                    TextField("", text: $chartName)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 320)
                }
                LabeledContent("Description") {
                    TextField("", text: $chartDescription)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 320)
                }
                LabeledContent("Source") {
                    TextField("", text: $source)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 320)
                }
                LabeledContent("Rodden Rating") {
                    Picker("Rodden Rating", selection: $roddenRating) {
                        ForEach(RoddenRating.allCases) { rating in
                            Text(rating.displayText).tag(rating)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }
            }

            Section("Location") {
                LabeledContent("Name of location") {
                    TextField("", text: $locationName)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 320)
                }
                LabeledContent("Longitude") {
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
                        .frame(maxWidth: 140)
                        .labelsHidden()
                    }
                }
                LabeledContent("Latitude") {
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
                        .frame(maxWidth: 140)
                        .labelsHidden()
                    }
                }
            }

            Section("Date and Time") {
                LabeledContent("Date") {
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

                        Text("Day")
                            .foregroundStyle(.secondary)
                        Picker("Day", selection: $day) {
                            ForEach(1...31, id: \.self) { value in
                                Text(String(value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                }
                LabeledContent("Calendar / Year Count") {
                    HStack(spacing: 8) {
                        Picker("Calendar", selection: $calendarStyle) {
                            ForEach(CalendarStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 160)
                        .labelsHidden()

                        Picker("Year Count", selection: $yearCount) {
                            ForEach(YearCount.allCases) { count in
                                Text(count.rawValue).tag(count)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                }
                LabeledContent("Time / DST") {
                    HStack(spacing: 8) {
                        Picker("Hour", selection: $hour) {
                            ForEach(0...23, id: \.self) { value in
                                Text(String(format: "%02d", value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()

                        Picker("Minute", selection: $minute) {
                            ForEach(0...59, id: \.self) { value in
                                Text(String(format: "%02d", value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()

                        Picker("Second", selection: $second) {
                            ForEach(0...59, id: \.self) { value in
                                Text(String(format: "%02d", value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()

                        Picker("DST", selection: $dstOption) {
                            ForEach(DSTOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 140)
                        .labelsHidden()
                    }
                }
                LabeledContent("Offset UT") {
                    HStack(spacing: 8) {
                        Picker("Offset Hour", selection: $offsetHour) {
                            ForEach(0...23, id: \.self) { value in
                                Text(String(format: "%02d", value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()

                        Picker("Offset Minute", selection: $offsetMinute) {
                            ForEach(0...59, id: \.self) { value in
                                Text(String(format: "%02d", value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()

                        Picker("Offset Second", selection: $offsetSecond) {
                            ForEach(0...59, id: \.self) { value in
                                Text(String(format: "%02d", value)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()

                        Picker("UT Relation", selection: $utOffsetDirection) {
                            ForEach(UTOffsetDirection.allCases) { relation in
                                Text(relation.rawValue).tag(relation)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 160)
                        .labelsHidden()
                    }
                }
            }
        }
        // Keeps native Form row metrics while avoiding overly wide input controls on macOS.
        .formStyle(.grouped)
        .navigationTitle("New Chart")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    radixNav.setInspector(.horoscope)
                    app.setInspectorSheet(false)
                }
            }
        }
    }
}

#Preview {
    RadixInputScreen()
}
