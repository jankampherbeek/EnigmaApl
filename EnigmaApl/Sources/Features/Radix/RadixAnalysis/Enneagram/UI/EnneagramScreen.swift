// EnneagramScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct EnneagramScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var enneagramModel: EnneagramModel

    @State private var activeTab: EnneagramTab = .overview

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Enneagram", bundle: .main, comment: "")
    }

    private var typeNames: [Int: String] {
        Dictionary(uniqueKeysWithValues: (1...9).map { n in
            let key: String
            switch n {
            case 1: key = EnneagramKeys.type1
            case 2: key = EnneagramKeys.type2
            case 3: key = EnneagramKeys.type3
            case 4: key = EnneagramKeys.type4
            case 5: key = EnneagramKeys.type5
            case 6: key = EnneagramKeys.type6
            case 7: key = EnneagramKeys.type7
            case 8: key = EnneagramKeys.type8
            default: key = EnneagramKeys.type9
            }
            return (n, t(key))
        })
    }

    private var results: [EnneagramTypeResult] {
        guard let chart = chartSession.selectedChart else { return [] }
        return EnneagramOrchestrator.strengths(chart: chart, options: enneagramModel.options)
    }

    private var detailLines: [EnneagramDetailLine] {
        guard let chart = chartSession.selectedChart else { return [] }
        return EnneagramOrchestrator.details(chart: chart, options: enneagramModel.options)
    }

    var body: some View {
        Group {
            if chartSession.selectedChart == nil {
                ContentUnavailableView(
                    t(EnneagramKeys.title),
                    systemImage: "circle.grid.3x3",
                    description: Text(t(EnneagramKeys.noChart))
                )
            } else {
                tabContent
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Picker("", selection: $activeTab) {
                    Text(t(EnneagramKeys.tabOverview)).tag(EnneagramTab.overview)
                    Text(t(EnneagramKeys.tabDetails)).tag(EnneagramTab.details)
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }
            ToolbarItem(placement: .automatic) {
                optionsMenu
            }
        }
    }

    // MARK: - Options menu

    private var optionsMenu: some View {
        Menu {
            Toggle(t(EnneagramKeys.optUseHouses), isOn: $enneagramModel.options.useHouses)
            Toggle(t(EnneagramKeys.optDoublePluto), isOn: $enneagramModel.options.doublePluto)
            Toggle(t(EnneagramKeys.optUpdated), isOn: $enneagramModel.options.useUpdatedVersion)
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
        .accessibilityLabel("Options")
    }

    // MARK: - Tab content

    @ViewBuilder
    private var tabContent: some View {
        switch activeTab {
        case .overview:
            EnneagramOverviewView(results: results, typeNames: typeNames)
        case .details:
            EnneagramDetailsView(detailLines: detailLines)
        }
    }
}

// MARK: - Tab enum

private enum EnneagramTab {
    case overview, details
}
