// PreNatalFactorSelectionSheet.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "PreNatal", bundle: .main, comment: "")
}

struct PreNatalFactorSelectionSheet: View {
    @EnvironmentObject private var model: PreNatalModel
    @Environment(\.dismiss) private var dismiss

    @State private var selected: Set<Factors>

    init(currentSelection: [Factors]) {
        _selected = State(initialValue: Set(currentSelection))
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(t(PreNatalKeys.factorSelTitle))
                .font(.headline)
                .padding()

            Divider()

            List(PreNatalOrchestrator.selectableFactors, id: \.self) { factor in
                Toggle(isOn: Binding(
                    get: { selected.contains(factor) },
                    set: { on in if on { selected.insert(factor) } else { selected.remove(factor) } }
                )) {
                    HStack(spacing: 8) {
                        Text(GlyphSelector.getGlyphForFactor(factor))
                            .font(.custom("EnigmaAstrology3", size: 20))
                            .frame(width: 28)
                        Text(NSLocalizedString(factor.localizedName, comment: ""))
                    }
                }
            }

            Divider()

            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button(t(PreNatalKeys.selectionDone)) {
                    model.selectedFactors = PreNatalOrchestrator.selectableFactors.filter { selected.contains($0) }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(minWidth: 360, minHeight: 480)
    }
}
