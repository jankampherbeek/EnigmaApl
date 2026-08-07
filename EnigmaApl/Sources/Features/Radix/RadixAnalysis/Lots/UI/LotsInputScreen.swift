// LotsInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct LotsInputScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var lotsModel: LotsModel
    @EnvironmentObject private var radixNav: RadixNavigator
    @State private var showHelp = false
    @State private var showFactsheet = false

    private var isNightChart: Bool {
        guard let chart = chartSession.selectedChart else { return false }
        return LotsOrchestrator.isNightChart(chart)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Button {
                    radixNav.setInspector(.analysis)
                } label: {
                    Label(t(LotsKeys.back), systemImage: "chevron.left")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Text(titleText)
                    .font(.title2.weight(.semibold))

                Toggle(t(LotsKeys.useSect), isOn: $lotsModel.useSect)
                    .disabled(!isNightChart)
                    .frame(maxWidth: 300, alignment: .leading)

                if chartSession.selected == nil {
                    Text(t(LotsKeys.noChart))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 500, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showFactsheet = true } label: {
                    Image(systemName: "book.pages")
                }
                .accessibilityLabel("Factsheet")
            }
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showFactsheet) {
            FactsheetView(baseName: "lots")
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(LotsKeys.helpInput))
        }
    }

    private var titleText: String {
        let format = t(LotsKeys.titleWithName)
        return String(format: format, chartSession.selected?.name ?? "")
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Lots", bundle: .main, comment: "")
    }
}
