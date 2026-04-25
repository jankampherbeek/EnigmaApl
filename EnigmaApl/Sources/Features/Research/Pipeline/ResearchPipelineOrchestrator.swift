// ResearchPipelineOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Combine
import Foundation

// MARK: - Progress

/// Phases the pipeline moves through in order.
enum PipelinePhase: Sendable {
    case idle
    case readingInput
    case calculating
    case writingResults
    case completed
    case failed(Error)
}

/// Snapshot of pipeline progress, published on the main actor.
struct PipelineProgress: Sendable, Equatable {
    static func == (lhs: PipelineProgress, rhs: PipelineProgress) -> Bool {
        lhs.recordsDone == rhs.recordsDone && lhs.totalRecords == rhs.totalRecords
    }
    let phase: PipelinePhase
    let recordsDone: Int
    let totalRecords: Int

    var fraction: Double {
        totalRecords > 0 ? Double(recordsDone) / Double(totalRecords) : 0
    }
}

// MARK: - Errors

enum PipelineError: Error {
    case missingCalculationConfig
    case inputReadFailed(Error)
    case binaryFileCreationFailed(Error)
    case calculationFailed(recordId: Int, underlying: Error)
    case writeFailed(Error)
    case cancelled
}

// MARK: - Orchestrator

/// Runs the full research calculation pipeline for one `ResearchProjectModel`.
///
/// Pipeline flow:
/// 1. Read all `ResearchInputRecord` rows from `horoscope_data.db`
/// 2. Create `results.bin` with the correct header
/// 3. For each record: `await seActor.calculate(...)` (serialised SE calls)
/// 4. Write each result immediately into `results.bin`
/// 5. Publish `PipelineProgress` updates on the main actor
/// 6. Honour `Task.isCancelled` between records
///
/// Usage:
/// ```swift
/// let orchestrator = ResearchPipelineOrchestrator()
/// for await progress in orchestrator.progressStream {
///     updateUI(progress)
/// }
/// try await orchestrator.run(project: model)
/// ```
@MainActor
final class ResearchPipelineOrchestrator: ObservableObject {

    // MARK: - Published state

    @Published private(set) var progress = PipelineProgress(
        phase: .idle, recordsDone: 0, totalRecords: 0
    )

    // MARK: - Private state

    private var pipelineTask: Task<Void, Error>?

    // MARK: - Public API

    /// Starts the pipeline for the given project.
    /// Cancels any previously running pipeline first.
    /// - Parameters:
    ///   - project: The `ResearchProjectModel` describing the project.
    ///   - config: The decoded `ResearchConfig` for the project.
    func run(project: ResearchProjectModel, config: ResearchConfig) {
        cancel()

        pipelineTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await self.executePipeline(project: project, config: config)
            } catch is CancellationError {
                self.publish(PipelineProgress(phase: .failed(PipelineError.cancelled),
                                             recordsDone: 0, totalRecords: 0))
            } catch {
                self.publish(PipelineProgress(phase: .failed(error),
                                             recordsDone: 0, totalRecords: 0))
            }
        }
    }

    /// Cancels a running pipeline.
    func cancel() {
        pipelineTask?.cancel()
        pipelineTask = nil
    }

    // MARK: - Pipeline execution

    private func executePipeline(project: ResearchProjectModel, config: ResearchConfig) async throws {
        guard let calcConfig = config.calculationConfig else {
            throw PipelineError.missingCalculationConfig
        }

        // ── Phase 1: Read input ──────────────────────────────────────────────
        publish(PipelineProgress(phase: .readingInput, recordsDone: 0, totalRecords: 0))

        let inputRecords: [ResearchInputRecord]
        do {
            let db = try ResearchDbManager(folderPath: project.path)
            inputRecords = try db.fetchAll()
        } catch {
            throw PipelineError.inputReadFailed(error)
        }

        let total = inputRecords.count
        guard total > 0 else {
            publish(PipelineProgress(phase: .completed, recordsDone: 0, totalRecords: 0))
            return
        }

        // ── Phase 2: Create results.bin ──────────────────────────────────────
        let binaryFile: ResultsBinaryFile
        do {
            binaryFile = try ResultsBinaryFile.create(
                at: project.path,
                config: config,
                recordCount: UInt64(total)
            )
            try binaryFile.openForWriting()
        } catch {
            throw PipelineError.binaryFileCreationFailed(error)
        }

        let factors = config.enabledFactors
        let seActor = SEActor()

        // ── Phase 3 + 4: Calculate and write ────────────────────────────────
        publish(PipelineProgress(phase: .calculating, recordsDone: 0, totalRecords: total))

        for (index, inputRecord) in inputRecords.enumerated() {
            try Task.checkCancellation()

            let chart = await seActor.calculate(
                input: inputRecord,
                factors: factors,
                calcConfig: calcConfig
            )

            do {
                try binaryFile.write(
                    recordId: inputRecord.id,
                    isData: inputRecord.isData,
                    at: index,
                    coordinates: chart.Coordinates,
                    config: config
                )
            } catch {
                binaryFile.closeForWriting()
                throw PipelineError.writeFailed(error)
            }

            publish(PipelineProgress(
                phase: .calculating,
                recordsDone: index + 1,
                totalRecords: total
            ))
        }

        // ── Phase 5: Complete ────────────────────────────────────────────────
        binaryFile.closeForWriting()

        publish(PipelineProgress(phase: .completed, recordsDone: total, totalRecords: total))
    }

    // MARK: - Progress helper

    /// Updates the published progress. Already on MainActor so direct assignment is safe.
    private func publish(_ newProgress: PipelineProgress) {
        self.progress = newProgress
    }
}
