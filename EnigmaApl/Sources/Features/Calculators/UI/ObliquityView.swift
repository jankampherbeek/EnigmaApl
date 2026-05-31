// ObliquityView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func ca(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Calculators", bundle: .main, comment: "")
}

struct ObliquityView: View {

    private let seWrapper = SEWrapper()

    // MARK: - Date and time input
    @State private var yearText: String       = "2000"
    @State private var month: Int             = 1
    @State private var day: Int               = 1
    @State private var hour: Int              = 12
    @State private var minute: Int            = 0
    @State private var second: Int            = 0
    @State private var calendarStyle: CalendarStyle     = .gregorian
    @State private var yearCount: YearCount             = .ce
    @State private var offsetHour: Int                  = 0
    @State private var offsetMinute: Int                = 0
    @State private var utOffsetDirection: UTOffsetDirection = .later
    @State private var showHelp: Bool = false

    // MARK: - Results
    @State private var meanObliquityResult: Double? = nil
    @State private var trueObliquityResult: Double? = nil

    private var dateValidation: DateComponentsValidationResult {
        guard let year = astronomicalYear else {
            return DateComponentsValidationResult(isValid: false,
                message: ca(CalculatorsKeys.invalidYear))
        }
        return AstronomicalDateValidation.validateDateComponents(
            year: year, month: month, day: day,
            gregorian: calendarStyle == .gregorian)
    }

    private var astronomicalYear: Int? {
        guard let y = Int(yearText) else { return nil }
        switch yearCount {
        case .astronomical: return y
        case .ce:           return y > 0 ? y : nil
        case .bc:           return y > 0 ? 1 - y : nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(ca(CalculatorsKeys.oblTitle))
                    .font(.title2.weight(.semibold))

                GroupBox(ca(CalculatorsKeys.oblDateTimeSection)) {
                    VStack(alignment: .leading, spacing: 12) {
                        dateTimeInputSection

                        Button(ca(CalculatorsKeys.oblCalcButton)) {
                            calculateObliquity()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!dateValidation.isValid)

                        if let mean = meanObliquityResult {
                            LabeledContent(ca(CalculatorsKeys.oblResultMean)) {
                                Text(mean.formatted(.number.precision(.fractionLength(6))) + "°")
                                    .monospacedDigit()
                            }
                        }
                        if let trueObl = trueObliquityResult {
                            LabeledContent(ca(CalculatorsKeys.oblResultTrue)) {
                                Text(trueObl.formatted(.number.precision(.fractionLength(6))) + "°")
                                    .monospacedDigit()
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: ca(CalculatorsKeys.oblHelp))
        }
    }

    // MARK: - Calculation

    private func calculateObliquity() {
        guard let year = astronomicalYear else { return }
        let date = AstronomicalDate(Year: year, Month: month, Day: day,
                                    Gregorian: calendarStyle == .gregorian)
        let localTime = AstronomicalTime(Hour: hour, Minute: minute, Second: second)
        let localJD = seWrapper.julianDay(date: date, time: localTime)
        let offsetSeconds = Double(offsetHour * 3600 + offsetMinute * 60)
        let sign = utOffsetDirection == .earlier ? -1.0 : 1.0
        let utJD = localJD + (sign * offsetSeconds) / 86_400.0
        guard let result = seWrapper.calculateObliquity(jdUt: utJD) else { return }
        meanObliquityResult = result.meanObliquity
        trueObliquityResult = result.trueObliquity
    }

    // MARK: - Date/time entry block
    @ViewBuilder
    private var dateTimeInputSection: some View {
        FieldBlock(ca(CalculatorsKeys.date)) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(ca(CalculatorsKeys.year)).foregroundStyle(.secondary)
                    TextField("", text: $yearText)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 100)
                    Text(ca(CalculatorsKeys.month)).foregroundStyle(.secondary)
                    NumericPickerField(range: 1...12, fieldWidth: 35,
                                      format: { String($0) }, selection: $month)
                    Text(ca(CalculatorsKeys.day)).foregroundStyle(.secondary)
                    NumericPickerField(range: 1...31, fieldWidth: 35,
                                      format: { String($0) }, selection: $day)
                }
                .fixedSize(horizontal: true, vertical: false)
                if let msg = dateValidation.message {
                    Text(msg).font(.caption).foregroundStyle(.red)
                }
            }
        }

        FieldBlock(ca(CalculatorsKeys.calendarYearCount)) {
            HStack(spacing: 8) {
                Picker("", selection: $calendarStyle) {
                    ForEach(CalendarStyle.allCases) { s in
                        Text(LocalizedStringKey(s.rbKey)).tag(s)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)
                .labelsHidden()

                Picker("", selection: $yearCount) {
                    ForEach(YearCount.allCases) { c in
                        Text(LocalizedStringKey(c.rbKey)).tag(c)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
            .fixedSize(horizontal: true, vertical: false)
        }

        FieldBlock(ca(CalculatorsKeys.time)) {
            HStack(spacing: 8) {
                NumericPickerField(range: 0...23, fieldWidth: 40,
                                  format: { String(format: "%02d", $0) }, selection: $hour)
                NumericPickerField(range: 0...59, fieldWidth: 35,
                                  format: { String(format: "%02d", $0) }, selection: $minute)
                NumericPickerField(range: 0...59, fieldWidth: 35,
                                  format: { String(format: "%02d", $0) }, selection: $second)
            }
            .fixedSize(horizontal: true, vertical: false)
        }

        FieldBlock(ca(CalculatorsKeys.offsetUT)) {
            HStack(spacing: 8) {
                NumericPickerField(range: 0...23, fieldWidth: 40,
                                  format: { String(format: "%02d", $0) }, selection: $offsetHour)
                NumericPickerField(range: 0...59, fieldWidth: 35,
                                  format: { String(format: "%02d", $0) }, selection: $offsetMinute)
                Picker("", selection: $utOffsetDirection) {
                    ForEach(UTOffsetDirection.allCases) { d in
                        Text(LocalizedStringKey(d.rbKey)).tag(d)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)
                .labelsHidden()
            }
            .fixedSize(horizontal: true, vertical: false)
        }
    }
}
