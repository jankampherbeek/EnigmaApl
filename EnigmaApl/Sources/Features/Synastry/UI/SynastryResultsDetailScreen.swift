// SynastryResultsDetailScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Synastry", bundle: .main, comment: "")
}

struct SynastryResultsDetailScreen: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var synastryModel: SynastryModel
    @EnvironmentObject private var synastryNav: SynastryNavigator

    private var resultType: SynastryResultType { app.nav.synastry.resultType ?? .compare }

    private var title: String {
        switch resultType {
        case .compare:            return t(SynastryKeys.resultsTitleCompare)
        case .composite:          return t(SynastryKeys.resultsTitleComposite)
        case .combine:            return t(SynastryKeys.resultsTitleCombine)
        case .aspectComparison:   return t(SynastryKeys.resultsTitleAspectComparison)
        case .midpointComparison: return t(SynastryKeys.resultsTitleMidpointComparison)
        case .declinationComparison: return t(SynastryKeys.resultsTitleDeclinationComparison)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(title)
                        .font(.title2.weight(.semibold))
                    Spacer()
                    Button(t(SynastryKeys.close)) { synastryNav.closeResult() }
                }

                if resultType == .compare, synastryModel.selectedCharts.count == 2 {
                    SynastryCompareWheelView(
                        first: synastryModel.selectedCharts[0],
                        second: synastryModel.selectedCharts[1]
                    )
                } else {
                    Text(t(SynastryKeys.resultsChartsHeader))
                        .font(.headline)

                    GroupBox {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(synastryModel.selectedCharts) { named in
                                Text(named.name)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
