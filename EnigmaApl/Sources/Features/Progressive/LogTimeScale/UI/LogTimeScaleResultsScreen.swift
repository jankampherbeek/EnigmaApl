// LogTimeScaleResultsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "LogTimeScale", bundle: .main, comment: "")
}

private enum LogTimeScaleResultTab {
    case positions, matches, wheel
}

struct LogTimeScaleResultsScreen: View {
    @EnvironmentObject private var logTimeScaleModel: LogTimeScaleModel
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var selectedTab: LogTimeScaleResultTab = .positions
    @State private var blackWhite:  Bool = false
    @State private var hideAspects: Bool = false
    @State private var showExport:  Bool = false

    private let labelWidth: CGFloat    = 160
    private let positionWidth: CGFloat = 130

    // Column widths – aspects table
    private let aspectW: CGFloat = 36
    private let radixW:  CGFloat = 36
    private let orbW:    CGFloat = 70
    private let exactW:  CGFloat = 100

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(LogTimeScaleKeys.resultsTitle))
                    .font(.title2.weight(.semibold))

                if logTimeScaleModel.positionResult == nil {
                    Text(t(LogTimeScaleKeys.noResults))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    Picker("", selection: $selectedTab) {
                        Text(t(LogTimeScaleKeys.tabPositions)).tag(LogTimeScaleResultTab.positions)
                        Text(t(LogTimeScaleKeys.tabMatches)).tag(LogTimeScaleResultTab.matches)
                        Text(t(LogTimeScaleKeys.tabWheel)).tag(LogTimeScaleResultTab.wheel)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 500)

                    tabContent
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(LogTimeScaleKeys.resultsTitle))
        .sheet(isPresented: $showExport) {
            if let chart = chartSession.selectedChart,
               let config = activeConfigs.first {
                WheelExportSheet(
                    wheelView: LogTimeScaleWheelCanvas(
                        radixData:       WheelPlotDataBuilder.build(from: chart, config: config),
                        ltsMundaneAngle: ltsMundaneAngle,
                        ltsLongitude:    logTimeScaleModel.positionResult,
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
            positionsTab
                .frame(maxWidth: 500, alignment: .leading)
        case .matches:
            matchesTab
        case .wheel:
            wheelTab
        }
    }

    // MARK: - Positions tab

    @ViewBuilder
    private var positionsTab: some View {
        if let position = logTimeScaleModel.positionResult {
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
            Text(t(LogTimeScaleKeys.columnPosition))
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
            Text(t(LogTimeScaleKeys.positionLabel))
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

    // MARK: - Matches tab

    private var matchesTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            if let position = logTimeScaleModel.positionResult {
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
                progressivePositions:    logTimeScaleModel.progressivePositions,
                radixSectionTitle:       t(LogTimeScaleKeys.midpointsRadixHeader),
                progressiveSectionTitle: t(LogTimeScaleKeys.midpointsTimescaleHeader),
                noMatchesText:           t(LogTimeScaleKeys.midpointsNoMatches),
                showMatchingFactor:      false,
                showProgressiveSection:  false
            )
        }
    }

    // MARK: - Aspects section

    @ViewBuilder
    private var aspectsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t(LogTimeScaleKeys.aspectsHeader))
                .font(.title3.weight(.semibold))

            let rows = aspectRows
            if rows.isEmpty {
                Text(t(LogTimeScaleKeys.noAspects))
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
            Text(t(LogTimeScaleKeys.colOrb))
                .frame(width: orbW, alignment: .trailing)
            Text(t(LogTimeScaleKeys.colExactness))
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
        if let chart = chartSession.selectedChart,
           let config = activeConfigs.first {
            VStack(alignment: .leading, spacing: 8) {
                wheelControls
                LogTimeScaleWheelCanvas(
                    radixData:       WheelPlotDataBuilder.build(from: chart, config: config),
                    ltsMundaneAngle: ltsMundaneAngle,
                    ltsLongitude:    logTimeScaleModel.positionResult,
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

    /// Converts the calculated position to a mundane wheel angle.
    /// Returns nil when no position is available or mode is Overview.
    private var ltsMundaneAngle: Double? {
        guard let pos = logTimeScaleModel.positionResult,
              logTimeScaleModel.activeMode == .positionsForEvent,
              let chart = chartSession.selectedChart else { return nil }
        return WheelGeometry.mundaneAngle(
            longitude:          pos,
            ascendantLongitude: chart.HousePositions.ascendant.longitude
        )
    }

    // MARK: - Computed aspect rows

    private var aspectRows: [AspectRow] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first,
              !logTimeScaleModel.progressivePositions.isEmpty else { return [] }

        let found = TransitAspectsOrchestrator.calculate(
            transitPositions: logTimeScaleModel.progressivePositions,
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
