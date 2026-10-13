// HarmonicExactAspectsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

/// Shows, per harmonic, the aspect with the smallest orb between the harmonic positions.
/// Shown in the detail column when .analysisHarmonicExactAspects is active.
struct HarmonicExactAspectsScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var includeAscendant = true
    @State private var includeMc        = true
    @State private var aspectSelection: HarmonicAspectSelection = .configured
    @State private var maxHarmonic      = 12
    @State private var initialised      = false
    @State private var showHelp         = false

    private let maxHarmonicLimit = 1000

    // Column widths
    private let harmonicW: CGFloat = 70
    private let glyphW:    CGFloat = 60
    private let orbW:      CGFloat = 70

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "HarmonicExactAspects", bundle: .main, comment: "")
    }

    private var results: [HarmonicExactAspect] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return HarmonicExactAspectsOrchestrator.exactAspects(
            chart: chart,
            factorConfig: config.factorConfig,
            aspectConfig: config.aspectConfig,
            includeAscendant: includeAscendant,
            includeMc: includeMc,
            aspectSelection: aspectSelection,
            maxHarmonic: maxHarmonic
        )
    }

    var body: some View {
        Group {
            if chartSession.selectedChart == nil {
                Text(t(HarmonicExactAspectsKeys.noChart))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(t(HarmonicExactAspectsKeys.title))
                            .font(.title2.weight(.semibold))

                        options

                        if results.isEmpty {
                            Text(t(HarmonicExactAspectsKeys.noData))
                                .foregroundStyle(.secondary)
                                .font(.callout)
                        } else {
                            resultsTable
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .factsheetToolbarButton(baseName: "harmonicexactaspects")
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(HarmonicExactAspectsKeys.help))
        }
        .onAppear(perform: initialiseFromConfig)
    }

    // MARK: - Options

    @ViewBuilder
    private var options: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 20) {
                    Toggle(t(HarmonicExactAspectsKeys.includeAscendant), isOn: $includeAscendant)
                    Toggle(t(HarmonicExactAspectsKeys.includeMc), isOn: $includeMc)
                }
                Picker("", selection: $aspectSelection) {
                    Text(t(HarmonicExactAspectsKeys.aspectsConfigured)).tag(HarmonicAspectSelection.configured)
                    Text(t(HarmonicExactAspectsKeys.aspectsMajor)).tag(HarmonicAspectSelection.major)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()
                HStack(spacing: 8) {
                    Text(t(HarmonicExactAspectsKeys.maxHarmonic))
                    TextField("", value: maxHarmonicBinding, format: .number)
                        .textFieldStyle(.roundedBorder)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .frame(width: 70)
                    Stepper("", value: maxHarmonicBinding,
                            in: HarmonicExactAspectsOrchestrator.minHarmonic...maxHarmonicLimit)
                        .labelsHidden()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Keeps the maximum harmonic within 2...maxHarmonicLimit, also for typed values.
    private var maxHarmonicBinding: Binding<Int> {
        Binding(
            get: { maxHarmonic },
            set: { maxHarmonic = min(max($0, HarmonicExactAspectsOrchestrator.minHarmonic), maxHarmonicLimit) }
        )
    }

    // MARK: - Table

    @ViewBuilder
    private var resultsTable: some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 8) {
                        Text(t(HarmonicExactAspectsKeys.colHarmonic)).frame(width: harmonicW, alignment: .trailing)
                        Text(t(HarmonicExactAspectsKeys.colFactor1)).frame(width: glyphW, alignment: .center)
                        Text(t(HarmonicExactAspectsKeys.colAspect)).frame(width: glyphW, alignment: .center)
                        Text(t(HarmonicExactAspectsKeys.colFactor2)).frame(width: glyphW, alignment: .center)
                        Text(t(HarmonicExactAspectsKeys.colOrb)).frame(width: orbW, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)

                    Divider()

                    ForEach(Array(results.enumerated()), id: \.offset) { index, result in
                        resultRow(result, index: index)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func resultRow(_ result: HarmonicExactAspect, index: Int) -> some View {
        HStack(spacing: 8) {
            Text("\(result.harmonic)")
                .frame(width: harmonicW, alignment: .trailing)
            Text(GlyphSelector.getGlyphForFactor(result.factor1))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(NSLocalizedString(result.factor1.localizedName, comment: ""))
            Text(GlyphSelector.getGlyphForAspect(result.aspect))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(NSLocalizedString(result.aspect.rbKey, comment: ""))
            Text(GlyphSelector.getGlyphForFactor(result.factor2))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(NSLocalizedString(result.factor2.localizedName, comment: ""))
            Text(orbText(result.orb))
                .frame(width: orbW, alignment: .trailing)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Helpers

    /// Ascendant and MC start as selected when they are in use in the configuration.
    private func initialiseFromConfig() {
        guard !initialised, let config = activeConfigs.first else { return }
        let used = Set(config.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor })
        includeAscendant = used.contains(.ascendant)
        includeMc        = used.contains(.mc)
        initialised      = true
    }

    private func orbText(_ orb: Double) -> String {
        let totalMin = Int(abs(orb) * 60)
        return "\(totalMin / 60)°\(String(format: "%02d", totalMin % 60))'"
    }
}
