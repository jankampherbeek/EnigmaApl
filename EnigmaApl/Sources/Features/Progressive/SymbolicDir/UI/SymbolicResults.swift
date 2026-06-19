// SymbolicResults.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "SymbolicDir", bundle: .main, comment: "")
}

// MARK: - Tab enum

private enum SymbolicResultTab: String, CaseIterable {
    case positions, matches, midpoints, dualWheel
}

// MARK: - Main view

struct SymbolicResults: View {
    @EnvironmentObject private var symbolicModel: SymbolicModel
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var selectedTab: SymbolicResultTab = .positions
    @State private var blackWhite:  Bool = false
    @State private var hideAspects: Bool = false
    @State private var showExport:  Bool = false
    @State private var showHelp:    Bool = false

    // Column widths – positions tab
    private let glyphWidth: CGFloat     = 32
    private let longitudeWidth: CGFloat = 120

    // Column widths – matches tab
    private let glyphW: CGFloat = 36
    private let orbW:   CGFloat = 70
    private let exactW: CGFloat = 100

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(SymbolicDirKeys.resultsTitle))
                    .font(.title2.weight(.semibold))

                if symbolicModel.results.isEmpty {
                    Text(t(SymbolicDirKeys.noResults))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    Picker("", selection: $selectedTab) {
                        Text(t(SymbolicDirKeys.tabPositions)).tag(SymbolicResultTab.positions)
                        Text(t(SymbolicDirKeys.tabMatches)).tag(SymbolicResultTab.matches)
                        Text(t(SymbolicDirKeys.tabMidpoints)).tag(SymbolicResultTab.midpoints)
                        Text(t(SymbolicDirKeys.tabDualWheel)).tag(SymbolicResultTab.dualWheel)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 650)

                    tabContent
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(SymbolicDirKeys.resultsTitle))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(SymbolicDirKeys.helpResults))
        }
        .sheet(isPresented: $showExport) {
            if let chart = chartSession.selectedChart,
               let config = activeConfigs.first {
                WheelExportSheet(
                    wheelView: DualWheelCanvas(
                        radixData:    WheelPlotDataBuilder.build(from: chart, config: config),
                        transitItems: resolvedDirectedItems(ascLong: chart.HousePositions.ascendant.longitude),
                        theme:        blackWhite ? .blackWhite : .color,
                        showAspects:  !hideAspects
                    )
                )
            }
        }
    }

    // MARK: - Tab routing

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .positions:
            positionsTable
                .frame(maxWidth: 400, alignment: .leading)
        case .matches:
            matchesTable
                .frame(maxWidth: 700, alignment: .leading)
        case .midpoints:
            ProgressiveMidpointsTab(
                progressivePositions: symbolicModel.results,
                radixSectionTitle: t(SymbolicDirKeys.midpointsRadixHeader),
                progressiveSectionTitle: t(SymbolicDirKeys.midpointsSymbolicHeader),
                noMatchesText: t(SymbolicDirKeys.midpointsNoMatches)
            )
        case .dualWheel:
            VStack(alignment: .leading, spacing: 8) {
                dualWheelControls
                dualWheelView
            }
        }
    }

    // MARK: - Positions tab

    private var positionsTable: some View {
        GroupBox {
            VStack(spacing: 0) {
                positionsHeader
                Divider()
                ForEach(Array(sortedResults.enumerated()), id: \.element.factor.rawValue) { index, item in
                    positionRow(item.factor, longitude: item.longitude, index: index)
                }
            }
        }
    }

    private var positionsHeader: some View {
        HStack(spacing: 12) {
            Spacer().frame(width: glyphWidth)
            Text(t(SymbolicDirKeys.columnLongitude))
                .frame(width: longitudeWidth, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func positionRow(_ factor: Factors, longitude: Double, index: Int) -> some View {
        let (dmsString, sign, valid) = PositionInDegreesConversion.DoubleToDmsSign(longitude)
        return HStack(spacing: 12) {
            Text(GlyphSelector.getGlyphForFactor(factor))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphWidth, alignment: .center)

            HStack(spacing: 4) {
                if valid, let sign {
                    Text(dmsString)
                    Text(GlyphSelector.getGlyphForSign(sign))
                        .font(.custom("EnigmaAstrology3", size: 14))
                } else {
                    Text(String(format: "%.4f°", longitude))
                }
            }
            .frame(width: longitudeWidth, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Matches tab

    @ViewBuilder
    private var matchesTable: some View {
        if matchRows.isEmpty {
            Text(t(SymbolicDirKeys.matchesNoMatches))
                .foregroundStyle(.secondary)
                .font(.callout)
        } else {
            GroupBox {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        matchesHeader
                        Divider()
                        ForEach(Array(matchRows.enumerated()), id: \.offset) { index, row in
                            matchRow(row, index: index)
                        }
                    }
                }
            }
        }
    }

    private var matchesHeader: some View {
        HStack(spacing: 8) {
            Spacer().frame(width: glyphW)
            Spacer().frame(width: glyphW)
            Spacer().frame(width: glyphW)
            Text(t(SymbolicDirKeys.matchesColOrb))
                .frame(width: orbW, alignment: .trailing)
            Text(t(SymbolicDirKeys.matchesColExactness))
                .frame(width: exactW, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func matchRow(_ row: AspectMatchRow, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(row.directedGlyph)
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
            Text(row.aspectGlyph)
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
            Text(row.radixGlyph)
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
            Text(row.orbText)
                .frame(width: orbW, alignment: .trailing)
                .foregroundStyle(.secondary)
            Text("\(row.exactness)%")
                .frame(width: exactW, alignment: .trailing)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Dual Wheel tab

    private var dualWheelControls: some View {
        HStack(spacing: 8) {
            Button { blackWhite.toggle() } label: {
                Image(systemName: blackWhite ? "circle.lefthalf.filled" : "paintpalette")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(blackWhite ? "Switch to color" : "Switch to black and white")

            Button { hideAspects.toggle() } label: {
                Image(systemName: "angle")
                    .foregroundStyle(hideAspects ? .secondary : .primary)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(hideAspects ? "Show aspects" : "Hide aspects")

            Button { showExport = true } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Export")
        }
    }

    @ViewBuilder
    private var dualWheelView: some View {
        if let chart = chartSession.selectedChart,
           let config = activeConfigs.first {
            DualWheelCanvas(
                radixData:    WheelPlotDataBuilder.build(from: chart, config: config),
                transitItems: resolvedDirectedItems(ascLong: chart.HousePositions.ascendant.longitude),
                theme:        blackWhite ? .blackWhite : .color,
                showAspects:  !hideAspects
            )
        }
    }

    // MARK: - Helpers

    private struct FactorResult {
        let factor: Factors
        let longitude: Double
    }

    private var sortedResults: [FactorResult] {
        symbolicModel.results
            .map { FactorResult(factor: $0.key, longitude: $0.value.longitude) }
            .sorted { $0.factor.rawValue < $1.factor.rawValue }
    }

    private var foundMatches: [FoundAspect] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return TransitAspectsOrchestrator.calculate(
            transitPositions: symbolicModel.results,
            radixChart:       chart,
            factorConfig:     config.factorConfig,
            aspectConfig:     config.aspectConfig,
            baseOrb:          config.progressionsConfig.symbolicDirections.orb
        )
    }

    private var matchRows: [AspectMatchRow] {
        foundMatches.map { found in
            let exactness = found.maxOrb > 0
                ? max(0, min(100, Int((1.0 - found.orb / found.maxOrb) * 100)))
                : 100
            let totalMin = Int(abs(found.orb) * 60)
            let orbText  = "\(totalMin / 60)°\(String(format: "%02d", totalMin % 60))'"
            return AspectMatchRow(
                directedGlyph: GlyphSelector.getGlyphForFactor(found.factor1),
                aspectGlyph:   GlyphSelector.getGlyphForAspect(found.aspect),
                radixGlyph:    GlyphSelector.getGlyphForFactor(found.factor2),
                orbText:       orbText,
                exactness:     exactness
            )
        }
    }

    private func resolvedDirectedItems(ascLong: Double) -> [WheelPlotItem] {
        let items: [WheelPlotItem] = symbolicModel.results.map { factor, position in
            let mundane = WheelGeometry.mundaneAngle(
                longitude: position.longitude,
                ascendantLongitude: ascLong
            )
            return WheelPlotItem(
                factor:            factor,
                glyph:             GlyphSelector.getGlyphForFactor(factor),
                eclipticLongitude: position.longitude,
                mundaneAngle:      mundane,
                plotAngle:         mundane,
                positionText:      cuspPositionText(longitude: position.longitude),
                speedType:         .direct
            )
        }
        return GlyphOverlapResolver.resolve(items)
    }
}

// MARK: - Row model

private struct AspectMatchRow {
    let directedGlyph: String
    let aspectGlyph:   String
    let radixGlyph:    String
    let orbText:       String
    let exactness:     Int
}
