// RadixFormComponents.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

func ri(_ key: String) -> String {
    NSLocalizedString(key, tableName: "RadixInput", bundle: .main, comment: "")
}

// Reusable numeric picker that combines a TextField (type directly) with a
// chevron button that opens a popover list – HIG-compliant on macOS.
struct NumericPickerField: View {
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
struct DMSComponentPicker: View {
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

struct FieldBlock<Content: View>: View {
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

struct RadixChartHelpView: View {
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

// MARK: - Accordion Section

enum AccordionSection: Hashable {
    case chartInfo, location, dateTime
}

// MARK: - Section: Chart Info

struct ChartInfoSection: View {
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

struct LocationSection: View {
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

struct DateTimeSection: View {
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
