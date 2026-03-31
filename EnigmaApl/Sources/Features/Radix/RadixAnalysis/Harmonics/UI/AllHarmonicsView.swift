// AllHarmonicsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct AllHarmonicsView: View {
    let harmonicNumber: Double
    @Binding var harmonicText: String

    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private let glyphW: CGFloat = 28
    private let posW:   CGFloat = 140

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "RadixAnalysis", bundle: .main, comment: "")
    }

    private var harmonicPositions: [HarmonicPosition] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return HarmonicsOrchestrator.harmonicPositions(
            chart: chart,
            factorConfig: config.factorConfig,
            harmonic: harmonicNumber
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(RadixAnalysisKeys.allHarmonicsTitle))
                    .font(.title2.weight(.semibold))

                harmonicInput

                if harmonicPositions.isEmpty {
                    Text(t(RadixAnalysisKeys.allHarmonicsNoData))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    positionsTable
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    // MARK: - Input field

    @ViewBuilder
    private var harmonicInput: some View {
        HStack(spacing: 8) {
            Text(t(RadixAnalysisKeys.inputLabel))
                .font(.callout)
            TextField("", text: $harmonicText)
                .textFieldStyle(.roundedBorder)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .frame(width: 80)
        }
    }

    // MARK: - Table

    @ViewBuilder
    private var positionsTable: some View {
        GroupBox {
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 4) {
                    Text(t(RadixAnalysisKeys.colFactor))
                        .frame(width: glyphW, alignment: .center)
                    Text(t(RadixAnalysisKeys.colPosition))
                        .frame(width: posW, alignment: .trailing)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)

                Divider()

                ForEach(Array(harmonicPositions.enumerated()), id: \.offset) { index, item in
                    positionRow(item, index: index)
                }
            }
        }
    }

    @ViewBuilder
    private func positionRow(_ item: HarmonicPosition, index: Int) -> some View {
        HStack(spacing: 4) {
            Text(GlyphSelector.getGlyphForFactor(item.factor))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(item.factor.localizedName)

            positionText(item.longitude)
                .frame(width: posW, alignment: .trailing)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
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
}
