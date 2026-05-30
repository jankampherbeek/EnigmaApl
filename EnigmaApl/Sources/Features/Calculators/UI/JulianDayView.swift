// JulianDayView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func ca(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Calculators", bundle: .main, comment: "")
}

struct JulianDayView: View {

    // MARK: - Date and time input (date → JD)
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

    // MARK: - Results: date → JD
    @State private var julianDayResult: Double?   = nil
    @State private var deltaTResult: Double?      = nil

    // MARK: - Julian Day → date input
    @State private var jdInputText: String        = ""

    // MARK: - Results: JD → date
    @State private var dateResult: String?        = nil
    @State private var timeResult: String?        = nil

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
                Text(ca(CalculatorsKeys.jdTitle))
                    .font(.title2.weight(.semibold))

                // MARK: Section 1: Date and time → Julian Day
                GroupBox(ca(CalculatorsKeys.jdDateTimeToJd)) {
                    VStack(alignment: .leading, spacing: 12) {
                        dateTimeInputSection

                        Button(ca(CalculatorsKeys.jdCalcButton)) {
                            // Backend not yet implemented
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!dateValidation.isValid)

                        if let jd = julianDayResult {
                            LabeledContent(ca(CalculatorsKeys.jdResultJd)) {
                                Text(String(format: "%.6f", jd))
                                    .monospacedDigit()
                            }
                        }
                        if let dt = deltaTResult {
                            LabeledContent(ca(CalculatorsKeys.jdResultDeltaT)) {
                                Text(String(format: "%.2f s", dt))
                                    .monospacedDigit()
                            }
                        }
                    }
                    .padding(.top, 4)
                }

                // MARK: Section 2: Julian Day → date and time
                GroupBox(ca(CalculatorsKeys.jdToDateTime)) {
                    VStack(alignment: .leading, spacing: 12) {
                        FieldBlock(ca(CalculatorsKeys.jdInput)) {
                            TextField("", text: $jdInputText)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 180)
                        }

                        Button(ca(CalculatorsKeys.jdCalcDateTimeButton)) {
                            // Backend not yet implemented
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(Double(jdInputText) == nil)

                        if let d = dateResult {
                            LabeledContent(ca(CalculatorsKeys.jdResultDate)) {
                                Text(d).monospacedDigit()
                            }
                        }
                        if let t = timeResult {
                            LabeledContent(ca(CalculatorsKeys.jdResultTime)) {
                                Text(t).monospacedDigit()
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
    }

    // MARK: - Shared date/time entry block
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
