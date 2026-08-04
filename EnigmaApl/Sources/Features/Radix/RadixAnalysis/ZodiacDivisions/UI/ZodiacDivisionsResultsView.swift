// ZodiacDivisionsResultsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ZodiacDivisions", bundle: .main, comment: "")
}

private enum ZodiacDivisionsTab { case positions, wheel }

private struct ZodiacDivisionRow: Identifiable {
    let id           = UUID()
    let factorGlyph:  String
    let positionDms:  String        // e.g. "23°14'"
    let positionSign: Signs?        // sign of the longitude, for astrological-font rendering
    let signGlyph:    String        // zodiac sign division glyph
    let decanGlyph:   String
    let dodecatGlyph: String
    let boundGlyph:   String
    let mundaneAngle: Double
}

struct ZodiacDivisionsResultsView: View {
    @EnvironmentObject private var model:        ZodiacDivisionsModel
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var selectedTab:  ZodiacDivisionsTab = .positions
    @State private var blackWhite   = false
    @State private var hideAspects  = false
    @State private var showExport   = false
    @State private var showHelp     = false
    @State private var showFactsheet = false

    // Column widths
    private let glyphW: CGFloat  = 36
    private let posW:   CGFloat  = 110
    private let divW:   CGFloat  = 60

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(ZodiacDivisionsKeys.resultsTitle))
                    .font(.title2.weight(.semibold))

                if chartSession.selectedChart == nil {
                    ContentUnavailableView(
                        t(ZodiacDivisionsKeys.noChart),
                        systemImage: "circle.dashed"
                    )
                } else {
                    Picker("", selection: $selectedTab) {
                        Text(t(ZodiacDivisionsKeys.tabPositions)).tag(ZodiacDivisionsTab.positions)
                        Text(t(ZodiacDivisionsKeys.tabWheel)).tag(ZodiacDivisionsTab.wheel)
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
            FactsheetView(baseName: "zodiacal-divisions")
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(ZodiacDivisionsKeys.resultsHelp))
        }
        .sheet(isPresented: $showExport) {
            if let plotData = radixPlotData {
                WheelExportSheet(
                    wheelView: ZodiacDivisionsWheelCanvas(
                        radixData:   plotData,
                        marks:       wheelMarks,
                        theme:       blackWhite ? .blackWhite : .color,
                        showAspects: !hideAspects
                    )
                )
            }
        }
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
                Text(t(ZodiacDivisionsKeys.noResults))
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
            Text(t(ZodiacDivisionsKeys.colPosition))
                .frame(width: posW, alignment: .leading)
            Text(t(ZodiacDivisionsKeys.colSign))
                .frame(width: divW, alignment: .center)
            Text(t(ZodiacDivisionsKeys.colDecan))
                .frame(width: divW, alignment: .center)
            Text(t(ZodiacDivisionsKeys.colDodecatemoria))
                .frame(width: divW, alignment: .center)
            Text(t(ZodiacDivisionsKeys.colBound))
                .frame(width: divW, alignment: .center)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func positionRow(_ row: ZodiacDivisionRow, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(row.factorGlyph)
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: glyphW, alignment: .center)
            HStack(spacing: 2) {
                Text(row.positionDms)
                if let sign = row.positionSign {
                    Text(GlyphSelector.getGlyphForSign(sign))
                        .font(.custom("EnigmaAstrology3", size: 14))
                }
            }
            .frame(width: posW, alignment: .leading)
            .lineLimit(1)
            Text(row.signGlyph)
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: divW, alignment: .center)
            Text(row.decanGlyph)
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: divW, alignment: .center)
            Text(row.dodecatGlyph)
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: divW, alignment: .center)
            Text(row.boundGlyph)
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: divW, alignment: .center)
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
                ZodiacDivisionsWheelCanvas(
                    radixData:   plotData,
                    marks:       wheelMarks,
                    theme:       blackWhite ? .blackWhite : .color,
                    showAspects: !hideAspects
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

    private var computedRows: [ZodiacDivisionRow] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }

        let usedFactors = Set(config.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor })
        let asc = chart.HousePositions.ascendant.longitude

        return chart.Coordinates.compactMap { factor, position -> ZodiacDivisionRow? in
            guard usedFactors.contains(factor),
                  let longitude = position.ecliptical.first?.mainPos else { return nil }

            let signIdx   = ZodiacDivisionsOrchestrator.calculate(longitude: longitude, method: .signs)
            let decanIdx  = ZodiacDivisionsOrchestrator.calculate(longitude: longitude, method: model.decansMethod)
            let dodecatIdx = ZodiacDivisionsOrchestrator.calculate(longitude: longitude, method: model.dodecatsMethod)
            let boundIdx  = ZodiacDivisionsOrchestrator.calculate(longitude: longitude, method: model.boundsMethod)

            guard signIdx >= 0, decanIdx >= 0, dodecatIdx >= 0, boundIdx >= 0 else { return nil }

            let (dms, posSign, valid) = PositionInDegreesConversion.DoubleToDmsSign(longitude)

            return ZodiacDivisionRow(
                factorGlyph:   GlyphSelector.getGlyphForFactor(factor),
                positionDms:   valid ? dms : String(format: "%.4f°", longitude),
                positionSign:  valid ? posSign : nil,
                signGlyph:     model.signGlyph(for: signIdx),
                decanGlyph:    model.decanGlyph(for: decanIdx),
                dodecatGlyph:  model.dodecatGlyph(for: dodecatIdx),
                boundGlyph:    model.boundGlyph(for: boundIdx),
                mundaneAngle:  WheelGeometry.mundaneAngle(longitude: longitude, ascendantLongitude: asc)
            )
        }
        .sorted { $0.mundaneAngle < $1.mundaneAngle }
    }

    private var wheelMarks: [ZodiacDivisionMark] {
        let rows = computedRows
        let plotAngles = GlyphOverlapResolver.resolvedPlotAngles(for: rows.map { $0.mundaneAngle })
        return rows.enumerated().map { index, row in
            ZodiacDivisionMark(
                mundaneAngle: row.mundaneAngle,
                plotAngle:    plotAngles[index],
                signGlyph:    row.signGlyph,
                decanGlyph:   row.decanGlyph,
                dodecatGlyph: row.dodecatGlyph,
                boundGlyph:   row.boundGlyph
            )
        }
    }

    private var radixPlotData: WheelPlotData? {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return nil }
        return WheelPlotDataBuilder.build(from: chart, config: config)
    }
}
