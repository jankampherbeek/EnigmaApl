// AnalysisScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
import SwiftUI

struct AnalysisScreen: View {
    @EnvironmentObject private var radixNav: RadixNavigator

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analyse")
                .font(.title2.weight(.semibold))

            Button("Aspecten") {
                radixNav.setInspector(.analysisAspects)
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}
