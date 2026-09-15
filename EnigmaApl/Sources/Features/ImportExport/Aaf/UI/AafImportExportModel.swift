// AafImportExportModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData
import Combine

/// Model for AafImportExportScreen. Delegates parsing, mapping and
/// persistence to AafImportExportOrchestrator. Call setup(context:) once
/// from onAppear before export()/importData(_:).
@MainActor
final class AafImportExportModel: ObservableObject {

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

    func export() -> Data? {
        guard let context = modelContext else { return nil }
        do {
            let (data, messages) = try AafImportExportOrchestrator(context: context).exportData()
            let chartCount = (try? context.fetch(FetchDescriptor<HoroscopeModel>()))?.count ?? 0
            statusMessage = String(format: t(ImportExportKeys.aafExportSuccess), chartCount)
            errorMessage = nil
            warnings = messages.map(describe)
            return data
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func importData(_ data: Data) {
        guard let context = modelContext else { return }
        let result = AafImportExportOrchestrator(context: context).importFile(data: data)
        statusMessage = String(format: t(ImportExportKeys.aafImportSuccess), result.chartsImported)
        errorMessage = result.fatalMessages.isEmpty ? nil : result.fatalMessages.map(describe).joined(separator: "\n")
        warnings = result.warningMessages.map(describe)
    }

    private func describe(_ message: ExchangeMessage) -> String {
        if let recordNumber = message.recordNumber {
            return String(format: t(ImportExportKeys.aafRecordMessage), recordNumber, message.message)
        }
        return message.message
    }
}
