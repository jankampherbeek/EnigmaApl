// ProgressiveCalendarAspectSelectionSheet.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ProgressiveCalendar", bundle: .main, comment: "")
}

struct ProgressiveCalendarAspectSelectionSheet: View {
    @EnvironmentObject private var model: ProgressiveCalendarModel
    @Environment(\.dismiss) private var dismiss

    @State private var selected: Set<Aspects>

    init(currentSelection: [Aspects]) {
        _selected = State(initialValue: Set(currentSelection))
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(t(ProgressiveCalendarKeys.aspectSelTitle))
                .font(.headline)
                .padding()

            Divider()

            List(Aspects.allCases, id: \.self) { aspect in
                Toggle(isOn: Binding(
                    get: { selected.contains(aspect) },
                    set: { on in if on { selected.insert(aspect) } else { selected.remove(aspect) } }
                )) {
                    HStack(spacing: 8) {
                        Text(GlyphSelector.getGlyphForAspect(aspect))
                            .font(.custom("EnigmaAstrology3", size: 20))
                            .frame(width: 28)
                        Text(NSLocalizedString(aspect.rbKey, comment: ""))
                        Spacer()
                        Text(String(format: "%.2f°", aspect.angle))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Divider()

            HStack {
                Button(t(ProgressiveCalendarKeys.selectionCancel)) { dismiss() }
                Spacer()
                Button(t(ProgressiveCalendarKeys.selectionDone)) {
                    model.aspects = Aspects.allCases.filter { selected.contains($0) }
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
