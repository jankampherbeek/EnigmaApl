// ImportOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Errors thrown by ImportOrchestrator.
enum ImportOrchestratorError: Error {
    case parseFailed(Error)
    case databaseFailed(Error)
    case noRecordsAfterImport
}

/// Coordinates the full import flow for one data file into a research project:
/// 1. Parse the source file using the supplied `DataImporter`
/// 2. Persist real-data records into `horoscope_data.db`
/// 3. Generate control-group records using `ControlGroupGenerator`
/// 4. Persist control-group records into the same database
///
/// All work is synchronous — call from a background `Task`.
struct ImportOrchestrator {

    private let generator: ControlGroupGenerator

    init(generator: ControlGroupGenerator = ControlGroupGenerator()) {
        self.generator = generator
    }

    /// Runs the import pipeline.
    /// - Parameters:
    ///   - sourceFile: Path to the data file to import.
    ///   - importer: The `DataImporter` matching the file's format.
    ///   - project: The project model that owns the database and provides `cgMultiplication`.
    /// - Returns: Tuple of `(realCount, controlCount)` — number of records inserted for each group.
    @discardableResult
    func run(
        sourceFile: String,
        importer: DataImporter,
        project: ResearchProjectModel
    ) throws -> (realCount: Int, controlCount: Int) {
        try runWith(sourceFile: sourceFile, importer: importer,
                    projectPath: project.path, cgMultiplication: project.cgMultiplication)
    }

    /// Sendable-safe entry point — accepts plain values instead of the SwiftData model.
    /// Use this when calling from a background `Task.detached` across actor boundaries.
    @discardableResult
    func runWith(
        sourceFile: String,
        importer: DataImporter,
        projectPath: String,
        cgMultiplication: Int
    ) throws -> (realCount: Int, controlCount: Int) {
        // 1. Parse
        let realRecords: [ResearchInputRecord]
        do {
            realRecords = try importer.parse(source: sourceFile, isData: true, startId: 1)
        } catch {
            throw ImportOrchestratorError.parseFailed(error)
        }

        guard !realRecords.isEmpty else {
            throw ImportOrchestratorError.noRecordsAfterImport
        }

        // 2. Open the database and reset it for a fresh import.
        //    Strategy: try to delete the file first (cleanest); if that fails
        //    (e.g. permissions), open the existing file and DROP + recreate the
        //    table instead. Log every failure so the log file reveals the real cause.
        let dbURL = URL(fileURLWithPath: projectPath, isDirectory: true)
            .appendingPathComponent("horoscope_data.db")

        let fileDeleted: Bool
        do {
            try FileManager.default.removeItem(at: dbURL)
            try? FileManager.default.removeItem(at: dbURL.appendingPathExtension("wal"))
            try? FileManager.default.removeItem(at: dbURL.appendingPathExtension("shm"))
            fileDeleted = true
        } catch {
            Logger.log.warning("ImportOrchestrator: could not delete DB file at '\(dbURL.path)': \(error.localizedDescription)")
            fileDeleted = false
        }

        let db: ResearchDbManager
        do {
            db = try ResearchDbManager(folderPath: projectPath)
            if !fileDeleted {
                // File still exists — reset by dropping and recreating the table.
                try db.resetTable()
            }
        } catch {
            Logger.log.error("ImportOrchestrator: DB open/reset failed at '\(projectPath)': \(error)")
            throw ImportOrchestratorError.databaseFailed(error)
        }

        // 3. Persist real data
        do {
            try db.insertAll(realRecords)
        } catch {
            throw ImportOrchestratorError.databaseFailed(error)
        }

        // 4. Generate and persist control group
        let controlStartId = (realRecords.last?.id ?? 0) + 1
        let controlRecords = generator.generate(
            from: realRecords,
            multiplicity: cgMultiplication,
            startId: controlStartId
        )

        if !controlRecords.isEmpty {
            do {
                try db.insertAll(controlRecords)
            } catch {
                throw ImportOrchestratorError.databaseFailed(error)
            }
        }

        return (realCount: realRecords.count, controlCount: controlRecords.count)
    }
}
