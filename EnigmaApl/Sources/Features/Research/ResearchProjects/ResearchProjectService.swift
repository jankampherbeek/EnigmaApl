// ResearchProjectService.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

/// Errors thrown by ResearchProjectService.
enum ResearchProjectServiceError: Error {
    case folderCreationFailed(String)
    case folderDeletionFailed(String)
    case configEncodingFailed
    case daoFailed(Error)
    case projectNotFound(String)
}

/// Single façade for all project-level operations:
/// create, delete, list, search, import data, run analysis, export results.
///
/// Owns the `ResearchProjectDao`, `ImportOrchestrator`, `AnalysisOrchestrator`,
/// and `ResultsExporter` — callers interact with this service only.
@MainActor
final class ResearchProjectService {

    private let dao: ResearchProjectDao
    private let importOrchestrator: ImportOrchestrator
    private let analysisOrchestrator: AnalysisOrchestrator
    private let exporter: ResultsExporter
    private let pipelineOrchestrator: ResearchPipelineOrchestrator

    init(
        context: ModelContext,
        pipelineOrchestrator: ResearchPipelineOrchestrator
    ) {
        self.dao = ResearchProjectDao(context: context)
        self.importOrchestrator = ImportOrchestrator()
        self.analysisOrchestrator = AnalysisOrchestrator()
        self.exporter = ResultsExporter()
        self.pipelineOrchestrator = pipelineOrchestrator
    }

    // MARK: - List / Search

    /// Returns all project names sorted alphabetically.
    func allProjectNames() throws -> [String] {
        do { return try dao.fetchAllNames() }
        catch { throw ResearchProjectServiceError.daoFailed(error) }
    }

    /// Returns all projects sorted alphabetically by name.
    func allProjects() throws -> [ResearchProjectModel] {
        do { return try dao.fetchAll() }
        catch { throw ResearchProjectServiceError.daoFailed(error) }
    }

    /// Returns the project with the given name, or `nil` if not found.
    func project(named name: String) throws -> ResearchProjectModel? {
        do { return try dao.fetch(byName: name) }
        catch { throw ResearchProjectServiceError.daoFailed(error) }
    }

    // MARK: - Create

    /// Creates a new research project: makes the project folder on disk and persists the model.
    /// - Parameters:
    ///   - name: Unique project name.
    ///   - description: Free-text description.
    ///   - inquiry: The type of statistical inquiry.
    ///   - config: The `ResearchConfig` describing factors and coordinate systems.
    ///   - cgMultiplication: Control-group size multiplier.
    ///   - baseFolder: Parent directory under which the project subfolder is created.
    @discardableResult
    func createProject(
        name: String,
        description: String,
        inquiry: Inquiries,
        config: ResearchConfig,
        cgMultiplication: Int,
        baseFolder: String
    ) throws -> ResearchProjectModel {
        // Create folder
        let projectFolder = URL(fileURLWithPath: baseFolder, isDirectory: true)
            .appendingPathComponent(sanitisedFolderName(name))
            .path
        do {
            try FileManager.default.createDirectory(
                atPath: projectFolder,
                withIntermediateDirectories: true
            )
        } catch {
            throw ResearchProjectServiceError.folderCreationFailed(projectFolder)
        }

        // Encode config
        let configJson: String
        do { configJson = try config.toJson() }
        catch { throw ResearchProjectServiceError.configEncodingFailed }

        // Persist
        let id = Int(Date().timeIntervalSince1970)   // simple unique id
        do {
            return try dao.add(
                id: id,
                name: name,
                projectDescription: description,
                enquiry: inquiry,
                config: configJson,
                cgMultiplication: cgMultiplication,
                path: projectFolder
            )
        } catch {
            throw ResearchProjectServiceError.daoFailed(error)
        }
    }

    // MARK: - Delete

    /// Deletes the project from SwiftData and removes its folder and all files from disk.
    func deleteProject(_ project: ResearchProjectModel) throws {
        // Remove folder
        if FileManager.default.fileExists(atPath: project.path) {
            do {
                try FileManager.default.removeItem(atPath: project.path)
            } catch {
                throw ResearchProjectServiceError.folderDeletionFailed(project.path)
            }
        }
        // Remove from SwiftData
        do { try dao.delete(project) }
        catch { throw ResearchProjectServiceError.daoFailed(error) }
    }

    // MARK: - Import data

    /// Imports a data file into a project's `horoscope_data.db` and generates the control group.
    /// - Parameters:
    ///   - sourceFile: Path to the data file.
    ///   - importer: The `DataImporter` matching the file format (e.g. `EnigmaFormatImporter()`).
    ///   - project: The target project.
    /// - Returns: `(realCount, controlCount)` — rows inserted per group.
    @discardableResult
    func importData(
        from sourceFile: String,
        using importer: DataImporter,
        into project: ResearchProjectModel
    ) throws -> (realCount: Int, controlCount: Int) {
        try importOrchestrator.run(sourceFile: sourceFile, importer: importer, project: project)
    }

    // MARK: - Run pipeline

    /// Starts the calculation pipeline (reads `horoscope_data.db`, calculates charts,
    /// writes `results.bin`). Progress is published on `pipelineOrchestrator.progress`.
    func runPipeline(for project: ResearchProjectModel) throws {
        guard let config = try? ResearchConfig.from(json: project.config) else {
            throw ResearchProjectServiceError.configEncodingFailed
        }
        pipelineOrchestrator.run(project: project, config: config)
    }

    /// Cancels a running pipeline.
    func cancelPipeline() {
        pipelineOrchestrator.cancel()
    }

    // MARK: - Analysis

    /// Runs the analysis worker matching the project's `inquiryType` and returns the result.
    /// Call from a background `Task` — work is synchronous and may be large.
    func runAnalysis(for project: ResearchProjectModel) throws -> AnalysisResult {
        try analysisOrchestrator.run(project: project)
    }

    // MARK: - Export

    /// Exports an analysis result to a CSV file.
    /// - Parameters:
    ///   - result: The result to export.
    ///   - destinationPath: Full path of the output CSV file.
    func exportResult(_ result: AnalysisResult, to destinationPath: String) throws {
        try exporter.export(result, to: destinationPath)
    }

    // MARK: - Helpers

    /// Converts a project name to a safe folder name (replaces spaces and special chars with underscores).
    private func sanitisedFolderName(_ name: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(.init(charactersIn: "-_"))
        return name.unicodeScalars
            .map { allowed.contains($0) ? String($0) : "_" }
            .joined()
    }
}
