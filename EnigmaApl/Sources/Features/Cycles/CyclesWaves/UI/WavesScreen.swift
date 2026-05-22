// WavesScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private enum WaveCycleType: CaseIterable {
    case jupiter, saturn, uranus

    var factor: Factors {
        switch self {
        case .jupiter: return .jupiter
        case .saturn:  return .saturn
        case .uranus:  return .uranus
        }
    }

    var interval: Int {
        switch self {
        case .jupiter: return 5
        case .saturn:  return 5
        case .uranus:  return 10
        }
    }
}

struct WavesScreen: View {
    @EnvironmentObject private var wavesModel: WavesModel

    private let seWrapper = SEWrapper()

    @State private var startYearText  = "2000"
    @State private var startMonth     = 1
    @State private var startDay       = 1
    @State private var startCalendar: CalendarStyle = .gregorian
    @State private var startYearCount: YearCount    = .ce

    @State private var endYearText = "2100"
    @State private var endMonth    = 12
    @State private var endDay      = 31
    @State private var endCalendar: CalendarStyle = .gregorian
    @State private var endYearCount: YearCount    = .ce

    @State private var observerPosition: ObserverPositions = .helioCentric
    @State private var selectedCoordinate: Coordinates     = .longitude
    @State private var selectedCycleTypes: Set<WaveCycleType> = [.saturn]
    @State private var showHelp = false


    // MARK: - Validation

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

    private var startDateValidation: DateComponentsValidationResult {
        guard let y = startAstrYear else {
            return DateComponentsValidationResult(isValid: false, message: w(WavesKeys.invalidYear))
        }
        return AstronomicalDateValidation.validateDateComponents(
            year: y, month: startMonth, day: startDay, gregorian: startCalendar == .gregorian)
    }

    private var endDateValidation: DateComponentsValidationResult {
        guard let y = endAstrYear else {
            return DateComponentsValidationResult(isValid: false, message: w(WavesKeys.invalidYear))
        }
        return AstronomicalDateValidation.validateDateComponents(
            year: y, month: endMonth, day: endDay, gregorian: endCalendar == .gregorian)
    }

    private var availableCoordinates: [Coordinates] {
        if observerPosition == .helioCentric {
            return Coordinates.allCases.filter { $0 != .rightAscension && $0 != .declination }
        }
        return Coordinates.allCases
    }

    private var endDateIsAfterStart: Bool {
        guard startDateValidation.isValid, endDateValidation.isValid,
              let startYear = startAstrYear, let endYear = endAstrYear else { return true }
        let midnight = AstronomicalTime(HourDecimal: 0.0)
        let jdStart = seWrapper.julianDay(
            date: AstronomicalDate(Year: startYear, Month: startMonth, Day: startDay, Gregorian: startCalendar == .gregorian),
            time: midnight)
        let jdEnd = seWrapper.julianDay(
            date: AstronomicalDate(Year: endYear, Month: endMonth, Day: endDay, Gregorian: endCalendar == .gregorian),
            time: midnight)
        return jdEnd > jdStart
    }

    private var canCalculate: Bool {
        startDateValidation.isValid && endDateValidation.isValid && endDateIsAfterStart && !selectedCycleTypes.isEmpty
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(w(WavesKeys.title))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                GroupBox(w(WavesKeys.startDate)) {
                    dateInputRow(
                        yearText: $startYearText, month: $startMonth, day: $startDay,
                        calendar: $startCalendar, yearCount: $startYearCount,
                        validation: startDateValidation)
                }

                GroupBox(w(WavesKeys.endDate)) {
                    dateInputRow(
                        yearText: $endYearText, month: $endMonth, day: $endDay,
                        calendar: $endCalendar, yearCount: $endYearCount,
                        validation: endDateValidation)
                }

                if startDateValidation.isValid && endDateValidation.isValid && !endDateIsAfterStart {
                    Text(w(WavesKeys.endDateOrder))
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                FieldBlock(w(WavesKeys.observerPosition)) {
                    Picker(w(WavesKeys.observerPosition), selection: $observerPosition) {
                        ForEach(ObserverPositions.allCases.filter { $0 != .topoCentric }, id: \.self) { pos in
                            Text(NSLocalizedString(pos.rbKey, comment: "")).tag(pos)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .focusable(true)
                }

                FieldBlock(w(WavesKeys.coordinate)) {
                    Picker(w(WavesKeys.coordinate), selection: $selectedCoordinate) {
                        ForEach(availableCoordinates, id: \.self) { coord in
                            Text(NSLocalizedString(coord.rbKey, comment: "")).tag(coord)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .focusable(true)
                }

                FieldBlock(w(WavesKeys.cycleType)) {
                    HStack(spacing: 16) {
                        ForEach(WaveCycleType.allCases, id: \.self) { ct in
                            let isOn = selectedCycleTypes.contains(ct)
                            Toggle(NSLocalizedString(ct.factor.localizedName, comment: ""), isOn: Binding(
                                get: { isOn },
                                set: { on in
                                    if on { selectedCycleTypes.insert(ct) }
                                    else  { selectedCycleTypes.remove(ct) }
                                }
                            ))
                            .toggleStyle(.checkbox)
                        }
                    }
                }

                Button(w(WavesKeys.calculate)) { calculate() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .disabled(!canCalculate)
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .controlSize(.small)
        .navigationTitle(w(WavesKeys.title))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: w(WavesKeys.help))
        }
        .onChange(of: observerPosition) { _, _ in
            if !availableCoordinates.contains(selectedCoordinate) {
                selectedCoordinate = .longitude
            }
        }
    }

    // MARK: - Date input

    @ViewBuilder
    private func dateInputRow(
        yearText: Binding<String>,
        month: Binding<Int>,
        day: Binding<Int>,
        calendar: Binding<CalendarStyle>,
        yearCount: Binding<YearCount>,
        validation: DateComponentsValidationResult
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(w(WavesKeys.year)).foregroundStyle(.secondary)
                TextField("", text: yearText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 100)
                    .adaptiveBorder()
                Text(w(WavesKeys.month)).foregroundStyle(.secondary)
                NumericPickerField(range: 1...12, fieldWidth: 35, format: { String($0) }, selection: month)
                Text(w(WavesKeys.day)).foregroundStyle(.secondary)
                NumericPickerField(range: 1...31, fieldWidth: 35, format: { String($0) }, selection: day)
            }
            .fixedSize(horizontal: true, vertical: false)
            HStack(spacing: 8) {
                Picker(w(WavesKeys.calendar), selection: calendar) {
                    ForEach(CalendarStyle.allCases) { style in
                        Text(NSLocalizedString(style.rbKey, comment: "")).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)
                .labelsHidden()
                .focusable(true)
                Picker(w(WavesKeys.yearCount), selection: yearCount) {
                    ForEach(YearCount.allCases) { count in
                        Text(NSLocalizedString(count.rbKey, comment: "")).tag(count)
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

    // MARK: - Calculate

    private func calculate() {
        guard let startYear = startAstrYear, let endYear = endAstrYear else { return }
        let midnight = AstronomicalTime(HourDecimal: 0.0)
        let jdStart = seWrapper.julianDay(
            date: AstronomicalDate(Year: startYear, Month: startMonth, Day: startDay,
                                   Gregorian: startCalendar == .gregorian),
            time: midnight)
        let jdEnd = seWrapper.julianDay(
            date: AstronomicalDate(Year: endYear, Month: endMonth, Day: endDay,
                                   Gregorian: endCalendar == .gregorian),
            time: midnight)
        var allResults: [Factors: [(julianDay: Double, waveValue: Double)]] = [:]
        for ct in WaveCycleType.allCases where selectedCycleTypes.contains(ct) {
            let request = WavesRequest(
                CycleType: ct.factor,
                Interval: ct.interval,
                JdStart: jdStart,
                JdEnd: jdEnd,
                Coordinate: selectedCoordinate,
                ObserverPosition: observerPosition
            )
            allResults[ct.factor] = WavesCalculator.PerformCalculation(request, seWrapper: seWrapper)
        }
        wavesModel.selectedFactors = WaveCycleType.allCases
            .filter { selectedCycleTypes.contains($0) }
            .map { $0.factor }
        wavesModel.allResults = allResults
    }

    // MARK: - i18n

    private func w(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Waves", bundle: .main, comment: "")
    }
}
