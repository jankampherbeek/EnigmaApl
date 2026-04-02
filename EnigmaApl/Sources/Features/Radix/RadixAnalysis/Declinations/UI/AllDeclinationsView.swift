// AllDeclinationsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct AllDeclinationsView: View {
    @Binding var activeTab: DeclinationsTab

    @EnvironmentObject private var chartSession: ChartSession

    @State private var showHelp = false

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Declinations", bundle: .main, comment: "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(DeclinationsKeys.allDeclinationsTitle))
                    .font(.title2.weight(.semibold))

                Text(t(DeclinationsKeys.allDeclinationsNoData))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                tabPicker
            }
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            NavigationStack {
                ScrollView {
                    Text(t(DeclinationsKeys.allDeclinationsHelp))
                        .padding()
                }
                .navigationTitle("Help")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("OK") { showHelp = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var tabPicker: some View {
        Picker("", selection: $activeTab) {
            Text(t(DeclinationsKeys.btnAllDeclinations)).tag(DeclinationsTab.all)
            Text(t(DeclinationsKeys.btnParallels)).tag(DeclinationsTab.parallels)
            Text(t(DeclinationsKeys.btnEquivalents)).tag(DeclinationsTab.equivalents)
            Text(t(DeclinationsKeys.btnDiagram)).tag(DeclinationsTab.diagram)
            Text(t(DeclinationsKeys.btnMidpoints)).tag(DeclinationsTab.midpoints)
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
}
