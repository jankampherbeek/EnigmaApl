// AgePointResultsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "AgePoint", bundle: .main, comment: "")
}

private enum AgePointResultTab {
    case positions, matches, wheel
}

struct AgePointResultsScreen: View {
    @EnvironmentObject private var agePointModel: AgePointModel
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var selectedTab: AgePointResultTab = .positions
    @State private var blackWhite:  Bool = false
    @State private var hideAspects: Bool = false
    @State private var showExport:  Bool = false
    @State private var showHelp:    Bool = false
    @State private var showFactsheet: Bool = false

    private let labelWidth: CGFloat    = 160
    private let positionWidth: CGFloat = 130

    private let aspectW: CGFloat = 36
    private let radixW:  CGFloat = 36
    private let orbW:    CGFloat = 70
    private let exactW:  CGFloat = 100

    private var hasResults: Bool {
        switch agePointModel.activeMode {
        case .positionsForEvent: return agePointModel.positionResult != nil
        case .overview:          return !agePointModel.overviewEntries.isEmpty
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(AgePointKeys.resultsTitle))
                    .font(.title2.weight(.semibold))

                if !hasResults {
                    Text(t(AgePointKeys.noResults))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    Picker("", selection: $selectedTab) {
                        Text(t(AgePointKeys.tabPositions)).tag(AgePointResultTab.positions)
                        if agePointModel.activeMode == .positionsForEvent {
                            Text(t(AgePointKeys.tabMatches)).tag(AgePointResultTab.matches)
                        }
                        Text(t(AgePointKeys.tabWheel)).tag(AgePointResultTab.wheel)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 500)

                    tabContent
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(AgePointKeys.resultsTitle))
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
            FactsheetView(baseName: "agepoint")
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(AgePointKeys.helpResults))
        }
        .onChange(of: agePointModel.activeMode) { _, mode in
            if mode == .overview && selectedTab == .matches {
                selectedTab = .positions
            }
        }
        .sheet(isPresented: $showExport) {
            if let plotData = radixPlotData {
                WheelExportSheet(
                    wheelView: AgePointWheelCanvas(
                        radixData:       plotData,
                        apMundaneAngle:  apMundaneAngle,
                        apLongitude:     agePointModel.positionResult,
                        overviewItems:   overviewWheelItems,
                        theme:           blackWhite ? .blackWhite : .color,
                        showAspects:     !hideAspects
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
            if agePointModel.activeMode == .overview {
                overviewPositionsTab
                    .frame(maxWidth: 500, alignment: .leading)
            } else {
                positionsTab
                    .frame(maxWidth: 500, alignment: .leading)
            }
        case .matches:
            matchesTab
        case .wheel:
            wheelTab
        }
    }

    // MARK: - Single-position tab

    @ViewBuilder
    private var positionsTab: some View {
        if let position = agePointModel.positionResult {
            GroupBox {
                VStack(spacing: 0) {
                    positionsHeader
                    Divider()
                    positionRow(position, index: 0)
                }
            }
        }
    }

    private var positionsHeader: some View {
        HStack(spacing: 12) {
            Spacer().frame(width: labelWidth)
            Text(t(AgePointKeys.columnPosition))
                .frame(width: positionWidth, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func positionRow(_ longitude: Double, index: Int) -> some View {
        let (dmsString, sign, valid) = PositionInDegreesConversion.DoubleToDmsSign(longitude)
        return HStack(spacing: 12) {
            Text(t(AgePointKeys.positionLabel))
                .frame(width: labelWidth, alignment: .leading)
            HStack(spacing: 4) {
                if valid, let sign {
                    Text(dmsString)
                    Text(GlyphSelector.getGlyphForSign(sign))
                        .font(.custom("EnigmaAstrology2", size: 14))
                } else {
                    Text(String(format: "%.4f°", longitude))
                }
            }
            .frame(width: positionWidth, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Overview positions tab

    @ViewBuilder
    private var overviewPositionsTab: some View {
        GroupBox {
            VStack(spacing: 0) {
                overviewHeader
                Divider()
                ForEach(Array(agePointModel.overviewEntries.enumerated()), id: \.offset) { index, entry in
                    overviewRow(entry, index: index)
                }
            }
        }
    }

    private var overviewHeader: some View {
        HStack(spacing: 12) {
            Text(t(AgePointKeys.overviewColLabel))
                .frame(width: labelWidth, alignment: .leading)
            Text(t(AgePointKeys.columnPosition))
                .frame(width: positionWidth, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func overviewRow(_ entry: AgePointOverviewEntry, index: Int) -> some View {
        let label = overviewLabel(for: entry.age)
        let (dmsString, sign, valid) = PositionInDegreesConversion.DoubleToDmsSign(entry.longitude)
        return HStack(spacing: 12) {
            Text(label)
                .frame(width: labelWidth, alignment: .leading)
            HStack(spacing: 4) {
                if valid, let sign {
                    Text(dmsString)
                    Text(GlyphSelector.getGlyphForSign(sign))
                        .font(.custom("EnigmaAstrology2", size: 14))
                } else {
                    Text(String(format: "%.4f°", entry.longitude))
                }
            }
            .frame(width: positionWidth, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Matches tab

    private var matchesTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            if let position = agePointModel.positionResult {
                GroupBox {
                    VStack(spacing: 0) {
                        positionsHeader
                        Divider()
                        positionRow(position, index: 0)
                    }
                }
                .frame(maxWidth: 500, alignment: .leading)
            }
            aspectsSection
            Divider()
            ProgressiveMidpointsTab(
                progressivePositions:    agePointModel.progressivePositions,
                radixSectionTitle:       t(AgePointKeys.midpointsRadixHeader),
                progressiveSectionTitle: t(AgePointKeys.midpointsAgePointHeader),
                noMatchesText:           t(AgePointKeys.midpointsNoMatches),
                showMatchingFactor:      false,
                showProgressiveSection:  false
            )
        }
    }

    // MARK: - Aspects section

    @ViewBuilder
    private var aspectsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t(AgePointKeys.aspectsHeader))
                .font(.title3.weight(.semibold))

            let rows = aspectRows
            if rows.isEmpty {
                Text(t(AgePointKeys.noAspects))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                GroupBox {
                    VStack(spacing: 0) {
                        aspectsHeader
                        Divider()
                        ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                            aspectRow(row, index: index)
                        }
                    }
                }
                .frame(maxWidth: CGFloat(aspectW + radixW + orbW + exactW) + 80, alignment: .leading)
            }
        }
    }

    private var aspectsHeader: some View {
        HStack(spacing: 8) {
            Spacer().frame(width: aspectW)
            Spacer().frame(width: radixW)
            Text(t(AgePointKeys.colOrb))
                .frame(width: orbW, alignment: .trailing)
            Text(t(AgePointKeys.colExactness))
                .frame(width: exactW, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func aspectRow(_ row: AspectRow, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(row.aspectGlyph)
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: aspectW, alignment: .center)
            Text(row.radixGlyph)
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: radixW, alignment: .center)
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

    // MARK: - Wheel tab

    @ViewBuilder
    private var wheelTab: some View {
        if let plotData = radixPlotData {
            VStack(alignment: .leading, spacing: 8) {
                wheelControls
                AgePointWheelCanvas(
                    radixData:       plotData,
                    apMundaneAngle:  apMundaneAngle,
                    apLongitude:     agePointModel.positionResult,
                    overviewItems:   overviewWheelItems,
                    theme:           blackWhite ? .blackWhite : .color,
                    showAspects:     !hideAspects
                )
            }
        }
    }

    private var wheelControls: some View {
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

    // MARK: - Helpers

    private var apMundaneAngle: Double? {
        guard let pos = agePointModel.positionResult,
              agePointModel.activeMode == .positionsForEvent,
              let chart = chartSession.selectedChart else { return nil }
        return WheelGeometry.mundaneAngle(
            longitude:          pos,
            ascendantLongitude: chart.HousePositions.ascendant.longitude
        )
    }

    private var radixPlotData: WheelPlotData? {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return nil }
        let cusps = chartSession.houseCuspLongitudes(for: agePointModel.selectedHouseSystem)
        return WheelPlotDataBuilder.build(from: chart, config: config, cuspLongitudes: cusps)
    }

    private var overviewWheelItems: [AgePointWheelMark]? {
        guard agePointModel.activeMode == .overview,
              let chart = chartSession.selectedChart,
              !agePointModel.overviewEntries.isEmpty else { return nil }
        let asc = chart.HousePositions.ascendant.longitude
        return agePointModel.overviewEntries.map { entry in
            let angle = WheelGeometry.mundaneAngle(longitude: entry.longitude, ascendantLongitude: asc)
            return AgePointWheelMark(label: overviewLabel(for: entry.age), mundaneAngle: angle)
        }
    }

    private func overviewLabel(for age: Int) -> String {
        if age <= 48 {
            return "\(age)/\(age + 72)"
        } else {
            return String(format: t(AgePointKeys.overviewAgeFmt), age)
        }
    }

    // MARK: - Computed aspect rows

    private var aspectRows: [AspectRow] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first,
              !agePointModel.progressivePositions.isEmpty else { return [] }

        let found = TransitAspectsOrchestrator.calculate(
            transitPositions: agePointModel.progressivePositions,
            radixChart:       chart,
            factorConfig:     config.factorConfig,
            aspectConfig:     config.aspectConfig,
            baseOrb:          config.progressionsConfig.transits.orb
        )

        return found.map { aspect in
            let exactness = aspect.maxOrb > 0
                ? max(0, min(100, Int((1.0 - aspect.orb / aspect.maxOrb) * 100)))
                : 100
            let totalMin = Int(abs(aspect.orb) * 60)
            let orbText  = "\(totalMin / 60)°\(String(format: "%02d", totalMin % 60))'"
            return AspectRow(
                aspectGlyph: GlyphSelector.getGlyphForAspect(aspect.aspect),
                radixGlyph:  GlyphSelector.getGlyphForFactor(aspect.factor2),
                orbText:     orbText,
                exactness:   exactness
            )
        }
    }
}

// MARK: - Row model

private struct AspectRow {
    let aspectGlyph: String
    let radixGlyph:  String
    let orbText:     String
    let exactness:   Int
}
