// ProgressiveMidpointsTab.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

/// Shared midpoints tab for Transit, Secondary, and Symbolic results views.
/// Shows two sections: radix midpoints occupied by progressive factors, and
/// progressive midpoints occupied by radix factors.
struct ProgressiveMidpointsTab: View {
    let progressivePositions: [Factors: ProgressivePosition]
    let radixSectionTitle: String
    let progressiveSectionTitle: String
    let noMatchesText: String

    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var dialType: MidpointDialType = .dial360

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Midpoints", bundle: .main, comment: "")
    }

    private let glyphW: CGFloat = 28
    private let posW:   CGFloat = 140
    private let orbW:   CGFloat = 70
    private let exactW: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("", selection: $dialType) {
                Text(t(MidpointsKeys.dial360)).tag(MidpointDialType.dial360)
                Text(t(MidpointsKeys.dial90)).tag(MidpointDialType.dial90)
                Text(t(MidpointsKeys.dial45)).tag(MidpointDialType.dial45)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 300)

            midpointsSection(title: radixSectionTitle, matches: radixMatches)

            Divider()

            midpointsSection(title: progressiveSectionTitle, matches: progressiveMatches)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private func midpointsSection(title: String, matches: [MidpointMatch]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.weight(.semibold))

            if matches.isEmpty {
                Text(noMatchesText)
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                MidpointTreeCanvas(matches: matches)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                Divider()
                matchesTable(matches: matches)
            }
        }
    }

    // MARK: - Table

    @ViewBuilder
    private func matchesTable(matches: [MidpointMatch]) -> some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Text(t(MidpointsKeys.colFactor1))
                            .frame(width: glyphW, alignment: .center)
                        Text(t(MidpointsKeys.colFactor2))
                            .frame(width: glyphW, alignment: .center)
                        Text(t(MidpointsKeys.colMidpoint))
                            .frame(width: posW, alignment: .trailing)
                        Text(t(MidpointsKeys.colPlanet))
                            .frame(width: glyphW, alignment: .center)
                        Text(t(MidpointsKeys.colOrb))
                            .frame(width: orbW, alignment: .trailing)
                        Text(t(MidpointsKeys.colExactness))
                            .frame(width: exactW, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)

                    Divider()

                    ForEach(Array(matches.enumerated()), id: \.offset) { index, match in
                        matchRow(match, index: index)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func matchRow(_ match: MidpointMatch, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(GlyphSelector.getGlyphForFactor(match.factor1))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(match.factor1.localizedName)

            Text(GlyphSelector.getGlyphForFactor(match.factor2))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(match.factor2.localizedName)

            positionText(match.midpointPosition)
                .frame(width: posW, alignment: .trailing)

            Text(GlyphSelector.getGlyphForFactor(match.matchingFactor))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(match.matchingFactor.localizedName)

            Text(orbText(match.actualOrb))
                .frame(width: orbW, alignment: .trailing)
                .foregroundStyle(.secondary)

            Text("\(exactness(match))%")
                .frame(width: exactW, alignment: .trailing)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Computed matches

    private var radixMatches: [MidpointMatch] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return MidpointsOrchestrator.radixMidpointsOccupiedByProgressive(
            radixChart: chart,
            progressivePositions: progressivePositions,
            factorConfig: config.factorConfig,
            orbConfig: config.orbConfig,
            dialType: dialType
        )
    }

    private var progressiveMatches: [MidpointMatch] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return MidpointsOrchestrator.progressiveMidpointsOccupiedByRadix(
            radixChart: chart,
            progressivePositions: progressivePositions,
            factorConfig: config.factorConfig,
            orbConfig: config.orbConfig,
            dialType: dialType
        )
    }

    // MARK: - Helpers

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

    private func orbText(_ orb: Double) -> String {
        let totalMin = Int(abs(orb) * 60)
        return "\(totalMin / 60)°\(String(format: "%02d", totalMin % 60))'"
    }

    private func exactness(_ match: MidpointMatch) -> Int {
        guard match.maxOrb > 0 else { return 100 }
        return max(0, min(100, Int((1.0 - match.actualOrb / match.maxOrb) * 100)))
    }
}
