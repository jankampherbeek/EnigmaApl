// AltZodiacStartResultsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "AltZodiacStart", bundle: .main, comment: "")
}

private enum AltZodiacStartTab { case positions, wheel }

private struct AltZodiacStartRow: Identifiable {
    let id             = UUID()
    let factor:         Factors
    let factorGlyph:    String
    let isStartFactor:  Bool
    let originalDms:    String
    let originalSign:   Signs?
    let shiftedDms:      String
    let shiftedSign:     Signs?
    let mundaneAngle:   Double
}

struct AltZodiacStartResultsView: View {
    @EnvironmentObject private var model:        AltZodiacStartModel
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    /// Drawing type for the wheel: the configured type, limited to the types this wheel supports.
    private var drawingType: DrawingType {
        WheelAngleMapper.specialisedType(activeConfigs.first?.displayConfig.drawingType ?? .signBased)
    }

    @State private var selectedTab: AltZodiacStartTab = .positions
    @State private var blackWhite  = false
    @State private var hideAspects = false
    @State private var showExport  = false
    @State private var showHelp    = false

    // Column widths
    private let glyphW: CGFloat = 36
    private let posW:   CGFloat = 110

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(AltZodiacStartKeys.resultsTitle))
                    .font(.title2.weight(.semibold))

                if chartSession.selectedChart == nil {
                    ContentUnavailableView(
                        t(AltZodiacStartKeys.noChart),
                        systemImage: "circle.dashed"
                    )
                } else {
                    startFactorBanner

                    Picker("", selection: $selectedTab) {
                        Text(t(AltZodiacStartKeys.tabPositions)).tag(AltZodiacStartTab.positions)
                        Text(t(AltZodiacStartKeys.tabWheel)).tag(AltZodiacStartTab.wheel)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 300)

                    tabContent
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .factsheetToolbarButton(baseName: "altzodiacstart")
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(AltZodiacStartKeys.resultsHelp))
        }
        .sheet(isPresented: $showExport) {
            if let plotData = radixPlotData, let startLongitude {
                WheelExportSheet(
                    wheelView: AltZodiacStartWheelCanvas(
                        radixData:            plotData,
                        zodiacStartLongitude: startLongitude,
                        theme:                blackWhite ? .blackWhite : .color,
                        showAspects:          !hideAspects,
                        drawingType:          drawingType
                    )
                )
            }
        }
    }

    // MARK: - Start-factor banner

    private var startFactorBanner: some View {
        HStack(spacing: 6) {
            Text(t(AltZodiacStartKeys.startFactorLabel))
                .foregroundStyle(.secondary)
            Text(GlyphSelector.getGlyphForFactor(model.startFactor))
                .font(.custom("EnigmaAstrology3", size: 18))
            Text(NSLocalizedString(model.startFactor.localizedName, comment: ""))
        }
        .font(.callout)
    }

    // MARK: - Tab routing

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .positions: positionsTab
        case .wheel:     wheelTab
        }
    }

    // MARK: - Positions tab

    private var positionsTab: some View {
        let rows = computedRows
        return Group {
            if rows.isEmpty {
                Text(t(AltZodiacStartKeys.noResults))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                GroupBox {
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(spacing: 0) {
                            positionsHeader
                            Divider()
                            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                                positionRow(row, index: index)
                            }
                        }
                    }
                }
            }
        }
    }

    private var positionsHeader: some View {
        HStack(spacing: 8) {
            Spacer().frame(width: glyphW)
            Text(t(AltZodiacStartKeys.colOriginal))
                .frame(width: posW, alignment: .leading)
            Text(t(AltZodiacStartKeys.colShifted))
                .frame(width: posW, alignment: .leading)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func positionRow(_ row: AltZodiacStartRow, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(row.factorGlyph)
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
            HStack(spacing: 2) {
                Text(row.originalDms)
                if let sign = row.originalSign {
                    Text(GlyphSelector.getGlyphForSign(sign))
                        .font(.custom("EnigmaAstrology3", size: 14))
                }
            }
            .frame(width: posW, alignment: .leading)
            .lineLimit(1)
            HStack(spacing: 2) {
                Text(row.shiftedDms)
                if let sign = row.shiftedSign {
                    Text(GlyphSelector.getGlyphForSign(sign))
                        .font(.custom("EnigmaAstrology3", size: 14))
                }
            }
            .frame(width: posW, alignment: .leading)
            .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(rowBackground(index: index, isStartFactor: row.isStartFactor))
    }

    private func rowBackground(index: Int, isStartFactor: Bool) -> Color {
        if isStartFactor { return Color.accentColor.opacity(0.15) }
        return index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06)
    }

    // MARK: - Wheel tab

    @ViewBuilder
    private var wheelTab: some View {
        if let plotData = radixPlotData, let startLongitude {
            VStack(alignment: .leading, spacing: 8) {
                wheelControls
                AltZodiacStartWheelCanvas(
                    radixData:            plotData,
                    zodiacStartLongitude: startLongitude,
                    theme:                blackWhite ? .blackWhite : .color,
                    showAspects:          !hideAspects,
                    drawingType:          drawingType
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

    // MARK: - Computed data

    private var startLongitude: Double? {
        chartSession.selectedChart?.Coordinates[model.startFactor]?.ecliptical.first?.mainPos
    }

    private var computedRows: [AltZodiacStartRow] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first,
              let startLongitude else { return [] }

        let usedFactors = Set(config.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor })
        let asc = chart.HousePositions.ascendant.longitude

        return chart.Coordinates.compactMap { factor, position -> AltZodiacStartRow? in
            guard usedFactors.contains(factor),
                  let longitude = position.ecliptical.first?.mainPos else { return nil }

            let shifted = AltZodiacStartOrchestrator.shiftedLongitude(longitude, zodiacStart: startLongitude)
            let (originalDms, originalSign, originalValid) = PositionInDegreesConversion.DoubleToDmsSign(longitude)
            let (shiftedDms, shiftedSign, shiftedValid)     = PositionInDegreesConversion.DoubleToDmsSign(shifted)

            return AltZodiacStartRow(
                factor:        factor,
                factorGlyph:   GlyphSelector.getGlyphForFactor(factor),
                isStartFactor: factor == model.startFactor,
                originalDms:   originalValid ? originalDms : String(format: "%.4f°", longitude),
                originalSign:  originalValid ? originalSign : nil,
                shiftedDms:    shiftedValid ? shiftedDms : String(format: "%.4f°", shifted),
                shiftedSign:   shiftedValid ? shiftedSign : nil,
                mundaneAngle:  WheelGeometry.mundaneAngle(longitude: longitude, ascendantLongitude: asc)
            )
        }
        .sorted { $0.mundaneAngle < $1.mundaneAngle }
    }

    private var radixPlotData: WheelPlotData? {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return nil }
        return ChartWheelPlotDataBuilder.build(from: chart, config: config, drawingType: drawingType)
    }
}
