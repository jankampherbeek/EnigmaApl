// HarmonicAspectsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

/// Shows all aspects between the harmonic positions, as a table with orb and exactness.
struct HarmonicAspectsView: View {
    let harmonicNumber: Double
    @Binding var harmonicText: String

    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var showHelp      = false

    // Column widths
    private let glyphW: CGFloat = 60
    private let orbW:   CGFloat = 70
    private let exactW: CGFloat = 100

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "RadixAnalysis", bundle: .main, comment: "")
    }

    private var foundAspects: [FoundAspect] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return HarmonicsOrchestrator.aspects(
            chart: chart,
            factorConfig: config.factorConfig,
            aspectConfig: config.aspectConfig,
            orbConfig: config.orbConfig,
            harmonic: harmonicNumber
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(RadixAnalysisKeys.aspectsTitle))
                    .font(.title2.weight(.semibold))

                harmonicInput

                if foundAspects.isEmpty {
                    Text(t(RadixAnalysisKeys.aspectsNoData))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    aspectsTable
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .factsheetToolbarButton(baseName: "harmonics")
        .sheet(isPresented: $showHelp) {
            NavigationStack {
                ScrollView {
                    Text(t(RadixAnalysisKeys.aspectsHelp))
                        .padding()
                }
                .navigationTitle("Help")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("OK") { showHelp = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Input field

    @ViewBuilder
    private var harmonicInput: some View {
        HStack(spacing: 8) {
            Text(t(RadixAnalysisKeys.inputLabel))
                .font(.callout)
            TextField("", text: $harmonicText)
                .textFieldStyle(.roundedBorder)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .frame(width: 80)
        }
    }

    // MARK: - Table

    @ViewBuilder
    private var aspectsTable: some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 8) {
                        Text(t(RadixAnalysisKeys.colAspFactor1)).frame(width: glyphW, alignment: .center)
                        Text(t(RadixAnalysisKeys.colAspAspect)).frame(width: glyphW, alignment: .center)
                        Text(t(RadixAnalysisKeys.colAspFactor2)).frame(width: glyphW, alignment: .center)
                        Text(t(RadixAnalysisKeys.colAspOrb)).frame(width: orbW, alignment: .trailing)
                        Text(t(RadixAnalysisKeys.colAspExactness)).frame(width: exactW, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)

                    Divider()

                    ForEach(Array(foundAspects.enumerated()), id: \.offset) { index, found in
                        aspectRow(found, index: index)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func aspectRow(_ found: FoundAspect, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(GlyphSelector.getGlyphForFactor(found.factor1))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(NSLocalizedString(found.factor1.localizedName, comment: ""))
            Text(GlyphSelector.getGlyphForAspect(found.aspect))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(NSLocalizedString(found.aspect.rbKey, comment: ""))
            Text(GlyphSelector.getGlyphForFactor(found.factor2))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(NSLocalizedString(found.factor2.localizedName, comment: ""))
            Text(orbText(found.orb))
                .frame(width: orbW, alignment: .trailing)
                .foregroundStyle(.secondary)
            Text("\(exactness(found))%")
                .frame(width: exactW, alignment: .trailing)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Helpers

    private func orbText(_ orb: Double) -> String {
        let totalMin = Int(abs(orb) * 60)
        return "\(totalMin / 60)°\(String(format: "%02d", totalMin % 60))'"
    }

    private func exactness(_ found: FoundAspect) -> Int {
        guard found.maxOrb > 0 else { return 100 }
        return max(0, min(100, Int((1.0 - found.orb / found.maxOrb) * 100)))
    }
}
