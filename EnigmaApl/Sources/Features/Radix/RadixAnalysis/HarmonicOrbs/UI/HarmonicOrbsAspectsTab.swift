// HarmonicOrbsAspectsTab.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

// MARK: - Private helpers

/// Normalised key for a factor pair, order-independent.
private struct FactorPairKey: Hashable {
    let lo: Int   // lower rawValue
    let hi: Int   // higher rawValue
    init(_ a: Factors, _ b: Factors) {
        lo = min(a.rawValue, b.rawValue)
        hi = max(a.rawValue, b.rawValue)
    }
}

private struct AspectRow: Identifiable {
    let id = UUID()
    let factor1Glyph: String
    let factor1Name: String
    let aspectGlyph: String
    let aspectName: String
    let factor2Glyph: String
    let factor2Name: String
    let orbText: String
    let exactness: Int
}

// MARK: - Aspect grid

private struct HarmonicOrbsAspectGridView: View {
    let factors: [Factors]
    let aspectLookup: [FactorPairKey: (Aspects, Color)]

    private let cellSize: CGFloat = 30
    private let gridColor         = Color.secondary.opacity(0.35)

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<factors.count, id: \.self) { i in
                    HStack(spacing: 0) {
                        // Data cells for columns 0…i-1 (no diagonal)
                        ForEach(0..<i, id: \.self) { j in
                            gridCell(row: i, col: j)
                        }
                        // Column header for column i, inline at diagonal position
                        Text(GlyphSelector.getGlyphForFactor(factors[i]))
                            .font(.custom("EnigmaAstrology3", size: 16))
                            .frame(width: cellSize, height: cellSize)
                            .accessibilityHidden(true)
                    }
                }
            }
            .padding(4)
        }
    }

    @ViewBuilder
    private func gridCell(row i: Int, col j: Int) -> some View {
        let key = FactorPairKey(factors[i], factors[j])
        let entry = aspectLookup[key]

        ZStack {
            if let (aspect, color) = entry {
                Text(GlyphSelector.getGlyphForAspect(aspect))
                    .font(.custom("EnigmaAstrology3", size: 14))
                    .foregroundStyle(color)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .overlay(Rectangle().stroke(gridColor, lineWidth: 0.5))
    }
}

// MARK: - Main tab

/// The "Aspects" tab of HarmonicOrbsDrawingScreen: an aspect grid and an aspect list, built the
/// same way as AspectsScreen, but using the harmonic-orb aspects instead of the active
/// configuration's aspect/orb settings.
struct HarmonicOrbsAspectsTab: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var harmonicOrbsModel: HarmonicOrbsModel
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    // Column widths for the list table
    private let glyphW: CGFloat = 36
    private let nameW: CGFloat  = 120
    private let orbW: CGFloat   = 70
    private let exactW: CGFloat = 100

    // MARK: Computed data

    /// Factors used in calculations, in Factors-enum order, present in the chart.
    private var activeFactors: [Factors] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        let chartKeys = Set(chart.Coordinates.keys)
        return config.factorConfig.factorSettings
            .filter { $0.isUsed && chartKeys.contains($0.factor) }
            .map { $0.factor }
    }

    private var foundAspects: [FoundAspect] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return HarmonicOrbsOrchestrator.calculate(
            chart: chart,
            factorConfig: config.factorConfig,
            settings: harmonicOrbsModel.settings,
            maxOrbDegrees: harmonicOrbsModel.maxOrbDegrees
        )
    }

    /// Map from factor pair → (aspect, color) for fast grid lookup.
    private var aspectLookup: [FactorPairKey: (Aspects, Color)] {
        guard let config = activeConfigs.first else { return [:] }
        let colorMap: [Aspects: Color] = Dictionary(
            uniqueKeysWithValues: config.aspectConfig.aspectSettings.map {
                ($0.aspect, Color($0.color))
            }
        )
        var lookup: [FactorPairKey: (Aspects, Color)] = [:]
        for found in foundAspects {
            let key = FactorPairKey(found.factor1, found.factor2)
            lookup[key] = (found.aspect, colorMap[found.aspect] ?? .primary)
        }
        return lookup
    }

    private var rows: [AspectRow] {
        foundAspects.map(makeRow)
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if chartSession.selectedChart == nil {
                    ContentUnavailableView(
                        t(HarmonicOrbsKeys.navTitle),
                        systemImage: "circle.dashed",
                        description: Text(t(HarmonicOrbsKeys.drawingNoChart))
                    )
                } else {
                    if !activeFactors.isEmpty {
                        Text(t(HarmonicOrbsKeys.gridTitle))
                            .font(.headline)
                        HarmonicOrbsAspectGridView(
                            factors: activeFactors,
                            aspectLookup: aspectLookup
                        )
                        .fixedSize()
                    }

                    Text(t(HarmonicOrbsKeys.listTitle))
                        .font(.headline)
                    if rows.isEmpty {
                        Text(t(HarmonicOrbsKeys.noAspectsFound))
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    } else {
                        aspectsTable
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    // MARK: Aspects table

    @ViewBuilder
    private var aspectsTable: some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 8) {
                        Spacer().frame(width: glyphW)
                        Text(t(HarmonicOrbsKeys.colFactor1)).frame(width: nameW, alignment: .leading)
                        Spacer().frame(width: glyphW)
                        Text(t(HarmonicOrbsKeys.colAspect)).frame(width: nameW, alignment: .leading)
                        Spacer().frame(width: glyphW)
                        Text(t(HarmonicOrbsKeys.colFactor2)).frame(width: nameW, alignment: .leading)
                        Text(t(HarmonicOrbsKeys.colOrb)).frame(width: orbW, alignment: .trailing)
                        Text(t(HarmonicOrbsKeys.colExactness)).frame(width: exactW, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)

                    Divider()

                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                        HStack(spacing: 8) {
                            Text(row.factor1Glyph)
                                .font(.custom("EnigmaAstrology3", size: 18))
                                .frame(width: glyphW, alignment: .leading)
                            Text(row.factor1Name)
                                .frame(width: nameW, alignment: .leading)
                                .lineLimit(1)
                            Text(row.aspectGlyph)
                                .font(.custom("EnigmaAstrology3", size: 18))
                                .frame(width: glyphW, alignment: .leading)
                            Text(row.aspectName)
                                .frame(width: nameW, alignment: .leading)
                                .lineLimit(1)
                            Text(row.factor2Glyph)
                                .font(.custom("EnigmaAstrology3", size: 18))
                                .frame(width: glyphW, alignment: .leading)
                            Text(row.factor2Name)
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
                }
            }
        }
    }

    // MARK: Helpers

    private func makeRow(_ found: FoundAspect) -> AspectRow {
        let exactness = found.maxOrb > 0
            ? max(0, min(100, Int((1.0 - found.orb / found.maxOrb) * 100)))
            : 100
        return AspectRow(
            factor1Glyph: GlyphSelector.getGlyphForFactor(found.factor1),
            factor1Name:  NSLocalizedString(found.factor1.localizedName, comment: ""),
            aspectGlyph:  GlyphSelector.getGlyphForAspect(found.aspect),
            aspectName:   NSLocalizedString(found.aspect.rbKey, comment: ""),
            factor2Glyph: GlyphSelector.getGlyphForFactor(found.factor2),
            factor2Name:  NSLocalizedString(found.factor2.localizedName, comment: ""),
            orbText:      orbText(found.orb),
            exactness:    exactness
        )
    }

    private func orbText(_ orb: Double) -> String {
        let totalMin = Int(abs(orb) * 60)
        return "\(totalMin / 60)°\(String(format: "%02d", totalMin % 60))'"
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "HarmonicOrbs", bundle: .main, comment: "")
    }
}
