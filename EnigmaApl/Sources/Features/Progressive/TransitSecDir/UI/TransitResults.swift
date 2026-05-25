// TransitResults.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Transit", bundle: .main, comment: "")
}

// MARK: - Tab enum

private enum TransitResultTab: String, CaseIterable {
    case positions, matches, dualWheel
}

// MARK: - Main view

struct TransitResults: View {
    @EnvironmentObject private var transitModel: TransitModel
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var selectedTab:  TransitResultTab = .positions
    @State private var blackWhite:   Bool = false
    @State private var hideAspects:  Bool = false
    @State private var showExport:   Bool = false

    // Column widths – positions tab
    private let glyphWidth: CGFloat       = 32
    private let longitudeWidth: CGFloat   = 120
    private let declinationWidth: CGFloat = 100

    // Column widths – matches tab
    private let glyphW:  CGFloat = 36
    private let nameW:   CGFloat = 120
    private let orbW:    CGFloat = 70
    private let exactW:  CGFloat = 100

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(TransitKeys.resultsTitle))
                    .font(.title2.weight(.semibold))

                if transitModel.results.isEmpty {
                    Text(t(TransitKeys.noResults))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    Picker("", selection: $selectedTab) {
                        Text(t(TransitKeys.tabPositions)).tag(TransitResultTab.positions)
                        Text(t(TransitKeys.tabMatches)).tag(TransitResultTab.matches)
                        Text(t(TransitKeys.tabDualWheel)).tag(TransitResultTab.dualWheel)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 500)

                    tabContent
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(TransitKeys.resultsTitle))
        .sheet(isPresented: $showExport) {
            if let chart = chartSession.selectedChart,
               let config = activeConfigs.first {
                WheelExportSheet(
                    wheelView: DualWheelCanvas(
                        radixData:    WheelPlotDataBuilder.build(from: chart, config: config),
                        transitItems: resolvedTransitItems(ascLong: chart.HousePositions.ascendant.longitude),
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
                .frame(maxWidth: 500, alignment: .leading)
        case .matches:
            matchesTable
                .frame(maxWidth: 700, alignment: .leading)
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
                    positionRow(item.factor, position: item.position, index: index)
                }
            }
        }
    }

    private var positionsHeader: some View {
        HStack(spacing: 12) {
            Spacer().frame(width: glyphWidth)
            Text(t(TransitKeys.columnFactor))
                .frame(width: 80, alignment: .leading)
            Text(t(TransitKeys.columnLongitude))
                .frame(width: longitudeWidth, alignment: .leading)
            Text(t(TransitKeys.columnDeclination))
                .frame(width: declinationWidth, alignment: .leading)
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
                .frame(width: glyphWidth, alignment: .center)

            Text(LocalizedStringKey(factor.localizedName))
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)

            HStack(spacing: 4) {
                if valid, let sign {
                    Text(dmsString)
                    Text(GlyphSelector.getGlyphForSign(sign))
                        .font(.custom("EnigmaAstrology2", size: 14))
                } else {
                    Text(String(format: "%.4f°", position.longitude))
                }
            }
            .frame(width: longitudeWidth, alignment: .leading)

            Text(PositionInDegreesConversion.DoubleToDms(position.declination))
                .frame(width: declinationWidth, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Matches tab

    @ViewBuilder
    private var matchesTable: some View {
        if foundMatches.isEmpty {
            Text(t(TransitKeys.matchesNoMatches))
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
            Text(t(TransitKeys.matchesColTransit))
                .frame(width: nameW, alignment: .leading)
            Spacer().frame(width: glyphW)
            Text(t(TransitKeys.matchesColAspect))
                .frame(width: nameW, alignment: .leading)
            Spacer().frame(width: glyphW)
            Text(t(TransitKeys.matchesColRadix))
                .frame(width: nameW, alignment: .leading)
            Text(t(TransitKeys.matchesColOrb))
                .frame(width: orbW, alignment: .trailing)
            Text(t(TransitKeys.matchesColExactness))
                .frame(width: exactW, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func matchRow(_ row: AspectMatchRow, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(row.transitGlyph)
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .leading)
            Text(row.transitName)
                .frame(width: nameW, alignment: .leading)
                .lineLimit(1)
            Text(row.aspectGlyph)
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .leading)
            Text(row.aspectName)
                .frame(width: nameW, alignment: .leading)
                .lineLimit(1)
            Text(row.radixGlyph)
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .leading)
            Text(row.radixName)
                .frame(width: nameW, alignment: .leading)
                .lineLimit(1)
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
                transitItems: resolvedTransitItems(ascLong: chart.HousePositions.ascendant.longitude),
                theme:        blackWhite ? .blackWhite : .color,
                showAspects:  !hideAspects
            )
        }
    }

    // MARK: - Helpers

    private struct FactorResult {
        let factor: Factors
        let position: ProgressivePosition
    }

    private var sortedResults: [FactorResult] {
        transitModel.results
            .map { FactorResult(factor: $0.key, position: $0.value) }
            .sorted { $0.factor.rawValue < $1.factor.rawValue }
    }

    private var foundMatches: [FoundAspect] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return TransitAspectsOrchestrator.calculate(
            transitPositions: transitModel.results,
            radixChart:       chart,
            factorConfig:     config.factorConfig,
            aspectConfig:     config.aspectConfig,
            orbConfig:        config.orbConfig
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
                transitGlyph: GlyphSelector.getGlyphForFactor(found.factor1),
                transitName:  NSLocalizedString(found.factor1.localizedName, comment: ""),
                aspectGlyph:  GlyphSelector.getGlyphForAspect(found.aspect),
                aspectName:   NSLocalizedString(found.aspect.rbKey, comment: ""),
                radixGlyph:   GlyphSelector.getGlyphForFactor(found.factor2),
                radixName:    NSLocalizedString(found.factor2.localizedName, comment: ""),
                orbText:      orbText,
                exactness:    exactness
            )
        }
    }

    private func resolvedTransitItems(ascLong: Double) -> [WheelPlotItem] {
        let items: [WheelPlotItem] = transitModel.results.map { factor, position in
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
    let transitGlyph: String
    let transitName:  String
    let aspectGlyph:  String
    let aspectName:   String
    let radixGlyph:   String
    let radixName:    String
    let orbText:      String
    let exactness:    Int
}
