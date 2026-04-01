// HarmonicsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct HarmonicsScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var activeTab: HarmonicsTab = .all
    @State private var harmonicNumber: Double = 2.0
    @State private var harmonicText: String = "2"

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "RadixAnalysis", bundle: .main, comment: "")
    }

    var body: some View {
        Group {
            if chartSession.selectedChart == nil {
                ContentUnavailableView(
                    t(RadixAnalysisKeys.btnHarmonics),
                    systemImage: "waveform",
                    description: Text(t(RadixAnalysisKeys.noChart))
                )
            } else {
                tabContent
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Picker("", selection: $activeTab) {
                    Text(t(RadixAnalysisKeys.btnAllHarmonics)).tag(HarmonicsTab.all)
                    Text(t(RadixAnalysisKeys.btnMatches)).tag(HarmonicsTab.matches)
                    Text(t(RadixAnalysisKeys.btnDrawing)).tag(HarmonicsTab.drawing)
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }
        }
        .onChange(of: harmonicText) { _, newText in
            if let value = Double(newText), value > 0 {
                harmonicNumber = value
            }
        }
    }

    // MARK: - Tab content

    @ViewBuilder
    private var tabContent: some View {
        switch activeTab {
        case .all:
            AllHarmonicsView(harmonicNumber: harmonicNumber, harmonicText: $harmonicText)
        case .matches:
            HarmonicMatchesView(harmonicNumber: harmonicNumber, harmonicText: $harmonicText)
        case .drawing:
            HarmonicDrawingView(harmonicNumber: harmonicNumber, harmonicText: $harmonicText)
        }
    }
}

// MARK: - Supporting enum

private enum HarmonicsTab {
    case all, matches, drawing
}
