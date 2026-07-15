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

                content
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var content: some View {
        let charts = synastryModel.selectedCharts
        switch resultType {
        case .compare where charts.count == 2:
            SynastryCompareWheelView(first: charts[0], second: charts[1])
        case .composite where charts.count == 2:
            SynastryCompositeView(first: charts[0], second: charts[1])
        case .combine where charts.count == 2:
            SynastryDavisonView(first: charts[0], second: charts[1])
        case .aspectComparison where charts.count == 2:
            SynastryAspectComparisonView(first: charts[0], second: charts[1])
        case .midpointComparison where charts.count == 2:
            SynastryMidpointComparisonView(first: charts[0], second: charts[1])
        case .declinationComparison where charts.count == 2:
            SynastryDeclinationComparisonView(first: charts[0], second: charts[1])
        default:
            genericChartsList
        }
    }

    private var genericChartsList: some View {
        VStack(alignment: .leading, spacing: 8) {
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
}
