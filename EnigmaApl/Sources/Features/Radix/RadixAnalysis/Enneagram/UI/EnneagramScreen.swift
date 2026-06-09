// EnneagramOptionsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct EnneagramOptionsView: View {
    @EnvironmentObject private var enneagramModel: EnneagramModel

    @State private var showFactsheet = false

    /// Display order matches the Windows reference application.
    private static let supportedFactors: [Factors] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn,
        .uranus, .neptune, .pluto, .chiron, .northNode, .apogeeMean
    ]

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Enneagram", bundle: .main, comment: "")
    }

    private func factorName(_ factor: Factors) -> String {
        NSLocalizedString(factor.localizedName, bundle: .main, comment: "")
    }

    private func toggleBinding(for factor: Factors) -> Binding<Bool> {
        Binding(
            get: { enneagramModel.options.selectedFactors.contains(factor) },
            set: { isOn in
                if isOn {
                    enneagramModel.options.selectedFactors.insert(factor)
                } else {
                    enneagramModel.options.selectedFactors.remove(factor)
                }
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text(t(EnneagramKeys.optionsTitle))
                    .font(.title2.weight(.semibold))

                // Planet selection
                GroupBox(label: Text(t(EnneagramKeys.optionsPlanets)).font(.headline)) {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Self.supportedFactors, id: \.self) { factor in
                            Toggle(isOn: toggleBinding(for: factor)) {
                                HStack(spacing: 8) {
                                    Text(GlyphSelector.getGlyphForFactor(factor))
                                        .font(.custom("EnigmaAstrology2", size: 18))
                                        .frame(width: 24, alignment: .center)
                                    Text(factorName(factor))
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Calculation options
                GroupBox(label: Text(t(EnneagramKeys.optionsSettings)).font(.headline)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle(t(EnneagramKeys.optUseHouses),   isOn: $enneagramModel.options.useHouses)
                        Toggle(t(EnneagramKeys.optDoublePluto), isOn: $enneagramModel.options.doublePluto)
                        Toggle(t(EnneagramKeys.optUpdated),     isOn: $enneagramModel.options.useUpdatedVersion)
                    }
                    .padding(.vertical, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showFactsheet = true } label: {
                    Image(systemName: "book.pages")
                }
                .accessibilityLabel("Factsheet")
            }
        }
        .sheet(isPresented: $showFactsheet) {
            FactsheetView(baseName: "enneagram")
        }
    }
}
