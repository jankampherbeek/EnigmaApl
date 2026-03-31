// AnalysisScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
import SwiftUI

struct AnalysisScreen: View {
    @EnvironmentObject private var radixNav: RadixNavigator

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(t(RadixAnalysisKeys.title))
                .font(.title2.weight(.semibold))

            Button(t(RadixAnalysisKeys.btnAspects)) {
                radixNav.setInspector(.analysisAspects)
            }
            .buttonStyle(.bordered)

            Button(t(RadixAnalysisKeys.btnMidpoints)) {
                radixNav.setInspector(.analysisMidpoints)
            }
            .buttonStyle(.bordered)

            Button(t(RadixAnalysisKeys.btnHarmonics)) {
                radixNav.setInspector(.analysisHarmonics)
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "RadixAnalysis", bundle: .main, comment: "")
    }
}
