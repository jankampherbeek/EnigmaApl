// EnneagramFigureScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct EnneagramFigureScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var enneagramModel: EnneagramModel

    @State private var showHelp = false

    private var results: [EnneagramTypeResult] {
        guard let chart = chartSession.selectedChart else { return [] }
        return EnneagramOrchestrator.strengths(chart: chart, options: enneagramModel.options)
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Enneagram", bundle: .main, comment: "")
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
                EnneagramDiagramView(results: results)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(EnneagramKeys.diagramHelp))
        }
    }
}
