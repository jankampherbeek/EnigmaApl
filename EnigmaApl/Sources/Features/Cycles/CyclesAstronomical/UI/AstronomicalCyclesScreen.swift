// AstronomicalCyclesScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

func ac(_ key: String) -> String {
    NSLocalizedString(key, tableName: "AstronomicalCycles", bundle: .main, comment: "")
}

private enum FactorSelectionMode: Hashable { case single, pairs }

private struct FactorPair: Identifiable {
    let id = UUID()
    let factorA: Factors
    let factorB: Factors
}

struct AstronomicalCyclesScreen: View {
    @EnvironmentObject private var cyclesModel: AstronomicalCyclesModel

    private let seWrapper = SEWrapper()

    @State private var startYearText = "2024"
    @State private var startMonth = 1
    @State private var startDay = 1
    @State private var startCalendar: CalendarStyle = .gregorian
    @State private var startYearCount: YearCount = .ce

    @State private var endYearText = "2025"
    @State private var endMonth = 12
    @State private var endDay = 31
    @State private var endCalendar: CalendarStyle = .gregorian
    @State private var endYearCount: YearCount = .ce

    @State private var observerPosition: ObserverPositions = .geoCentric
    @State private var selectedCoordinate: Coordinates = .longitude
    @State private var ayanamsha: Ayanamshas = .tropical
    @State private var factorMode: FactorSelectionMode = .single
    @State private var selectedFactors: [Factors] = []
    @State private var pendingFactorA: Factors? = nil
    @State private var pendingFactorB: Factors? = nil
    @State private var factorPairs: [FactorPair] = []
    @State private var periodWarning: String? = nil
    @State private var showHelp = false

    private let maxSingleFactors = 12
    private let maxPairs = 6

    private static let helioExcluded: Set<Factors> = [
        .sun, .moon, .northNode, .apogeeMean, .apogeeKoch, .apogeeDuval, .apogeeInterpolated,
        .perigeeInterpolated, .priapus, .priapusCorrected, .dragon, .beast, .southNode,
        .blackSun, .diamond
    ]

    private var availableFactors: [Factors] {
        let positionExcluded: Set<Factors> = observerPosition == .helioCentric
            ? Self.helioExcluded
            : [.earth]
        return Factors.allCases.filter {
            let ct = $0.calculationType
            guard ct != .Mundane && ct != .Lots && ct != .ZodiacFixed && ct != .Unknown else { return false }
            return !positionExcluded.contains($0)
        }
    }

    private var availableCoordinates: [Coordinates] {
        if observerPosition == .helioCentric {
            return Coordinates.allCases.filter { $0 != .rightAscension && $0 != .declination }
        }
        return Coordinates.allCases
    }

    private var startAstrYear: Int? {
        guard let y = Int(startYearText) else { return nil }
        switch startYearCount {
        case .astronomical: return y
        case .ce: return y > 0 ? y : nil
        case .bc: return y > 0 ? 1 - y : nil
        }
    }

    private var endAstrYear: Int? {
        guard let y = Int(endYearText) else { return nil }
        switch endYearCount {
        case .astronomical: return y
        case .ce: return y > 0 ? y : nil
        case .bc: return y > 0 ? 1 - y : nil
        }
    }

    private var startDateValidation: DateComponentsValidationResult {
        guard let y = startAstrYear else {
            return DateComponentsValidationResult(isValid: false, message: ac(AstroCyclesKeys.invalidYear))
        }
        return AstronomicalDateValidation.validateDateComponents(
            year: y, month: startMonth, day: startDay, gregorian: startCalendar == .gregorian)
    }

    private var endDateValidation: DateComponentsValidationResult {
        guard let y = endAstrYear else {
            return DateComponentsValidationResult(isValid: false, message: ac(AstroCyclesKeys.invalidYear))
        }
        return AstronomicalDateValidation.validateDateComponents(
            year: y, month: endMonth, day: endDay, gregorian: endCalendar == .gregorian)
    }

    private var hasSelections: Bool {
        switch factorMode {
        case .single: return !selectedFactors.isEmpty
        case .pairs:  return !factorPairs.isEmpty
        }
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
        startDateValidation.isValid && endDateValidation.isValid && endDateIsAfterStart && hasSelections
    }

    private var canAddPair: Bool {
        guard let a = pendingFactorA, let b = pendingFactorB, a != b else { return false }
        guard factorPairs.count < maxPairs else { return false }
        return !factorPairs.contains { $0.factorA == a && $0.factorB == b }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(ac(AstroCyclesKeys.title))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                GroupBox(ac(AstroCyclesKeys.startDate)) {
                    dateInputRow(
                        yearText: $startYearText, month: $startMonth, day: $startDay,
                        calendar: $startCalendar, yearCount: $startYearCount,
                        validation: startDateValidation)
                }

                GroupBox(ac(AstroCyclesKeys.endDate)) {
                    dateInputRow(
                        yearText: $endYearText, month: $endMonth, day: $endDay,
                        calendar: $endCalendar, yearCount: $endYearCount,
                        validation: endDateValidation)
                }

                if startDateValidation.isValid && endDateValidation.isValid && !endDateIsAfterStart {
                    Text(ac(AstroCyclesKeys.endDateOrder))
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                FieldBlock(ac(AstroCyclesKeys.observerPosition)) {
                    Picker(ac(AstroCyclesKeys.observerPosition), selection: $observerPosition) {
                        ForEach(ObserverPositions.allCases.filter { $0 != .topoCentric }, id: \.self) { pos in
                            Text(LocalizedStringKey(pos.rbKey)).tag(pos)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .focusable(true)
                }

                FieldBlock(ac(AstroCyclesKeys.coordinate)) {
                    Picker(ac(AstroCyclesKeys.coordinate), selection: $selectedCoordinate) {
                        ForEach(availableCoordinates, id: \.self) { coord in
                            Text(LocalizedStringKey(coord.rbKey)).tag(coord)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .focusable(true)
                }

                FieldBlock(ac(AstroCyclesKeys.ayanamsha)) {
                    Picker(ac(AstroCyclesKeys.ayanamsha), selection: $ayanamsha) {
                        ForEach(Ayanamshas.allCases, id: \.self) { ayan in
                            Text(LocalizedStringKey(ayan.rbKey)).tag(ayan)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .focusable(true)
                }

                Picker("", selection: $factorMode) {
                    Text(ac(AstroCyclesKeys.singleFactors)).tag(FactorSelectionMode.single)
                    Text(ac(AstroCyclesKeys.pairsOfFactors)).tag(FactorSelectionMode.pairs)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 300)

                if factorMode == .single {
                    SingleFactorSelectorView(
                        selectedFactors: $selectedFactors,
                        factors: availableFactors,
                        maxFactors: maxSingleFactors,
                        countLabel: String(format: ac(AstroCyclesKeys.selectedCount), selectedFactors.count, maxSingleFactors)
                    )
                } else {
                    pairsView
                }

                Button(ac(AstroCyclesKeys.calculate)) { calculate() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .disabled(!canCalculate)

                if let warning = periodWarning {
                    Text(warning)
                        .foregroundStyle(.orange)
                        .font(.callout)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: observerPosition) { _, _ in
                let coords = availableCoordinates
                if !coords.contains(selectedCoordinate) { selectedCoordinate = .longitude }
                let factors = availableFactors
                selectedFactors.removeAll { !factors.contains($0) }
                if let a = pendingFactorA, !factors.contains(a) { pendingFactorA = nil }
                if let b = pendingFactorB, !factors.contains(b) { pendingFactorB = nil }
                factorPairs.removeAll { !factors.contains($0.factorA) || !factors.contains($0.factorB) }
            }
        }
        .controlSize(.small)
        .navigationTitle(ac(AstroCyclesKeys.title))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: ac(AstroCyclesKeys.help))
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
                Text(ac(AstroCyclesKeys.year)).foregroundStyle(.secondary)
                TextField("", text: yearText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 100)
                    .adaptiveBorder()
                Text(ac(AstroCyclesKeys.month)).foregroundStyle(.secondary)
                NumericPickerField(range: 1...12, fieldWidth: 35, format: { String($0) }, selection: month)
                Text(ac(AstroCyclesKeys.day)).foregroundStyle(.secondary)
                NumericPickerField(range: 1...31, fieldWidth: 35, format: { String($0) }, selection: day)
            }
            .fixedSize(horizontal: true, vertical: false)
            HStack(spacing: 8) {
                Picker(ac(AstroCyclesKeys.calendar), selection: calendar) {
                    ForEach(CalendarStyle.allCases) { style in
                        Text(LocalizedStringKey(style.rbKey)).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)
                .labelsHidden()
                .focusable(true)
                Picker(ac(AstroCyclesKeys.yearCount), selection: yearCount) {
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

    // MARK: - Factor pairs

    @ViewBuilder
    private var pairsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 16) {
                FactorColumnView(title: ac(AstroCyclesKeys.factorA), selectedFactor: $pendingFactorA, factors: availableFactors)
                FactorColumnView(title: ac(AstroCyclesKeys.factorB), selectedFactor: $pendingFactorB, factors: availableFactors)
            }
            Button(ac(AstroCyclesKeys.addPair)) {
                guard let a = pendingFactorA, let b = pendingFactorB, a != b else { return }
                factorPairs.append(FactorPair(factorA: a, factorB: b))
                pendingFactorA = nil
                pendingFactorB = nil
            }
            .buttonStyle(.bordered)
            .disabled(!canAddPair)
            if !factorPairs.isEmpty {
                addedPairsListView
            }
        }
    }


    @ViewBuilder
    private var addedPairsListView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ac(AstroCyclesKeys.addedPairs)).font(.headline)
            ForEach(factorPairs) { pair in
                PairRow(pair: pair) { factorPairs.removeAll { $0.id == pair.id } }
            }
        }
    }

    // MARK: - Calculate

    private func calculate() {
        periodWarning = nil
        cyclesModel.singleResults = []
        cyclesModel.pairResults = []
        cyclesModel.factorPairs = []

        let allFactors: [Factors] = factorMode == .single
            ? selectedFactors
            : factorPairs.flatMap { [$0.factorA, $0.factorB] }

        let specs = allFactors.compactMap { $0.cycleSpec }
        guard !specs.isEmpty,
              let smallestInterval = specs.map({ $0.interval }).min(),
              let smallestMaxPeriod = specs.map({ $0.maxPeriod }).min(),
              let startYear = startAstrYear,
              let endYear = endAstrYear
        else { return }

        let midnight = AstronomicalTime(HourDecimal: 0.0)
        let jdStart = seWrapper.julianDay(
            date: AstronomicalDate(Year: startYear, Month: startMonth, Day: startDay, Gregorian: startCalendar == .gregorian),
            time: midnight)
        let jdEnd = seWrapper.julianDay(
            date: AstronomicalDate(Year: endYear, Month: endMonth, Day: endDay, Gregorian: endCalendar == .gregorian),
            time: midnight)

        let periodDays = Int(round(jdEnd - jdStart))

        if periodDays > smallestMaxPeriod {
            periodWarning = String(format: ac(AstroCyclesKeys.warningMaxPeriod), smallestMaxPeriod, periodDays)
            return
        }

        cyclesModel.isPairs = factorMode == .pairs
        cyclesModel.coordinate = selectedCoordinate

        switch factorMode {
        case .single:
            cyclesModel.singleResults = selectedFactors.map { factor in
                let request = PeriodCalculatorRequest(
                    Factor: factor,
                    Interval: smallestInterval,
                    JdStart: jdStart,
                    JdEnd: jdEnd,
                    Coordinate: selectedCoordinate,
                    Ayanamsha: ayanamsha,
                    ObserverPosition: observerPosition
                )
                return (factor: factor, series: PeriodCalculator.PerformCalculation(request, seWrapper: seWrapper))
            }
        case .pairs:
            let pairs = factorPairs.map { (factor1: $0.factorA, factor2: $0.factorB) }
            cyclesModel.factorPairs = pairs
            let request = PeriodDifferenceRequest(
                FactorPairs: pairs,
                Interval: smallestInterval,
                JdStart: jdStart,
                JdEnd: jdEnd,
                Coordinate: selectedCoordinate,
                Ayanamsha: ayanamsha,
                ObserverPosition: observerPosition
            )
            cyclesModel.pairResults = PeriodDifference.PerformCalculation(request, seWrapper: seWrapper)
        }
    }
}

// MARK: - Added pair row

private struct PairRow: View {
    let pair: FactorPair
    let onRemove: () -> Void

    var body: some View {
        HStack {
            Text(NSLocalizedString(pair.factorA.localizedName, comment: ""))
            Text("↔").foregroundStyle(.secondary)
            Text(NSLocalizedString(pair.factorB.localizedName, comment: ""))
            Spacer()
            Button(action: onRemove) {
                Image(systemName: "xmark.circle").foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 8)
        .background(Color.primary.opacity(0.04))
        .cornerRadius(4)
    }
}

// MARK: - Single factor selector

private struct SingleFactorSelectorView: View {
    @Binding var selectedFactors: [Factors]
    let factors: [Factors]
    let maxFactors: Int
    let countLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(countLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
                    ForEach(factors, id: \.rawValue) { factor in
                        FactorCheckRow(
                            factor: factor,
                            isSelected: selectedFactors.contains(factor),
                            isDisabled: !selectedFactors.contains(factor) && selectedFactors.count >= maxFactors
                        ) {
                            if selectedFactors.contains(factor) {
                                selectedFactors.removeAll { $0 == factor }
                            } else if selectedFactors.count < maxFactors {
                                selectedFactors.append(factor)
                            }
                        }
                    }
                }
                .padding(4)
            }
            .frame(height: 280)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.15), lineWidth: 1))
        }
    }
}

private struct FactorCheckRow: View {
    let factor: Factors
    let isSelected: Bool
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        let iconName = isSelected ? "checkmark.square.fill" : "square"
        let iconColor: Color = isSelected ? .accentColor : .secondary
        let textColor: Color = isDisabled ? .secondary : .primary
        let bgColor: Color = isSelected ? Color.accentColor.opacity(0.1) : .clear
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: iconName).foregroundStyle(iconColor)
                Text(NSLocalizedString(factor.localizedName, comment: "")).foregroundStyle(textColor)
                Spacer()
            }
            .padding(.vertical, 3)
            .padding(.horizontal, 6)
            .background(bgColor)
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

// MARK: - Factor column

private struct FactorColumnView: View {
    let title: String
    @Binding var selectedFactor: Factors?
    let factors: [Factors]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(factors, id: \.rawValue) { factor in
                        FactorColumnRow(factor: factor, isSelected: selectedFactor == factor) {
                            selectedFactor = selectedFactor == factor ? nil : factor
                        }
                    }
                }
            }
            .frame(height: 240)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.15), lineWidth: 1))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FactorColumnRow: View {
    let factor: Factors
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let rowBg: Color = isSelected ? Color.accentColor.opacity(0.15) : .clear
        Button(action: onTap) {
            HStack {
                Text(NSLocalizedString(factor.localizedName, comment: ""))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(rowBg)
        }
        .buttonStyle(.plain)
    }
}
