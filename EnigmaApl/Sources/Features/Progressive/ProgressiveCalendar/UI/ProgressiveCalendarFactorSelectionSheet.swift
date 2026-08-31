// ProgressiveCalendarFactorSelectionSheet.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ProgressiveCalendar", bundle: .main, comment: "")
}

/// Reusable multi-select factor sheet, shared by the four factor pickers on the Progressive
/// Calendar input screen (transit/secondary/symbolic/radix factors) — each supplies its own
/// title and current selection, and receives the result through `onDone`.
struct ProgressiveCalendarFactorSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let selectableFactors: [Factors]
    let onDone: ([Factors]) -> Void

    @State private var selected: Set<Factors>

    init(title: String, selectableFactors: [Factors], currentSelection: [Factors], onDone: @escaping ([Factors]) -> Void) {
        self.title = title
        self.selectableFactors = selectableFactors
        self.onDone = onDone
        _selected = State(initialValue: Set(currentSelection))
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.headline)
                .padding()

            Divider()

            List(selectableFactors, id: \.self) { factor in
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
                Button(t(ProgressiveCalendarKeys.selectionCancel)) { dismiss() }
                Spacer()
                Button(t(ProgressiveCalendarKeys.selectionDone)) {
                    onDone(selectableFactors.filter { selected.contains($0) })
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
