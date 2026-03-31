// HarmonicDrawingView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct HarmonicDrawingView: View {
    let harmonicNumber: Double
    @Binding var harmonicText: String

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "RadixAnalysis", bundle: .main, comment: "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(t(RadixAnalysisKeys.drawingTitle))
                .font(.title2.weight(.semibold))

            HStack(spacing: 8) {
                Text(t(RadixAnalysisKeys.inputLabel))
                    .font(.callout)
                TextField("", text: $harmonicText)
                    .textFieldStyle(.roundedBorder)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .frame(width: 80)
            }

            Text(t(RadixAnalysisKeys.drawingPlaceholder))
                .foregroundStyle(.secondary)
                .font(.callout)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}
