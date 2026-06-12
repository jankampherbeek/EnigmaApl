// SolarResultsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "SolarReturn", bundle: .main, comment: "")
}

private enum SolarResultTab {
    case solarChart, combinedChart, positions, aspects, details
}

struct SolarResultsScreen: View {
    @EnvironmentObject private var solarReturnModel: SolarReturnModel
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var selectedTab: SolarResultTab = .solarChart
    @State private var blackWhite:  Bool = false
    @State private var hideAspects: Bool = false
    @State private var showExport:    Bool = false
    @State private var showHelp:      Bool = false
    @State private var showFactsheet: Bool = false

    // Column widths – positions table
    private let glyphW:       CGFloat = 32
    private let longitudeW:   CGFloat = 120
    private let declinationW: CGFloat = 100

    // Column widths – aspects table
    private let solarGlyphW:  CGFloat = 36
    private let aspectGlyphW: CGFloat = 36
    private let radixGlyphW:  CGFloat = 36
    private let orbW:         CGFloat = 70

    private var theme: WheelTheme { blackWhite ? .blackWhite : .color }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(SolarReturnKeys.resultsTitle))
                    .font(.title2.weight(.semibold))

                if let name = chartSession.selected?.name {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                if !solarReturnModel.hasResults {
                    Text(t(SolarReturnKeys.noResults))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    Picker("", selection: $selectedTab) {
                        Text(t(SolarReturnKeys.tabSolarChart))   .tag(SolarResultTab.solarChart)
                        Text(t(SolarReturnKeys.tabCombinedChart)).tag(SolarResultTab.combinedChart)
                        Text(t(SolarReturnKeys.tabPositions))    .tag(SolarResultTab.positions)
                        Text(t(SolarReturnKeys.tabAspects))      .tag(SolarResultTab.aspects)
                        Text(t(SolarReturnKeys.tabDetails))      .tag(SolarResultTab.details)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 750)

                    tabContent
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(SolarReturnKeys.resultsTitle))
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
            FactsheetView(baseName: "solar")
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(SolarReturnKeys.helpResults))
        }
        .sheet(isPresented: $showExport) {
            exportSheet
        }
    }

    // MARK: - Tab routing

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .solarChart:
            VStack(alignment: .leading, spacing: 8) {
                wheelControls
                solarWheelView
            }
        case .combinedChart:
            VStack(alignment: .leading, spacing: 8) {
                wheelControls
                combinedWheelView
            }
        case .positions:
            positionsTable
                .frame(maxWidth: 400, alignment: .leading)
        case .aspects:
            aspectsContent
                .frame(maxWidth: 500, alignment: .leading)
        case .details:
            detailsContent
                .frame(maxWidth: 600, alignment: .leading)
        }
    }

    // MARK: - Wheel controls

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

    // MARK: - Solar chart wheel

    @ViewBuilder
    private var solarWheelView: some View {
        if let solarChart = solarReturnModel.solarFullChart,
           let config = activeConfigs.first {
            ZodiacTypeWheelCanvas(
                plotData:    WheelPlotDataBuilder.build(from: solarChart, config: config),
                theme:       theme,
                showAspects: !hideAspects
            )
        }
    }

    // MARK: - Combined chart wheel

    @ViewBuilder
    private var combinedWheelView: some View {
        if let radixChart = chartSession.selectedChart,
           let config = activeConfigs.first {
            DualWheelCanvas(
                radixData:    WheelPlotDataBuilder.build(from: radixChart, config: config),
                transitItems: solarTransitItems(ascLong: radixChart.HousePositions.ascendant.longitude),
                theme:        theme,
                showAspects:  !hideAspects
            )
        }
    }

    // MARK: - Export sheet

    @ViewBuilder
    private var exportSheet: some View {
        if let config = activeConfigs.first {
            switch selectedTab {
            case .solarChart:
                if let solarChart = solarReturnModel.solarFullChart {
                    WheelExportSheet(
                        wheelView: ZodiacTypeWheelCanvas(
                            plotData:    WheelPlotDataBuilder.build(from: solarChart, config: config),
                            theme:       theme,
                            showAspects: !hideAspects
                        )
                    )
                }
            case .combinedChart:
                if let radixChart = chartSession.selectedChart {
                    WheelExportSheet(
                        wheelView: DualWheelCanvas(
                            radixData:    WheelPlotDataBuilder.build(from: radixChart, config: config),
                            transitItems: solarTransitItems(ascLong: radixChart.HousePositions.ascendant.longitude),
                            theme:        theme,
                            showAspects:  !hideAspects
                        )
                    )
                }
            default:
                EmptyView()
            }
        }
    }

    // MARK: - Positions tab

    private var positionsTable: some View {
        GroupBox {
            VStack(spacing: 0) {
                positionsHeader
                Divider()
                ForEach(Array(sortedPositions.enumerated()), id: \.element.factor.rawValue) { index, item in
                    positionRow(item.factor, position: item.position, index: index)
                }
            }
        }
    }

    private var positionsHeader: some View {
        HStack(spacing: 12) {
            Spacer().frame(width: glyphW)
            Text(t(SolarReturnKeys.colLongitude))
                .frame(width: longitudeW, alignment: .trailing)
            Text(t(SolarReturnKeys.colDeclination))
                .frame(width: declinationW, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func positionRow(_ factor: Factors, position: ProgressivePosition, index: Int) -> some View {
        let (dmsString, sign, valid) = PositionInDegreesConversion.DoubleToDmsSign(position.longitude)
        return HStack(spacing: 12) {
            Text(GlyphSelector.getGlyphForFactor(factor))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)

            HStack(spacing: 4) {
                if valid, let sign {
                    Text(dmsString)
                    Text(GlyphSelector.getGlyphForSign(sign))
                        .font(.custom("EnigmaAstrology2", size: 14))
                } else {
                    Text(String(format: "%.4f°", position.longitude))
                }
            }
            .frame(width: longitudeW, alignment: .trailing)

            Text(PositionInDegreesConversion.DoubleToDms(position.declination))
                .frame(width: declinationW, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Aspects tab

    @ViewBuilder
    private var aspectsContent: some View {
        let rows = aspectRows
        if rows.isEmpty {
            Text(t(SolarReturnKeys.aspectsNoAspects))
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
        }
    }

    private var aspectsHeader: some View {
        HStack(spacing: 8) {
            Spacer().frame(width: solarGlyphW)
            Spacer().frame(width: aspectGlyphW)
            Spacer().frame(width: radixGlyphW)
            Text(t(SolarReturnKeys.aspectsColOrb))
                .frame(width: orbW, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func aspectRow(_ row: AspectRow, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(row.solarGlyph)
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: solarGlyphW, alignment: .center)
            Text(row.aspectGlyph)
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: aspectGlyphW, alignment: .center)
            Text(row.radixGlyph)
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: radixGlyphW, alignment: .center)
            Text(row.orbText)
                .frame(width: orbW, alignment: .trailing)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Details tab

    private var detailsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            radixDetails
            Divider()
            solarDetails
        }
        .font(.callout)
    }

    private var radixDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t(SolarReturnKeys.detailsRadixHeader))
                .font(.headline)

            LabeledContent(t(SolarReturnKeys.detailsRadixDate), value: solarReturnModel.radixDateText)

            if let sunLong = solarReturnModel.radixSunLongitude {
                LabeledContent(t(SolarReturnKeys.detailsRadixSun),
                               value: PositionInDegreesConversion.DoubleToDms(sunLong))
            }
        }
    }

    private var solarDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t(SolarReturnKeys.detailsSolarHeader))
                .font(.headline)

            LabeledContent(t(SolarReturnKeys.detailsSolarDate), value: solarReturnModel.solarDateText)

            if let jd = solarReturnModel.solarJd {
                LabeledContent(t(SolarReturnKeys.detailsSolarJd), value: String(format: "%.6f", jd))
            }

            let geoLong = solarReturnModel.geoLong
            let geoLat  = solarReturnModel.geoLat
            let longDir = geoLong >= 0 ? t(SolarReturnKeys.east) : t(SolarReturnKeys.west)
            let latDir  = geoLat  >= 0 ? t(SolarReturnKeys.north) : t(SolarReturnKeys.south)
            let longDms = PositionInDegreesConversion.DoubleToDms(abs(geoLong))
            let latDms  = PositionInDegreesConversion.DoubleToDms(abs(geoLat))
            LabeledContent(t(SolarReturnKeys.detailsSolarLocation),
                           value: "\(longDms) \(longDir) / \(latDms) \(latDir)")

            if let sunLong = solarReturnModel.solarSunLongitude {
                LabeledContent(t(SolarReturnKeys.detailsSolarSun),
                               value: PositionInDegreesConversion.DoubleToDms(sunLong))
            }

            if solarReturnModel.useSidereal {
                Text(t(SolarReturnKeys.detailsSidereal))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Helpers

    private struct FactorPosition {
        let factor: Factors
        let position: ProgressivePosition
    }

    private var sortedPositions: [FactorPosition] {
        solarReturnModel.positions
            .map { FactorPosition(factor: $0.key, position: $0.value) }
            .sorted { $0.factor.rawValue < $1.factor.rawValue }
    }

    /// Builds the solar WheelPlotItems positioned on the radix ascendant.
    private func solarTransitItems(ascLong: Double) -> [WheelPlotItem] {
        let items = solarReturnModel.positions.map { factor, position -> WheelPlotItem in
            let mundane = WheelGeometry.mundaneAngle(longitude: position.longitude,
                                                      ascendantLongitude: ascLong)
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

    private var aspectRows: [AspectRow] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        let orb = config.progressionsConfig.solarReturn.orb
        let found = TransitAspectsOrchestrator.calculate(
            transitPositions: solarReturnModel.positions,
            radixChart:       chart,
            factorConfig:     config.factorConfig,
            aspectConfig:     config.aspectConfig,
            baseOrb:          orb
        )
        return found
            .sorted { $0.orb < $1.orb }
            .map { aspect in
                let totalMin = Int(abs(aspect.orb) * 60)
                let orbText  = "\(totalMin / 60)°\(String(format: "%02d", totalMin % 60))'"
                return AspectRow(
                    solarGlyph:  GlyphSelector.getGlyphForFactor(aspect.factor1),
                    aspectGlyph: GlyphSelector.getGlyphForAspect(aspect.aspect),
                    radixGlyph:  GlyphSelector.getGlyphForFactor(aspect.factor2),
                    orbText:     orbText
                )
            }
    }
}

// MARK: - Row model

private struct AspectRow {
    let solarGlyph:  String
    let aspectGlyph: String
    let radixGlyph:  String
    let orbText:     String
}
