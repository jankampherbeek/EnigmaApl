// DeclinationParallelsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct DeclinationParallelsView: View {
    @Binding var activeTab: DeclinationsTab

    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var showFactsheet = false
    @State private var showHelp      = false

    // Column widths
    private let glyphW: CGFloat = 28
    private let declW:  CGFloat = 90
    private let orbW:   CGFloat = 90
    private let exactW: CGFloat = 100

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Declinations", bundle: .main, comment: "")
    }

    private var parallels: [DefinedParallel] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return DeclinationsOrchestrator.parallels(
            chart: chart,
            factorConfig: config.factorConfig,
            orbConfig: config.orbConfig
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(DeclinationsKeys.parallelsTitle))
                    .font(.title2.weight(.semibold))

                if parallels.isEmpty {
                    Text(t(DeclinationsKeys.parallelsNoData))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    parallelsTable
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                tabPicker
            }
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
            FactsheetView(baseName: "declinations")
        }
        .sheet(isPresented: $showHelp) {
            NavigationStack {
                ScrollView {
                    Text(t(DeclinationsKeys.parallelsHelp))
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

    // MARK: - Table

    @ViewBuilder
    private var parallelsTable: some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Text(t(DeclinationsKeys.parallelsColFactor1))
                            .frame(width: glyphW, alignment: .center)
                        Text(t(DeclinationsKeys.parallelsColDecl1))
                            .frame(width: declW, alignment: .trailing)
                        Text(t(DeclinationsKeys.parallelsColAspect))
                            .frame(width: glyphW, alignment: .center)
                        Text(t(DeclinationsKeys.parallelsColFactor2))
                            .frame(width: glyphW, alignment: .center)
                        Text(t(DeclinationsKeys.parallelsColDecl2))
                            .frame(width: declW, alignment: .trailing)
                        Text(t(DeclinationsKeys.parallelsColOrb))
                            .frame(width: orbW, alignment: .trailing)
                        Text(t(DeclinationsKeys.parallelsColExactness))
                            .frame(width: exactW, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)

                    Divider()

                    ForEach(Array(parallels.enumerated()), id: \.offset) { index, parallel in
                        parallelRow(parallel, index: index, chart: chartSession.selectedChart)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func parallelRow(_ parallel: DefinedParallel, index: Int, chart: FullChart?) -> some View {
        let decl1 = declination(for: parallel.factor1, in: chart)
        let decl2 = declination(for: parallel.factor2, in: chart)
        HStack(spacing: 8) {
            Text(GlyphSelector.getGlyphForFactor(parallel.factor1))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(parallel.factor1.localizedName)

            Text(decl1.map { PositionInDegreesConversion.DoubleToDms($0) } ?? "-")
                .frame(width: declW, alignment: .trailing)
                .monospacedDigit()

            Text(parallel.isContraParallel ? "\u{F010}" : "\u{F000}")
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)

            Text(GlyphSelector.getGlyphForFactor(parallel.factor2))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(parallel.factor2.localizedName)

            Text(decl2.map { PositionInDegreesConversion.DoubleToDms($0) } ?? "-")
                .frame(width: declW, alignment: .trailing)
                .monospacedDigit()

            Text(orbText(parallel.actualOrb))
                .frame(width: orbW, alignment: .trailing)
                .foregroundStyle(.secondary)

            Text("\(exactness(parallel))%")
                .frame(width: exactW, alignment: .trailing)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Helpers

    private func declination(for factor: Factors, in chart: FullChart?) -> Double? {
        chart?.Coordinates[factor]?.equatorial.first?.deviation
    }

    private func orbText(_ orb: Double) -> String {
        let totalSec = Int(abs(orb) * 3600)
        let deg = totalSec / 3600
        let min = (totalSec % 3600) / 60
        let sec = totalSec % 60
        return "\(deg)°\(String(format: "%02d", min))'\(String(format: "%02d", sec))\""
    }

    private func exactness(_ parallel: DefinedParallel) -> Int {
        guard parallel.maxOrb > 0 else { return 100 }
        return max(0, min(100, Int((1.0 - parallel.actualOrb / parallel.maxOrb) * 100)))
    }

    // MARK: - Tab picker

    private var tabPicker: some View {
        Picker("", selection: $activeTab) {
            Text(t(DeclinationsKeys.btnAllDeclinations)).tag(DeclinationsTab.all)
            Text(t(DeclinationsKeys.btnParallels)).tag(DeclinationsTab.parallels)
            Text(t(DeclinationsKeys.btnEquivalents)).tag(DeclinationsTab.equivalents)
            Text(t(DeclinationsKeys.btnDiagram)).tag(DeclinationsTab.diagram)
            Text(t(DeclinationsKeys.btnMidpoints)).tag(DeclinationsTab.midpoints)
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
}
