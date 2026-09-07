// ImportExportDetailScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ImportExport", bundle: .main, comment: "")
}

/// Detail screen for a single import/export format. Enigma has a real
/// implementation; the other (chart-only) formats still show a placeholder
/// until their mapping is specified.
struct ImportExportDetailScreen: View {
    let section: ImportExportSection

    private var supportsExport: Bool {
        section != .astroDienst
    }

    var body: some View {
        if section == .enigma {
            EnigmaImportExportScreen()
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(format: t(ImportExportKeys.detailTitle), section.rawValue))
                    .font(.title2.weight(.semibold))
                Text(t(ImportExportKeys.detailBody))
                    .foregroundStyle(.secondary)

                Divider()

                Label(t(ImportExportKeys.capabilitiesChartsOnly), systemImage: "info.circle")
                Label(
                    t(supportsExport ? ImportExportKeys.directionBoth : ImportExportKeys.directionImportOnly),
                    systemImage: "arrow.up.arrow.down"
                )
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
