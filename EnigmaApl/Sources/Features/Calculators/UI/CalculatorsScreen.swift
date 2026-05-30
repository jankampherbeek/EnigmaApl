// CalculatorsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func ca(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Calculators", bundle: .main, comment: "")
}

struct CalculatorsScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(ca(CalculatorsKeys.title))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(ca(CalculatorsKeys.select))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
