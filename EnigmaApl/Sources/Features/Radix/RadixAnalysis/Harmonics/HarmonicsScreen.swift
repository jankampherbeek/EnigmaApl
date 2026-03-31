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
        VStack(alignment: .leading, spacing: 0) {
            if chartSession.selectedChart == nil {
                ContentUnavailableView(
                    t(RadixAnalysisKeys.btnHarmonics),
                    systemImage: "waveform",
                    description: Text(t(RadixAnalysisKeys.noChart))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }

            Divider()

            bottomBar
                .padding(.horizontal)
                .padding(.vertical, 10)
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

    // MARK: - Bottom bar

    @ViewBuilder
    private var bottomBar: some View {
        HStack(spacing: 12) {
            tabButton(.all,     label: t(RadixAnalysisKeys.btnAllHarmonics))
            tabButton(.matches, label: t(RadixAnalysisKeys.btnMatches))
            tabButton(.drawing, label: t(RadixAnalysisKeys.btnDrawing))
        }
    }

    @ViewBuilder
    private func tabButton(_ tab: HarmonicsTab, label: String) -> some View {
        Button(label) { activeTab = tab }
            .buttonStyle(.bordered)
            .tint(activeTab == tab ? .accentColor : nil)
    }
}

// MARK: - Supporting enum

private enum HarmonicsTab {
    case all, matches, drawing
}
