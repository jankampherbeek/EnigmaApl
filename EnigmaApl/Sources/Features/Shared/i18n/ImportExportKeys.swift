// ImportExportKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for the Import/Export feature, resolved from ImportExport.strings.
struct ImportExportKeys {
    private init() {}

    // MARK: - ImportExportScreen
    static let title  = "view.importexport.title"
    static let select = "view.importexport.select"

    // MARK: - ImportExportDetailScreen (placeholder formats)
    static let detailTitle            = "view.importexport.detail.title"
    static let detailBody             = "view.importexport.detail.body"
    static let capabilitiesChartsOnly = "view.importexport.detail.capabilities.chartsonly"
    static let directionBoth          = "view.importexport.detail.direction.both"
    static let directionImportOnly    = "view.importexport.detail.direction.importonly"

    // MARK: - EnigmaImportExportScreen
    static let enigmaBody          = "view.importexport.enigma.body"
    static let enigmaExportButton  = "view.importexport.enigma.export.button"
    static let enigmaImportButton  = "view.importexport.enigma.import.button"
    static let enigmaExportSuccess = "view.importexport.enigma.export.success"
    static let enigmaImportSuccess = "view.importexport.enigma.import.success"
}
