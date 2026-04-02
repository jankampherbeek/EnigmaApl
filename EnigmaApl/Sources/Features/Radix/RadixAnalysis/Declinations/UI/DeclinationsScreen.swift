// DeclinationsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct DeclinationsScreen: View {
    @EnvironmentObject private var chartSession: ChartSession

    @State private var activeTab: DeclinationsTab = .all

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Declinations", bundle: .main, comment: "")
    }

    var body: some View {
        if chartSession.selectedChart == nil {
            ContentUnavailableView(
                t(DeclinationsKeys.title),
                systemImage: "arrow.up.and.down",
                description: Text(t(DeclinationsKeys.noChart))
            )
        } else {
            tabContent
        }
    }

    // MARK: - Tab content

    @ViewBuilder
    private var tabContent: some View {
        switch activeTab {
        case .all:
            AllDeclinationsView(activeTab: $activeTab)
        case .parallels:
            DeclinationParallelsView(activeTab: $activeTab)
        case .equivalents:
            DeclinationLongEquivalentsView(activeTab: $activeTab)
        case .diagram:
            DeclinationDiagramView(activeTab: $activeTab)
        case .midpoints:
            DeclinationMidpointsView(activeTab: $activeTab)
        }
    }
}

// MARK: - Supporting enum

enum DeclinationsTab {
    case all, parallels, equivalents, diagram, midpoints
}
