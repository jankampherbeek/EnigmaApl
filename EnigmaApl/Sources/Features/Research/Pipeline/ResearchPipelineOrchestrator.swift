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
        lhs.recordsDone == rhs.recordsDone
            && lhs.totalRecords == rhs.totalRecords
            && lhs.phaseTag == rhs.phaseTag
    }
    /// String tag used for equality — avoids comparing associated values on `PipelinePhase`.
    private var phaseTag: String {
        switch phase {
        case .idle:           return "idle"
        case .readingInput:   return "readingInput"
        case .calculating:    return "calculating"
        case .writingResults: return "writingResults"
        case .completed:      return "completed"
        case .failed:         return "failed"
        }
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
/// 3. For each record: calculate via Swiss Ephemeris (runs off main actor)
/// 4. Write each result immediately into `results.bin`
/// 5. Publish `PipelineProgress` updates on the main actor (throttled)
/// 6. Honour `Task.isCancelled` between records
@MainActor
final class ResearchPipelineOrchestrator: ObservableObject {

    // MARK: - Published state

    @Published private(set) var progress = PipelineProgress(
        phase: .idle, recordsDone: 0, totalRecords: 0
    )

    // MARK: - Private state

    private var pipelineTask: Task<Void, Never>?

    // MARK: - Public API

    /// Starts the pipeline for the given project.
    /// Cancels any previously running pipeline first.
    /// The heavy computation runs in a detached background task;
    /// progress updates are marshalled back to the main actor.
    func run(project: ResearchProjectModel, config: ResearchConfig) {
        cancel()

        // Extract only Sendable values before crossing into the detached task
        let projectPath = project.path
        let configSnapshot = config

        // Publish "reading input" immediately
        self.progress = PipelineProgress(phase: .readingInput, recordsDone: 0, totalRecords: 0)

        pipelineTask = Task { [weak self] in
            guard let self else { return }
            await self.runDetached(path: projectPath, config: configSnapshot)
        }
    }

    /// Cancels a running pipeline.
    func cancel() {
        pipelineTask?.cancel()
        pipelineTask = nil
    }

    // MARK: - Internal

    /// Hops off the main actor into a detached task, then marshals final result back.
    private func runDetached(path: String, config: ResearchConfig) async {
        // nonisolated closure: all work runs on the cooperative thread pool, not main actor
        let finalProgress = await Task.detached(priority: .userInitiated) { [weak self] in
            await PipelineRunner.run(path: path, config: config, onProgress: { p in
                // Hop to main actor for each UI update
                await self?.publishOnMain(p)
            })
        }.value

        // Publish the final state (completed / failed) on the main actor
        self.progress = finalProgress
    }

    @MainActor
    private func publishOnMain(_ p: PipelineProgress) {
        self.progress = p
    }
}

// MARK: - Off-actor pipeline runner

/// Stateless namespace. Runs entirely off the main actor.
/// Calls `onProgress` for each throttled UI update; the callback marshals to main actor.
private enum PipelineRunner {

    typealias ProgressCallback = @Sendable (PipelineProgress) async -> Void

    static func run(
        path: String,
        config: ResearchConfig,
        onProgress: ProgressCallback
    ) async -> PipelineProgress {
        do {
            return try await execute(path: path, config: config, onProgress: onProgress)
        } catch is CancellationError {
            return PipelineProgress(phase: .failed(PipelineError.cancelled),
                                    recordsDone: 0, totalRecords: 0)
        } catch {
            return PipelineProgress(phase: .failed(error), recordsDone: 0, totalRecords: 0)
        }
    }

    private static func execute(
        path: String,
        config: ResearchConfig,
        onProgress: ProgressCallback
    ) async throws -> PipelineProgress {

        guard let calcConfig = config.calculationConfig else {
            throw PipelineError.missingCalculationConfig
        }

        // ── Phase 1: Read input ──────────────────────────────────────────────
        let inputRecords: [ResearchInputRecord]
        do {
            let db = try ResearchDbManager(folderPath: path)
            inputRecords = try db.fetchAll()
        } catch {
            throw PipelineError.inputReadFailed(error)
        }

        let total = inputRecords.count
        guard total > 0 else {
            return PipelineProgress(phase: .completed, recordsDone: 0, totalRecords: 0)
        }

        // ── Phase 2: Create results.bin ──────────────────────────────────────
        // Delete any stale results.bin from a previous run before creating the new one.
        let resultsBinURL = URL(fileURLWithPath: path, isDirectory: true)
            .appendingPathComponent("results.bin")
        try? FileManager.default.removeItem(at: resultsBinURL)

        let binaryFile: ResultsBinaryFile
        do {
            binaryFile = try ResultsBinaryFile.create(at: path, config: config,
                                                      recordCount: UInt64(total))
            try binaryFile.openForWriting()
        } catch {
            throw PipelineError.binaryFileCreationFailed(error)
        }

        let factors = config.enabledFactors
        let seActor = SEActor()

        // ── Phase 3 + 4: Calculate and write ────────────────────────────────
        await onProgress(PipelineProgress(phase: .calculating, recordsDone: 0, totalRecords: total))

        // Throttle UI updates to ~200 across the entire run
        let updateInterval = max(1, total / 200)
        var lastPublished = 0

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

            let done = index + 1
            if done - lastPublished >= updateInterval || done == total {
                lastPublished = done
                await onProgress(PipelineProgress(
                    phase: .calculating,
                    recordsDone: done,
                    totalRecords: total
                ))
            }
        }

        // ── Phase 5: Complete ────────────────────────────────────────────────
        binaryFile.closeForWriting()

        return PipelineProgress(phase: .completed, recordsDone: total, totalRecords: total)
    }
}
