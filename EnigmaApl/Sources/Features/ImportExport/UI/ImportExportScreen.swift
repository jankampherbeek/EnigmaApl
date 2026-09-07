// ImportExportScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ImportExport", bundle: .main, comment: "")
}

/// Landing view for the Import/Export mode, shown in the content column.
/// The actual per-format screen is shown in the detail column.
struct ImportExportScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(t(ImportExportKeys.title))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(t(ImportExportKeys.select))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
