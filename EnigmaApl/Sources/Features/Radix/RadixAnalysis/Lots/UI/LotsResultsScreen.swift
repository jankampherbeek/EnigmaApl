// LotsResultsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct LotsResultsScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var lotsModel: LotsModel

    private let nameW: CGFloat = 200
    private let posW: CGFloat = 160

    var body: some View {
        Group {
            if let chart = chartSession.selectedChart {
                let results = LotsOrchestrator.calculate(chart: chart, useSect: lotsModel.useSect)
                ScrollView {
                    VStack(spacing: 0) {
                        headerRow
                        Divider()
                        ForEach(Array(results.enumerated()), id: \.offset) { index, lot in
                            lotRow(lot, index: index)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                ContentUnavailableView(
                    t(LotsKeys.navTitle),
                    systemImage: "circle.hexagongrid",
                    description: Text(t(LotsKeys.noChart))
                )
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 8) {
            Text(t(LotsKeys.colName))
                .frame(width: nameW, alignment: .leading)
            Text(t(LotsKeys.colPosition))
                .frame(width: posW, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    private func lotRow(_ lot: LotResult, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(t(nameKey(for: lot.type)))
                .frame(width: nameW, alignment: .leading)
            positionText(lot.longitude)
                .frame(width: posW, alignment: .trailing)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 5)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    @ViewBuilder
    private func positionText(_ value: Double) -> some View {
        let (dmsString, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(value)
        if success, let sign {
            HStack(spacing: 4) {
                Text(dmsString)
                Text(GlyphSelector.getGlyphForSign(sign))
                    .font(.custom("EnigmaAstrology3", size: 16))
            }
        } else {
            Text("—")
        }
    }

    private func nameKey(for type: LotType) -> String {
        switch type {
        case .fortune:   return LotsKeys.lotFortune
        case .spirit:    return LotsKeys.lotSpirit
        case .eros:      return LotsKeys.lotEros
        case .victory:   return LotsKeys.lotVictory
        case .necessity: return LotsKeys.lotNecessity
        case .courage:   return LotsKeys.lotCourage
        case .nemesis:   return LotsKeys.lotNemesis
        }
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Lots", bundle: .main, comment: "")
    }
}
