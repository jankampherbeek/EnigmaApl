// ZodiacDivisionsInputView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct ZodiacDivisionsInputView: View {
    @EnvironmentObject private var model:    ZodiacDivisionsModel
    @EnvironmentObject private var radixNav: RadixNavigator
    @State private var showHelp = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Button {
                    radixNav.setInspector(.analysis)
                } label: {
                    Label(t(ZodiacDivisionsKeys.backLabel), systemImage: "chevron.left")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Text(t(ZodiacDivisionsKeys.inputTitle))
                    .font(.title2.weight(.semibold))

                // Decans
                GroupBox(label: Text(t(ZodiacDivisionsKeys.decansHeader)).font(.headline)) {
                    VStack(alignment: .leading, spacing: 6) {
                        radioOption(t(ZodiacDivisionsKeys.decansSigns),   selected: !model.useDecansPlanet) {
                            model.useDecansPlanet = false
                        }
                        radioOption(t(ZodiacDivisionsKeys.decansPlanets), selected: model.useDecansPlanet) {
                            model.useDecansPlanet = true
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Dodecatemoria
                GroupBox(label: Text(t(ZodiacDivisionsKeys.dodecatsHeader)).font(.headline)) {
                    VStack(alignment: .leading, spacing: 6) {
                        radioOption(t(ZodiacDivisionsKeys.dodecatsOriginal), selected: model.useDodecatsOriginal) {
                            model.useDodecatsOriginal = true
                        }
                        radioOption(t(ZodiacDivisionsKeys.dodecatsPaulus),  selected: !model.useDodecatsOriginal) {
                            model.useDodecatsOriginal = false
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Bounds
                GroupBox(label: Text(t(ZodiacDivisionsKeys.boundsHeader)).font(.headline)) {
                    VStack(alignment: .leading, spacing: 6) {
                        radioOption(t(ZodiacDivisionsKeys.boundsEgyptian), selected: model.useBoundsEgyptian) {
                            model.useBoundsEgyptian = true
                        }
                        radioOption(t(ZodiacDivisionsKeys.boundsPtolemy),  selected: !model.useBoundsEgyptian) {
                            model.useBoundsEgyptian = false
                        }
                    }
                    .padding(.vertical, 4)
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
            WheelHelpSheet(helpText: t(ZodiacDivisionsKeys.inputHelp))
        }
    }

    // MARK: - Helpers

    private func radioOption(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: selected ? "circle.inset.filled" : "circle")
                    .imageScale(.medium)
                Text(title)
            }
        }
        .buttonStyle(.plain)
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ZodiacDivisions", bundle: .main, comment: "")
    }
}
