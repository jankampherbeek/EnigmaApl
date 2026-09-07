// EnigmaImportExportModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData
import Combine

/// Model for EnigmaImportExportScreen.
/// Encodes/decodes the Enigma JSON format and delegates persistence to
/// EnigmaImportExportOrchestrator. Call setup(context:) once from onAppear
/// before export()/importData(_:).
@MainActor
final class EnigmaImportExportModel: ObservableObject {

    @Published var statusMessage: String?
    @Published var errorMessage: String?

    private var modelContext: ModelContext?

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ImportExport", bundle: .main, comment: "")
    }

    func setup(context: ModelContext) {
        modelContext = context
    }

    /// Encodes all charts and events into the Enigma JSON export format.
    /// Returns nil (and sets errorMessage) if encoding or fetching fails.
    func export() -> Data? {
        guard let context = modelContext else { return nil }
        do {
            let file = try EnigmaImportExportOrchestrator(context: context).buildExportFile()
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(file)
            statusMessage = String(format: t(ImportExportKeys.enigmaExportSuccess), file.charts.count, file.events.count)
            errorMessage = nil
            return data
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    /// Decodes the given Enigma JSON data and imports it, skipping any chart or
    /// event whose id already exists locally.
    func importData(_ data: Data) {
        guard let context = modelContext else { return }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let file = try decoder.decode(EnigmaExportFile.self, from: data)
            let result = try EnigmaImportExportOrchestrator(context: context).importFile(file)
            statusMessage = String(
                format: t(ImportExportKeys.enigmaImportSuccess),
                result.chartsImported, result.eventsImported, result.chartsSkipped, result.eventsSkipped
            )
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
