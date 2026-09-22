// QckImportExportModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData
import Combine

/// Model for QckImportExportScreen. Delegates parsing, mapping and
/// persistence to QckImportExportOrchestrator. Call setup(context:) once
/// from onAppear before export()/importData(_:).
@MainActor
final class QckImportExportModel: ObservableObject {

    @Published var statusMessage: String?
    @Published var errorMessage: String?

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
            let (data, messages) = try QckImportExportOrchestrator(context: context).exportData()
            let fatalMessages = messages.filter { $0.severity == .fatal }
            statusMessage = String(format: t(ImportExportKeys.qckExportSuccess), countLines(in: data))
            errorMessage = fatalMessages.isEmpty ? nil : fatalMessages.map(describe).joined(separator: "\n")
            return data
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func importData(_ data: Data) {
        guard let context = modelContext else { return }
        let result = QckImportExportOrchestrator(context: context).importFile(data: data)
        statusMessage = String(format: t(ImportExportKeys.qckImportSuccess), result.chartsImported)
        errorMessage = result.fatalMessages.isEmpty ? nil : result.fatalMessages.map(describe).joined(separator: "\n")
    }

    private func countLines(in data: Data) -> Int {
        guard let text = String(data: data, encoding: LegacyTextEncoding.defaultLegacyEncoding) else { return 0 }
        return text.split(separator: "\r\n", omittingEmptySubsequences: true).count
    }

    private func describe(_ message: ExchangeMessage) -> String {
        if let recordNumber = message.recordNumber {
            return String(format: t(ImportExportKeys.qckRecordMessage), recordNumber, message.message)
        }
        return message.message
    }
}
