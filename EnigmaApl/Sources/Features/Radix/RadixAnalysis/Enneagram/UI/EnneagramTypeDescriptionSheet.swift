// EnneagramTypeDescriptionSheet.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct EnneagramTypeDescriptionSheet: View {
    let type: Int

    @Environment(\.dismiss) private var dismiss

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Enneagram", bundle: .main, comment: "")
    }

    private var typeName: String {
        switch type {
        case 1: return t(EnneagramKeys.type1)
        case 2: return t(EnneagramKeys.type2)
        case 3: return t(EnneagramKeys.type3)
        case 4: return t(EnneagramKeys.type4)
        case 5: return t(EnneagramKeys.type5)
        case 6: return t(EnneagramKeys.type6)
        case 7: return t(EnneagramKeys.type7)
        case 8: return t(EnneagramKeys.type8)
        default: return t(EnneagramKeys.type9)
        }
    }

    private var description: String {
        switch type {
        case 1: return t(EnneagramKeys.desc1)
        case 2: return t(EnneagramKeys.desc2)
        case 3: return t(EnneagramKeys.desc3)
        case 4: return t(EnneagramKeys.desc4)
        case 5: return t(EnneagramKeys.desc5)
        case 6: return t(EnneagramKeys.desc6)
        case 7: return t(EnneagramKeys.desc7)
        case 8: return t(EnneagramKeys.desc8)
        default: return t(EnneagramKeys.desc9)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Type \(type) — \(typeName)")
                .font(.title2.weight(.semibold))
            ScrollView {
                Text(description)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Spacer()
                Button("OK") { dismiss() }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(minWidth: 360, minHeight: 200)
    }
}
