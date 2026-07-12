// LongTimeEphemerisInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func lte(_ key: String) -> String {
    NSLocalizedString(key, tableName: "LongTimeEphemeris", bundle: .main, comment: "")
}

private func eph(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Ephemeris", bundle: .main, comment: "")
}

struct LongTimeEphemerisInputScreen: View {
    @EnvironmentObject private var model: LongTimeEphemerisModel

    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private let seWrapper = SEWrapper()

    @State private var showHelp = false

    // MARK: - Available factors

    private var availableFactors: [Factors] {
        EphemerisCalculator.availableFactors(for: model.observerPosition)
    }

    // MARK: - Year helpers

    private var startAstrYear: Int? {
        guard let y = Int(model.startYearText) else { return nil }
        switch model.startYearCount {
        case .astronomical: return y
        case .ce:           return y > 0 ? y : nil
        case .bc:           return y > 0 ? 1 - y : nil
        }
    }

    private var endAstrYear: Int? {
        guard let y = Int(model.endYearText) else { return nil }
        switch model.endYearCount {
        case .astronomical: return y
        case .ce:           return y > 0 ? y : nil
        case .bc:           return y > 0 ? 1 - y : nil
        }
    }

    // MARK: - Validation

    private var startDateValidation: DateComponentsValidationResult {
        guard let y = startAstrYear else {
            return DateComponentsValidationResult(isValid: false, message: lte(LongTimeEphemerisKeys.invalidYear))
        }
        return AstronomicalDateValidation.validateDateComponents(
            year: y, month: model.startMonth, day: model.startDay,
            gregorian: model.startCalendarStyle == .gregorian)
    }

    private var endDateValidation: DateComponentsValidationResult {
        guard let y = endAstrYear else {
            return DateComponentsValidationResult(isValid: false, message: lte(LongTimeEphemerisKeys.invalidYear))
        }
        return AstronomicalDateValidation.validateDateComponents(
            year: y, month: model.endMonth, day: model.endDay,
            gregorian: model.endCalendarStyle == .gregorian)
    }

    private var endDateIsAfterStart: Bool {
        guard startDateValidation.isValid, endDateValidation.isValid,
              let startYear = startAstrYear, let endYear = endAstrYear else { return true }
        let midnight = AstronomicalTime(HourDecimal: 0.0)
        let jdStart = seWrapper.julianDay(
            date: AstronomicalDate(Year: startYear, Month: model.startMonth, Day: model.startDay,
                                   Gregorian: model.startCalendarStyle == .gregorian),
            time: midnight)
        let jdEnd = seWrapper.julianDay(
            date: AstronomicalDate(Year: endYear, Month: model.endMonth, Day: model.endDay,
                                   Gregorian: model.endCalendarStyle == .gregorian),
            time: midnight)
        return jdEnd > jdStart
    }

    private var intervalIsPositive: Bool {
        model.intervalDays > 0 || model.intervalHours > 0
    }

    private var estimatedRowCount: Int? {
        guard startDateValidation.isValid, endDateValidation.isValid,
              endDateIsAfterStart, intervalIsPositive,
              let startYear = startAstrYear, let endYear = endAstrYear else { return nil }
        let midnight = AstronomicalTime(HourDecimal: 0.0)
        let jdStart = seWrapper.julianDay(
            date: AstronomicalDate(Year: startYear, Month: model.startMonth, Day: model.startDay,
                                   Gregorian: model.startCalendarStyle == .gregorian),
            time: midnight)
        let jdEnd = seWrapper.julianDay(
            date: AstronomicalDate(Year: endYear, Month: model.endMonth, Day: model.endDay,
                                   Gregorian: model.endCalendarStyle == .gregorian),
            time: midnight)
        let intervalInDays = Double(model.intervalDays) + Double(model.intervalHours) / 24.0
        guard intervalInDays > 0 else { return nil }
        return Int((jdEnd - jdStart) / intervalInDays) + 1
    }

    private var rowCountExceedsLimit: Bool {
        guard let count = estimatedRowCount else { return false }
        return count > LongTimeEphemerisModel.maxRows
    }

    private var canCalculate: Bool {
        startDateValidation.isValid && endDateValidation.isValid &&
        endDateIsAfterStart && intervalIsPositive && !model.selectedFactors.isEmpty &&
        !rowCountExceedsLimit
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(lte(LongTimeEphemerisKeys.title))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                GroupBox(lte(LongTimeEphemerisKeys.startDate)) {
                    dateInputRow(
                        yearText: $model.startYearText,
                        month: $model.startMonth,
                        day: $model.startDay,
                        calendar: $model.startCalendarStyle,
                        yearCount: $model.startYearCount,
                        validation: startDateValidation
                    )
                }

                GroupBox(lte(LongTimeEphemerisKeys.endDate)) {
                    dateInputRow(
                        yearText: $model.endYearText,
                        month: $model.endMonth,
                        day: $model.endDay,
                        calendar: $model.endCalendarStyle,
                        yearCount: $model.endYearCount,
                        validation: endDateValidation
                    )
                }

                if startDateValidation.isValid && endDateValidation.isValid && !endDateIsAfterStart {
                    Text(lte(LongTimeEphemerisKeys.endDateOrder))
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                GroupBox(lte(LongTimeEphemerisKeys.interval)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Text(lte(LongTimeEphemerisKeys.intervalDays)).foregroundStyle(.secondary)
                            NumericPickerField(
                                range: 0...99999,
                                fieldWidth: 60,
                                format: { String($0) },
                                selection: $model.intervalDays
                            )
                            Text(lte(LongTimeEphemerisKeys.intervalHours)).foregroundStyle(.secondary)
                            NumericPickerField(
                                range: 0...23,
                                fieldWidth: 40,
                                format: { String($0) },
                                selection: $model.intervalHours
                            )
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        if !intervalIsPositive {
                            Text(lte(LongTimeEphemerisKeys.intervalZero))
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }

                FieldBlock(lte(LongTimeEphemerisKeys.observerPosition)) {
                    Picker(lte(LongTimeEphemerisKeys.observerPosition), selection: $model.observerPosition) {
                        ForEach(ObserverPositions.allCases.filter { $0 != .topoCentric }, id: \.self) { pos in
                            Text(LocalizedStringKey(pos.rbKey)).tag(pos)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .focusable(true)
                }
                .onChange(of: model.observerPosition) { _, _ in
                    let available = availableFactors
                    model.selectedFactors.removeAll { !available.contains($0) }
                }

                FieldBlock(lte(LongTimeEphemerisKeys.ayanamsha)) {
                    Picker(lte(LongTimeEphemerisKeys.ayanamsha), selection: $model.ayanamsha) {
                        ForEach(Ayanamshas.allCases, id: \.self) { ayan in
                            Text(LocalizedStringKey(ayan.rbKey)).tag(ayan)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .focusable(true)
                }

                FieldBlock(lte(LongTimeEphemerisKeys.coordinate)) {
                    Picker(lte(LongTimeEphemerisKeys.coordinate), selection: $model.selectedCoordinate) {
                        ForEach(EphemerisCoordinate.allCases) { coord in
                            Text(eph(coord.labelKey)).tag(coord)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .focusable(true)
                }

                FieldBlock(lte(LongTimeEphemerisKeys.format)) {
                    Picker("", selection: $model.displayFormat) {
                        Text(lte(LongTimeEphemerisKeys.formatDms)).tag(LongTimeEphemerisDisplayFormat.dms)
                        Text(lte(LongTimeEphemerisKeys.formatDecimal)).tag(LongTimeEphemerisDisplayFormat.decimal)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                    .labelsHidden()
                }

                FieldBlock(lte(LongTimeEphemerisKeys.factors)) {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 2
                        ) {
                            ForEach(availableFactors, id: \.rawValue) { factor in
                                LteFactorRow(
                                    factor: factor,
                                    isSelected: model.selectedFactors.contains(factor)
                                ) {
                                    toggleFactor(factor)
                                }
                            }
                        }
                        .padding(4)
                    }
                    .frame(height: 320)
                    .background(Color.primary.opacity(0.04))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.15), lineWidth: 1))
                }

                if let count = estimatedRowCount {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                        Text("\(lte(LongTimeEphemerisKeys.estimatedRows)) \(count.formatted())")
                            .foregroundStyle(.secondary)
                    }
                    .font(.callout)

                    if rowCountExceedsLimit {
                        Text(String(format: lte(LongTimeEphemerisKeys.tooManyRows),
                                    count.formatted(),
                                    LongTimeEphemerisModel.maxRows.formatted()))
                            .foregroundStyle(.red)
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if model.isCalculating {
                    VStack(alignment: .leading, spacing: 8) {
                        ProgressView(value: model.progress)
                            .frame(maxWidth: 400)
                        HStack {
                            Text(lte(LongTimeEphemerisKeys.calculating))
                                .foregroundStyle(.secondary)
                                .font(.callout)
                            Button(lte(LongTimeEphemerisKeys.cancel)) {
                                model.cancelCalculation()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } else {
                    Button(lte(LongTimeEphemerisKeys.calculate)) { calculate() }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .disabled(!canCalculate)
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .controlSize(.small)
        .navigationTitle(lte(LongTimeEphemerisKeys.title))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: lte(LongTimeEphemerisKeys.help))
        }
        .onAppear {
            if model.selectedFactors.isEmpty, let config = activeConfigs.first {
                model.selectedFactors = config.factorConfig.factorSettings
                    .filter(\.isUsed)
                    .map(\.factor)
                    .filter { availableFactors.contains($0) }
            }
        }
    }

    // MARK: - Date input row

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
                Text(lte(LongTimeEphemerisKeys.year)).foregroundStyle(.secondary)
                TextField("", text: yearText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 100)
                    .adaptiveBorder()
                Text(lte(LongTimeEphemerisKeys.month)).foregroundStyle(.secondary)
                NumericPickerField(range: 1...12, fieldWidth: 35, format: { String($0) }, selection: month)
                Text(lte(LongTimeEphemerisKeys.day)).foregroundStyle(.secondary)
                NumericPickerField(range: 1...31, fieldWidth: 35, format: { String($0) }, selection: day)
            }
            .fixedSize(horizontal: true, vertical: false)
            HStack(spacing: 8) {
                Picker(lte(LongTimeEphemerisKeys.calendar), selection: calendar) {
                    ForEach(CalendarStyle.allCases) { style in
                        Text(LocalizedStringKey(style.rbKey)).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)
                .labelsHidden()
                .focusable(true)
                Picker(lte(LongTimeEphemerisKeys.yearCount), selection: yearCount) {
                    ForEach(YearCount.allCases) { count in
                        Text(LocalizedStringKey(count.rbKey)).tag(count)
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

    // MARK: - Helpers

    private func toggleFactor(_ factor: Factors) {
        if model.selectedFactors.contains(factor) {
            model.selectedFactors.removeAll { $0 == factor }
        } else {
            model.selectedFactors.append(factor)
        }
    }

    private func calculate() {
        guard let startYear = startAstrYear, let endYear = endAstrYear else { return }
        let midnight = AstronomicalTime(HourDecimal: 0.0)
        let jdStart = seWrapper.julianDay(
            date: AstronomicalDate(Year: startYear, Month: model.startMonth, Day: model.startDay,
                                   Gregorian: model.startCalendarStyle == .gregorian),
            time: midnight)
        let jdEnd = seWrapper.julianDay(
            date: AstronomicalDate(Year: endYear, Month: model.endMonth, Day: model.endDay,
                                   Gregorian: model.endCalendarStyle == .gregorian),
            time: midnight)
        model.startCalculation(jdStart: jdStart, jdEnd: jdEnd)
    }
}

// MARK: - Factor row

private struct LteFactorRow: View {
    let factor: Factors
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let iconName = isSelected ? "checkmark.square.fill" : "square"
        let iconColor: Color = isSelected ? .accentColor : .secondary
        let bgColor: Color = isSelected ? Color.accentColor.opacity(0.1) : .clear
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: iconName).foregroundStyle(iconColor)
                Text(NSLocalizedString(factor.localizedName, comment: "")).foregroundStyle(.primary)
                Spacer()
            }
            .padding(.vertical, 3)
            .padding(.horizontal, 6)
            .background(bgColor)
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}
