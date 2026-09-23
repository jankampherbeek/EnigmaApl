// AltZodiacStartInputView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct AltZodiacStartInputView: View {
    @EnvironmentObject private var model:    AltZodiacStartModel
    @EnvironmentObject private var radixNav: RadixNavigator
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]
    @State private var showHelp = false

    /// Factors selectable as the alternative zodiac's starting point: every factor the
    /// user has enabled ("isUsed") in the active configuration.
    private var selectableFactors: [Factors] {
        guard let config = activeConfigs.first else { return [] }
        let usedFactors = Set(config.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor })
        return Factors.selectableCases.filter { usedFactors.contains($0) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Button {
                    radixNav.setInspector(.analysis)
                } label: {
                    Label(t(AltZodiacStartKeys.backLabel), systemImage: "chevron.left")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Text(t(AltZodiacStartKeys.inputTitle))
                    .font(.title2.weight(.semibold))

                GroupBox(label: Text(t(AltZodiacStartKeys.factorHeader)).font(.headline)) {
                    if selectableFactors.isEmpty {
                        Text(t(AltZodiacStartKeys.noFactors))
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(selectableFactors, id: \.self) { factor in
                                radioOption(factor: factor, selected: model.startFactor == factor) {
                                    model.startFactor = factor
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
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
            WheelHelpSheet(helpText: t(AltZodiacStartKeys.inputHelp))
        }
        .onAppear { ensureValidSelection() }
        .onChange(of: activeConfigs.first?.factorConfigData) { _, _ in ensureValidSelection() }
    }

    /// Falls back to the first selectable factor whenever the current selection is no
    /// longer among the factors enabled in the active configuration.
    private func ensureValidSelection() {
        guard !selectableFactors.contains(model.startFactor),
              let fallback = selectableFactors.first else { return }
        model.startFactor = fallback
    }

    // MARK: - Helpers

    private func radioOption(factor: Factors, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: selected ? "circle.inset.filled" : "circle")
                    .imageScale(.medium)
                Text(GlyphSelector.getGlyphForFactor(factor))
                    .font(.custom("EnigmaAstrology3", size: 18))
                    .frame(width: 24, alignment: .center)
                Text(NSLocalizedString(factor.localizedName, comment: ""))
            }
        }
        .buttonStyle(.plain)
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "AltZodiacStart", bundle: .main, comment: "")
    }
}
