// AnalysisScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
import SwiftUI

// Grouped overview of all analyses, shown in the content column. Grouping is defined in AnalysisGroup.

struct AnalysisScreen: View {
    @EnvironmentObject private var app: AppState
    @State private var showHelp = false

    var body: some View {
        List {
            ForEach(AnalysisGroup.allCases) { group in
                Section(t(group.rbKey)) {
                    ForEach(group.items) { item in
                        Button { app.openAnalysis(item) } label: {
                            HStack {
                                Text(t(item.analysisRbKey))
                                Spacer()
                                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle(t(RadixAnalysisKeys.title))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(RadixAnalysisKeys.help))
        }
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "RadixAnalysis", bundle: .main, comment: "")
    }
}
