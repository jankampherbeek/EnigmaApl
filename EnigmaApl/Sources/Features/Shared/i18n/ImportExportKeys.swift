// ImportExportKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for the Import/Export feature, resolved from ImportExport.strings.
struct ImportExportKeys {
    private init() {}

    // MARK: - ImportExportScreen
    static let title  = "view.importexport.title"
    static let select = "view.importexport.select"

    // MARK: - ImportExportDetailScreen
    static let detailTitle = "view.importexport.detail.title"

    // MARK: - EnigmaImportExportScreen
    static let enigmaBody          = "view.importexport.enigma.body"
    static let enigmaExportButton  = "view.importexport.enigma.export.button"
    static let enigmaImportButton  = "view.importexport.enigma.import.button"
    static let enigmaExportSuccess = "view.importexport.enigma.export.success"
    static let enigmaImportSuccess = "view.importexport.enigma.import.success"

    // MARK: - Shared warnings list (Qck/Aaf/Adb screens)
    static let warningsHeader = "view.importexport.warnings.header"

    // MARK: - QckImportExportScreen
    static let qckBody          = "view.importexport.qck.body"
    static let qckExportButton  = "view.importexport.qck.export.button"
    static let qckImportButton  = "view.importexport.qck.import.button"
    static let qckExportSuccess = "view.importexport.qck.export.success"
    static let qckImportSuccess = "view.importexport.qck.import.success"
    static let qckRecordMessage = "view.importexport.qck.record.message"

    // MARK: - AafImportExportScreen
    static let aafBody          = "view.importexport.aaf.body"
    static let aafExportButton  = "view.importexport.aaf.export.button"
    static let aafImportButton  = "view.importexport.aaf.import.button"
    static let aafExportSuccess = "view.importexport.aaf.export.success"
    static let aafImportSuccess = "view.importexport.aaf.import.success"
    static let aafRecordMessage = "view.importexport.aaf.record.message"

    // MARK: - AdbXmlImportScreen
    static let adbBody          = "view.importexport.adb.body"
    static let adbImportButton  = "view.importexport.adb.import.button"
    static let adbImportSuccess = "view.importexport.adb.import.success"
    static let adbRecordMessage = "view.importexport.adb.record.message"
}
