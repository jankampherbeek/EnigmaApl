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
    case gregorian = "G"
    case julian = "J"
    var id: String { rawValue }
}

enum YearCount: String, CaseIterable, Identifiable {
    case ce = "CE"
    case bc = "BC"
    case astronomical = "Astr"
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

struct RadixInputScreen: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var radixNav: RadixNavigator
    @State private var chartName: String = ""
    @State private var chartDescription = ""
    @State private var source = ""
    @State private var roddenRating: RoddenRating = .aa

    @State private var locationName: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var latHemi: LatitudeHemisphere = .north
    @State private var lonHemi: LongitudeHemisphere = .east

    @State private var date = ""
    @State private var time = ""
    @State private var offset = "00:00:00"
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
                LabeledContent("Longitude (ddd:mm:ss)") {
                    HStack(spacing: 8) {
                        TextField("", text: $longitude)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 180)
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
                LabeledContent("Latitude (dd:mm:ss)") {
                    HStack(spacing: 8) {
                        TextField("", text: $latitude)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 180)
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
                LabeledContent("Date (yyyy/mm/dd)") {
                    TextField("", text: $date)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 220)
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
                LabeledContent("Time (hh:mm:ss)") {
                    HStack(spacing: 8) {
                        TextField("", text: $time)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 180)
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
                LabeledContent("Offset UT (hh:mm:ss)") {
                    HStack(spacing: 8) {
                        TextField("", text: $offset)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 180)
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
