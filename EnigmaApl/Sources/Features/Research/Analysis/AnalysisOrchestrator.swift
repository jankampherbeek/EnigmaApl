// AnalysisOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Errors thrown by AnalysisOrchestrator.
enum AnalysisOrchestratorError: Error {
    case missingResultsFile(String)
    case configDecodingFailed
    case inquiryNotSupported(Inquiries)
    case workerFailed(Error)
}

/// Typed union of all possible analysis results.
/// Add a new case here when each additional `Inquiries` worker is implemented.
enum AnalysisResult: Sendable {
    case factorsInSigns(FactorsInSignsResult)
    // future cases: factorsInHouses, aspects, …
}

/// Dispatches analysis for a project to the correct worker based on the project's `inquiryType`.
/// Opens `results.bin` (memory-mapped), runs the worker synchronously, and returns the result.
///
/// Call from a background `Task` — the work is synchronous and potentially large.
struct AnalysisOrchestrator {

    init() {}

    /// Runs the analysis for the given project.
    /// - Parameter project: The `ResearchProjectModel` describing the project.
    /// - Returns: An `AnalysisResult` matching the project's `inquiryType`.
    func run(project: ResearchProjectModel) throws -> AnalysisResult {
        guard let config = try? ResearchConfig.from(json: project.config) else {
            throw AnalysisOrchestratorError.configDecodingFailed
        }

        let binaryFile: ResultsBinaryFile
        do {
            binaryFile = try ResultsBinaryFile.open(at: project.path)
        } catch {
            throw AnalysisOrchestratorError.missingResultsFile(project.path)
        }

        guard let inquiry = project.inquiryType else {
            throw AnalysisOrchestratorError.inquiryNotSupported(.factorsInSigns)
        }

        switch inquiry {
        case .factorsInSigns:
            let worker = FactorsInSignsWorker(binaryFile: binaryFile, config: config)
            do {
                let result = try worker.run()
                return .factorsInSigns(result)
            } catch {
                throw AnalysisOrchestratorError.workerFailed(error)
            }

        default:
            throw AnalysisOrchestratorError.inquiryNotSupported(inquiry)
        }
    }
}
