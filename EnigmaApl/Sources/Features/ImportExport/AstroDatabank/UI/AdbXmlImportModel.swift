// AdbXmlImportModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData
import Combine

/// Model for AdbXmlImportScreen. Delegates parsing, mapping and persistence
/// to AdbXmlImportOrchestrator. Call setup(context:) once from onAppear
/// before importData(_:). Import-only: Astro-Databank XML has no exporter.
@MainActor
final class AdbXmlImportModel: ObservableObject {

    @Published var statusMessage: String?
    @Published var errorMessage: String?
    @Published var warnings: [String] = []

    private var modelContext: ModelContext?

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ImportExport", bundle: .main, comment: "")
    }

    func setup(context: ModelContext) {
        modelContext = context
    }

    func importData(_ data: Data) {
        guard let context = modelContext else { return }
        let result = AdbXmlImportOrchestrator(context: context).importFile(data: data)
        statusMessage = String(format: t(ImportExportKeys.adbImportSuccess), result.chartsImported)
        errorMessage = result.fatalMessages.isEmpty ? nil : result.fatalMessages.map(describe).joined(separator: "\n")
        warnings = result.warningMessages.map(describe)
    }

    private func describe(_ message: ExchangeMessage) -> String {
        if let recordNumber = message.recordNumber {
            return String(format: t(ImportExportKeys.adbRecordMessage), recordNumber, message.message)
        }
        return message.message
    }
}
