// ImportExportDetailScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// Detail screen for a single import/export format: dispatches to each
/// format's real import/export screen.
struct ImportExportDetailScreen: View {
    let section: ImportExportSection

    var body: some View {
        switch section {
        case .enigma:
            EnigmaImportExportScreen()
        case .quickChart:
            QckImportExportScreen()
        case .aaf97:
            AafImportExportScreen()
        case .astroDienst:
            AdbXmlImportScreen()
        }
    }
}
