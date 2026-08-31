// ProgressiveCalendarInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ProgressiveCalendar", bundle: .main, comment: "")
}

struct ProgressiveCalendarInputScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var model: ProgressiveCalendarModel
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var startDateText: String = ""
    @State private var endDateText: String = ""

    private enum FactorSheetKind: Identifiable {
        case transit, secondary, symbolic, radix
        var id: Self { self }
    }
    @State private var factorSheet: FactorSheetKind?
    @State private var showAspectSheet = false
    @State private var showHelp = false

    private var hasChart: Bool { chartSession.selectedChart != nil }
    private var savedConfig: ProgressiveCalendarConfig {
        activeConfigs.first?.progressionsConfig.progressiveCalendar ?? ProgressiveCalendarConfig()
    }

    var body: some View {
        Group {
            if !hasChart {
                ContentUnavailableView(
                    t(ProgressiveCalendarKeys.title),
                    systemImage: "calendar",
                    description: Text(t(ProgressiveCalendarKeys.noChart))
                )
            } else {
                form
            }
        }
        .navigationTitle(t(ProgressiveCalendarKeys.title))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(ProgressiveCalendarKeys.help))
        }
        .sheet(item: $factorSheet) { kind in
            factorSheetView(for: kind)
        }
        .sheet(isPresented: $showAspectSheet) {
            ProgressiveCalendarAspectSelectionSheet(currentSelection: model.aspects)
                .environmentObject(model)
        }
        .onAppear {
            model.syncFromConfig(savedConfig)
        }
    }

    // MARK: - Form

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(t(ProgressiveCalendarKeys.title))
                    .font(.title2.weight(.semibold))

                if let name = chartSession.selected?.name {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                techniquesSection
                radixFactorsSection
                eventKindsSection
                orbsSection
                dateRangeSection

                if model.isModified(against: savedConfig) {
                    Button(t(ProgressiveCalendarKeys.settingsReset)) {
                        model.syncFromConfig(savedConfig)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                calculateButton

                if let error = model.inputErrorMessage {
                    Text(error).font(.callout).foregroundStyle(.red)
                } else if model.isCalculating {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text(t(ProgressiveCalendarKeys.calculating)).foregroundStyle(.secondary)
                    }
                    .font(.callout)
                } else if let error = model.errorMessage {
                    Text(error).font(.callout).foregroundStyle(.secondary)
                } else if model.hasResults {
                    Text(String(format: t(ProgressiveCalendarKeys.resultsSummary), model.events.count, model.episodes.count))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 700, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Techniques

    private var techniquesSection: some View {
        GroupBox(t(ProgressiveCalendarKeys.techniquesHeader)) {
            VStack(alignment: .leading, spacing: 10) {
                techniqueRow(t(ProgressiveCalendarKeys.useTransits), isOn: $model.useTransits) {
                    factorSheet = .transit
                } buttonLabel: {
                    t(ProgressiveCalendarKeys.transitFactorsButton)
                } glyphs: {
                    factorGlyphs(model.transitFactors)
                }

                techniqueRow(t(ProgressiveCalendarKeys.useSecondaryDirections), isOn: $model.useSecondaryDirections) {
                    factorSheet = .secondary
                } buttonLabel: {
                    t(ProgressiveCalendarKeys.secondaryFactorsButton)
                } glyphs: {
                    factorGlyphs(model.secondaryDirectionFactors)
                }

                techniqueRow(t(ProgressiveCalendarKeys.useSymbolicDirections), isOn: $model.useSymbolicDirections) {
                    factorSheet = .symbolic
                } buttonLabel: {
                    t(ProgressiveCalendarKeys.symbolicFactorsButton)
                } glyphs: {
                    factorGlyphs(model.symbolicDirectionFactors)
                }

                if model.useSymbolicDirections {
                    LabeledContent(t(ProgressiveCalendarKeys.symbolicKeyLabel)) {
                        Picker("", selection: $model.symbolicKey) {
                            ForEach(SymbolicKeys.allCases, id: \.self) { key in
                                Text(NSLocalizedString(key.rbKey, comment: "")).tag(key)
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: 200)
                    }
                }
            }
            .padding(.vertical, 4)
            .font(.callout)
        }
        .frame(maxWidth: 620)
    }

    @ViewBuilder
    private func techniqueRow(
        _ label: String, isOn: Binding<Bool>,
        openSheet: @escaping () -> Void, buttonLabel: () -> String, glyphs: () -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(label, isOn: isOn)
            HStack(spacing: 8) {
                Button(buttonLabel()) { openSheet() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(!isOn.wrappedValue)
                Text(glyphs())
                    .font(.custom("EnigmaAstrology3", size: 16))
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Radix factors

    private var radixFactorsSection: some View {
        HStack(spacing: 8) {
            Button(t(ProgressiveCalendarKeys.radixFactorsButton)) { factorSheet = .radix }
                .buttonStyle(.bordered)
            Text(factorGlyphs(model.radixFactors))
                .font(.custom("EnigmaAstrology3", size: 18))
                .lineLimit(2)
        }
    }

    // MARK: - Event kinds

    private var eventKindsSection: some View {
        GroupBox(t(ProgressiveCalendarKeys.eventKindsHeader)) {
            VStack(alignment: .leading, spacing: 8) {
                Toggle(t(ProgressiveCalendarKeys.useAspectsToRadix), isOn: $model.useAspectsToRadix)
                Toggle(t(ProgressiveCalendarKeys.useParallelsToRadix), isOn: $model.useParallelsToRadix)
                Toggle(t(ProgressiveCalendarKeys.useAspectsProgToProg), isOn: $model.useAspectsProgToProg)
                Toggle(t(ProgressiveCalendarKeys.useParallelsProgToProg), isOn: $model.useParallelsProgToProg)
                Toggle(t(ProgressiveCalendarKeys.useCuspConjunctions), isOn: $model.useCuspConjunctions)
                Toggle(t(ProgressiveCalendarKeys.useStations), isOn: $model.useRetrogradeDirectStations)
                Toggle(t(ProgressiveCalendarKeys.useOobEnterExit), isOn: $model.useOobEnterExit)
                Toggle(t(ProgressiveCalendarKeys.useDeclinationExtremes), isOn: $model.useDeclinationExtremes)

                HStack(spacing: 8) {
                    Button(t(ProgressiveCalendarKeys.aspectsButton)) { showAspectSheet = true }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    Text(model.aspects.map { GlyphSelector.getGlyphForAspect($0) }.joined())
                        .font(.custom("EnigmaAstrology3", size: 16))
                }
            }
            .padding(.vertical, 4)
            .font(.callout)
        }
        .frame(maxWidth: 500)
    }

    // MARK: - Orbs

    private var orbsSection: some View {
        GroupBox(t(ProgressiveCalendarKeys.orbsHeader)) {
            VStack(alignment: .leading, spacing: 8) {
                OrbDegMinRow(label: t(ProgressiveCalendarKeys.aspectOrbLabel), orb: $model.aspectOrb)
                OrbDegMinRow(label: t(ProgressiveCalendarKeys.parallelOrbLabel), orb: $model.parallelOrb)
                OrbDegMinRow(label: t(ProgressiveCalendarKeys.cuspOrbLabel), orb: $model.cuspOrb)
            }
            .padding(.vertical, 4)
            .font(.callout)
        }
        .frame(maxWidth: 400)
    }

    // MARK: - Date range

    private var dateRangeSection: some View {
        GroupBox(t(ProgressiveCalendarKeys.dateRangeHeader)) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(t(ProgressiveCalendarKeys.startDateLabel)).font(.subheadline.weight(.medium))
                    TextField(t(ProgressiveCalendarKeys.datePlaceholder), text: $startDateText)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 200)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(t(ProgressiveCalendarKeys.endDateLabel)).font(.subheadline.weight(.medium))
                    TextField(t(ProgressiveCalendarKeys.datePlaceholder), text: $endDateText)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 200)
                }
                Text(String(format: t(ProgressiveCalendarKeys.maxRangeNote), Int(model.maxRangeInDays.rounded())))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .frame(maxWidth: 400)
    }

    // MARK: - Calculate

    private var calculateButton: some View {
        Button(t(ProgressiveCalendarKeys.calculate)) {
            guard let namedChart = chartSession.selected else { return }
            model.calculate(
                startDateText: startDateText,
                endDateText: endDateText,
                natalJD: namedChart.baseRequest.JulianDay,
                radixChart: namedChart.chart
            )
        }
        .buttonStyle(.borderedProminent)
        .disabled(model.isCalculating || !hasChart)
    }

    // MARK: - Sheets

    @ViewBuilder
    private func factorSheetView(for kind: FactorSheetKind) -> some View {
        switch kind {
        case .transit:
            ProgressiveCalendarFactorSelectionSheet(
                title: t(ProgressiveCalendarKeys.transitFactorsButton),
                selectableFactors: ProgressiveCalendarModel.selectableFactors,
                currentSelection: model.transitFactors
            ) { model.transitFactors = $0 }
        case .secondary:
            ProgressiveCalendarFactorSelectionSheet(
                title: t(ProgressiveCalendarKeys.secondaryFactorsButton),
                selectableFactors: ProgressiveCalendarModel.selectableFactors,
                currentSelection: model.secondaryDirectionFactors
            ) { model.secondaryDirectionFactors = $0 }
        case .symbolic:
            ProgressiveCalendarFactorSelectionSheet(
                title: t(ProgressiveCalendarKeys.symbolicFactorsButton),
                selectableFactors: ProgressiveCalendarModel.selectableFactors,
                currentSelection: model.symbolicDirectionFactors
            ) { model.symbolicDirectionFactors = $0 }
        case .radix:
            ProgressiveCalendarFactorSelectionSheet(
                title: t(ProgressiveCalendarKeys.radixFactorsButton),
                selectableFactors: ProgressiveCalendarModel.selectableFactors,
                currentSelection: model.radixFactors
            ) { model.radixFactors = $0 }
        }
    }

    // MARK: - Helpers

    private func factorGlyphs(_ factors: [Factors]) -> String {
        factors.map { GlyphSelector.getGlyphForFactor($0) }.joined()
    }
}

// MARK: - Orb degree/minute row

/// Degree/minute stepper pair for a single orb, matching the app's established DMS
/// convention for orb display (see `ProgOrbRow` in the generic Config editors).
private struct OrbDegMinRow: View {
    let label: String
    @Binding var orb: Double

    private var deg: Int { Int(orb) }
    private var minutes: Int { Int(((orb - Double(deg)) * 60.0).rounded()) }

    var body: some View {
        LabeledContent(label) {
            HStack(spacing: 4) {
                Text("\(deg)°")
                    .frame(width: 30, alignment: .trailing)
                    .monospacedDigit()
                Stepper("", value: Binding(
                    get: { deg },
                    set: { orb = Double($0) + Double(minutes) / 60.0 }
                ), in: 0...10)
                    .labelsHidden().fixedSize()
                Text("\(minutes)'")
                    .frame(width: 30, alignment: .trailing)
                    .monospacedDigit()
                Stepper("", value: Binding(
                    get: { minutes },
                    set: { orb = Double(deg) + Double($0) / 60.0 }
                ), in: 0...59)
                    .labelsHidden().fixedSize()
            }
        }
    }
}
