// RadixFormComponents.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Combine

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

// MARK: - Location search model

@MainActor
private final class LocationSearchModel: ObservableObject {
    @Published var countryQuery: String = ""
    @Published var cityQuery: String = ""
    @Published var filteredCountries: [LocationCountry] = []
    @Published var filteredCities: [LocationCity] = []
    @Published var selectedCountry: LocationCountry?
    @Published var selectedCity: LocationCity?
    @Published var errorMessage: String?

    private var orchestrator: LocationOrchestrator?
    private var lang: String = "en"
    private var countryDebounceTask: Task<Void, Never>?
    private var cityDebounceTask: Task<Void, Never>?
    private var suppressCountrySearch = false
    private var suppressCitySearch = false
    @Published var countrySelected = false
    @Published var citySelected = false

    func setup() {
        guard orchestrator == nil else { return }
        lang = Locale.current.language.languageCode?.identifier ?? "en"
        if !["en", "nl", "de", "fr"].contains(lang) { lang = "en" }
        do {
            orchestrator = try LocationOrchestrator(seWrapper: SEWrapper())
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func onCountryQueryChanged() {
        guard !suppressCountrySearch else { return }
        countrySelected = false
        countryDebounceTask?.cancel()
        let q = countryQuery.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty, q != "*" else { filteredCountries = []; return }
        let language = lang
        countryDebounceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            do {
                self.filteredCountries = try self.orchestrator?.countries(lang: language, pattern: q) ?? []
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func onCityQueryChanged() {
        guard !suppressCitySearch else { return }
        citySelected = false
        cityDebounceTask?.cancel()
        let country = selectedCountry
        let q = cityQuery.trimmingCharacters(in: .whitespaces)
        guard let country, !q.isEmpty else { filteredCities = []; return }
        cityDebounceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            do {
                let results = try self.orchestrator?.cities(countryCode: country.code, pattern: q) ?? []
                self.filteredCities = results
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func selectCountry(_ country: LocationCountry) {
        countryDebounceTask?.cancel()
        cityDebounceTask?.cancel()
        suppressCountrySearch = true
        suppressCitySearch = true
        countrySelected = true
        citySelected = false
        selectedCountry = country
        countryQuery = country.name
        filteredCountries = []
        cityQuery = ""
        selectedCity = nil
        filteredCities = []
        Task { @MainActor in
            self.suppressCountrySearch = false
            self.suppressCitySearch = false
        }
    }

    func selectCity(_ city: LocationCity) {
        cityDebounceTask?.cancel()
        suppressCitySearch = true
        citySelected = true
        selectedCity = city
        cityQuery = city.name
        filteredCities = []
        Task { @MainActor in
            self.suppressCitySearch = false
        }
    }

    func prePopulate(country: String?, city: String?) {
        if let c = country, !c.isEmpty {
            // Resolve the real country object so city search is enabled after pre-population.
            let results = (try? orchestrator?.countries(lang: lang, pattern: c)) ?? []
            if let found = results.first(where: { $0.name.lowercased() == c.lowercased() }) ?? results.first {
                // selectCountry sets selectedCountry (enabling city search) and resets city fields.
                selectCountry(found)
            } else {
                suppressCountrySearch = true
                countryQuery = c
                countrySelected = true
                filteredCountries = []
                Task { @MainActor in self.suppressCountrySearch = false }
            }
        }
        // Set city text after country selection (suppress is still active, so no search fires).
        if let ci = city, !ci.isEmpty {
            cityQuery = ci
            citySelected = true
            filteredCities = []
        }
    }

    func resolveTimezone(tzName: String, longitude: Double) -> ZoneInfo? {
        let dateTime = AstronomicalDateTime(
            Date: AstronomicalDate(Year: 2000, Month: 1, Day: 1),
            Time: AstronomicalTime(Hour: 12, Minute: 0, Second: 0)
        )
        return try? orchestrator?.timezoneInfo(tzName: tzName, dateTime: dateTime, longitude: longitude)
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
    @Binding var offsetHour: Int
    @Binding var offsetMinute: Int
    @Binding var utOffsetDirection: UTOffsetDirection
    @Binding var dstOption: DSTOption
    @Binding var selectedCity: LocationCity?
    var initialCountry: String? = nil
    var initialCity: String? = nil
    var selectedCountryName: Binding<String>? = nil
    var onCitySelected: ((LocationCity) -> Void)? = nil

    @StateObject private var searchModel = LocationSearchModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Country search
            FieldBlock(ri("view.radixinputscreen.country")) {
                TextField(ri("view.radixinputscreen.country.placeholder"), text: $searchModel.countryQuery)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
                    .adaptiveBorder()
                    .onChange(of: searchModel.countryQuery) { _, _ in searchModel.onCountryQueryChanged() }
                    .onAppear {
                        searchModel.setup()
                        if let c = initialCountry {
                            searchModel.prePopulate(country: c, city: initialCity)
                            selectedCountryName?.wrappedValue = c
                        }
                    }
            }
            if !searchModel.filteredCountries.isEmpty && !searchModel.countrySelected {
                dropdownList(searchModel.filteredCountries, keyPath: \.name) { country in
                    searchModel.selectCountry(country)
                    selectedCountryName?.wrappedValue = country.name
                }
            }

            // City / location name search
            FieldBlock(ri("view.radixinputscreen.nameoflocation")) {
                TextField(ri("view.radixinputscreen.city.placeholder"), text: $searchModel.cityQuery)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
                    .adaptiveBorder()
                    .opacity(searchModel.selectedCountry == nil ? 0.4 : 1.0)
                    .onChange(of: searchModel.cityQuery) { _, _ in searchModel.onCityQueryChanged() }
            }
            if !searchModel.filteredCities.isEmpty && !searchModel.citySelected {
                dropdownList(searchModel.filteredCities, keyPath: \.name) { city in
                    searchModel.selectCity(city)
                    locationName = city.name
                    applyCity(city)
                    onCitySelected?(city)
                }
            }

            if let err = searchModel.errorMessage {
                Text(err).font(.caption).foregroundStyle(.red)
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
        .onChange(of: searchModel.selectedCity) { _, city in
            selectedCity = city
        }
    }

    @ViewBuilder
    private func dropdownList<T>(_ items: [T], keyPath: KeyPath<T, String>, onSelect: @escaping (T) -> Void) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    Button { onSelect(item) } label: {
                        Text(item[keyPath: keyPath])
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.15), lineWidth: 1))
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

        if let zone = searchModel.resolveTimezone(tzName: city.timezoneName, longitude: city.longitude) {
            let totalSec = abs(zone.offsetSeconds)
            offsetHour = totalSec / 3600
            offsetMinute = (totalSec % 3600) / 60
            utOffsetDirection = zone.offsetSeconds >= 0 ? .later : .earlier
            dstOption = zone.dstUsed ? .dst : .noDST
        }
    }

    private func decimalToDms(_ decimal: Double) -> (Int, Int, Int, Bool) {
        let negative = decimal < 0
        let abs = Swift.abs(decimal)
        let degrees = Int(abs)
        let minutesFrac = (abs - Double(degrees)) * 60
        let minutes = Int(minutesFrac)
        let seconds = Int((minutesFrac - Double(minutes)) * 60)
        return (degrees, minutes, seconds, negative)
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
