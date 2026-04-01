// HarmonicMatchesView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct HarmonicMatchesView: View {
    let harmonicNumber: Double
    @Binding var harmonicText: String

    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var showFactsheet = false
    @State private var showHelp      = false

    private let glyphW: CGFloat = 28
    private let orbW:   CGFloat = 70
    private let exactW: CGFloat = 100

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "RadixAnalysis", bundle: .main, comment: "")
    }

    private var matches: [HarmonicMatch] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return HarmonicsOrchestrator.matches(
            chart: chart,
            factorConfig: config.factorConfig,
            orbConfig: config.orbConfig,
            harmonic: harmonicNumber
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(RadixAnalysisKeys.matchesTitle))
                    .font(.title2.weight(.semibold))

                harmonicInput

                if matches.isEmpty {
                    Text(t(RadixAnalysisKeys.matchesNoData))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    matchesTable
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showFactsheet = true } label: {
                    Image(systemName: "book.pages")
                }
                .accessibilityLabel("Factsheet")
            }
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showFactsheet) {
            FactsheetView(baseName: "harmonics")
        }
        .sheet(isPresented: $showHelp) {
            NavigationStack {
                ScrollView {
                    Text(t(RadixAnalysisKeys.matchesHelp))
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
    private var matchesTable: some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 8) {
                        Text(t(RadixAnalysisKeys.colHarmonicFactor))
                            .frame(width: glyphW, alignment: .center)
                        Text(t(RadixAnalysisKeys.colRadixFactor))
                            .frame(width: glyphW, alignment: .center)
                        Text(t(RadixAnalysisKeys.colOrb))
                            .frame(width: orbW, alignment: .trailing)
                        Text(t(RadixAnalysisKeys.colExactness))
                            .frame(width: exactW, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)

                    Divider()

                    ForEach(Array(matches.enumerated()), id: \.offset) { index, match in
                        matchRow(match, index: index)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func matchRow(_ match: HarmonicMatch, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(GlyphSelector.getGlyphForFactor(match.harmonicFactor))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(match.harmonicFactor.localizedName)

            Text(GlyphSelector.getGlyphForFactor(match.radixFactor))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(match.radixFactor.localizedName)

            Text(orbText(match.actualOrb))
                .frame(width: orbW, alignment: .trailing)
                .foregroundStyle(.secondary)

            Text("\(exactness(match))%")
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

    private func exactness(_ match: HarmonicMatch) -> Int {
        guard match.maxOrb > 0 else { return 100 }
        return max(0, min(100, Int((1.0 - match.actualOrb / match.maxOrb) * 100)))
    }
}
