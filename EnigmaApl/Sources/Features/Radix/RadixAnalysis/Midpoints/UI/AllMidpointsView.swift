// AllMidpointsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct AllMidpointsView: View {
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Midpoints", bundle: .main, comment: "")
    }

    private var midpoints: [BaseMidpoint] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return MidpointsOrchestrator.baseMidpoints(
            chart: chart,
            factorConfig: config.factorConfig
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(MidpointsKeys.allMidpointsTitle))
                    .font(.title2.weight(.semibold))

                if midpoints.isEmpty {
                    Text(t(MidpointsKeys.noMidpoints))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    midpointsGrid
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    // MARK: - Grid

    @ViewBuilder
    private var midpointsGrid: some View {
        GeometryReader { geo in
            let useTwo = geo.size.width >= 600
            let half = midpoints.count / 2 + midpoints.count % 2

            if useTwo {
                HStack(alignment: .top, spacing: 16) {
                    midpointsColumn(Array(midpoints.prefix(half)))
                    midpointsColumn(Array(midpoints.suffix(from: half)))
                }
            } else {
                midpointsColumn(midpoints)
            }
        }
        // Give GeometryReader a concrete height so ScrollView can size correctly.
        .frame(minHeight: rowHeight * CGFloat((midpoints.count + 1) / 2 + 2))
    }

    private let rowHeight: CGFloat = 32
    private let glyphW:    CGFloat = 28
    private let posW:      CGFloat = 140

    @ViewBuilder
    private func midpointsColumn(_ items: [BaseMidpoint]) -> some View {
        GroupBox {
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 4) {
                    Text(t(MidpointsKeys.colFactor1))
                        .frame(width: glyphW, alignment: .center)
                    Text(t(MidpointsKeys.colFactor2))
                        .frame(width: glyphW, alignment: .center)
                    Text(t(MidpointsKeys.colPosition))
                        .frame(width: posW, alignment: .trailing)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)

                Divider()

                ForEach(Array(items.enumerated()), id: \.offset) { index, mp in
                    midpointRow(mp, index: index)
                }
            }
        }
    }

    @ViewBuilder
    private func midpointRow(_ mp: BaseMidpoint, index: Int) -> some View {
        HStack(spacing: 4) {
            Text(GlyphSelector.getGlyphForFactor(mp.factor1))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(mp.factor1.localizedName)

            Text(GlyphSelector.getGlyphForFactor(mp.factor2))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(mp.factor2.localizedName)

            positionText(mp.position)
                .frame(width: posW, alignment: .trailing)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    @ViewBuilder
    private func positionText(_ longitude: Double) -> some View {
        let (dmsString, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(longitude)
        if success, let sign {
            Text(positionAttributedString(dms: dmsString, sign: sign))
        } else {
            Text(PositionInDegreesConversion.DoubleToDms(longitude))
        }
    }

    private func positionAttributedString(dms: String, sign: Signs) -> AttributedString {
        var dmsAttr = AttributedString(dms + " ")
        dmsAttr.font = .body
        var glyphAttr = AttributedString(GlyphSelector.getGlyphForSign(sign))
        glyphAttr.font = .custom("EnigmaAstrology2", size: 18)
        return dmsAttr + glyphAttr
    }
}
