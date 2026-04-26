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
        onProgress: @escaping ProgressCallback
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
        onProgress: @escaping ProgressCallback
    ) async throws -> PipelineProgress {

        // Pre-decode once — config.calculationConfig decodes JSON on every call
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

        // ── Phase 2: Create results.bin (pre-allocated, fixed-offset records) ─
        let resultsBinURL = URL(fileURLWithPath: path, isDirectory: true)
            .appendingPathComponent("results.bin")
        try? FileManager.default.removeItem(at: resultsBinURL)

        do {
            // Create + close immediately — workers each open their own FileHandle
            let binaryFile = try ResultsBinaryFile.create(at: path, config: config,
                                                          recordCount: UInt64(total))
            // Just verify it was created; workers will write via their own handles
            _ = binaryFile
        } catch {
            throw PipelineError.binaryFileCreationFailed(error)
        }

        // ── Phase 3 + 4: Parallel calculation + write ────────────────────────
        await onProgress(PipelineProgress(phase: .calculating, recordsDone: 0, totalRecords: total))

        // Pre-compute layout once; workers capture the snapshot
        let factors = config.enabledFactors
        let layouts = config.factorLayouts
        let recordSize = config.recordSize

        // Counter shared across workers for throttled progress reporting
        let counter = ProgressCounter(total: total)

        // Number of parallel workers = number of active CPU cores (capped at record count)
        let coreCount = max(1, ProcessInfo.processInfo.activeProcessorCount)
        let workerCount = min(coreCount, total)
        let sliceSize = (total + workerCount - 1) / workerCount   // ceiling division

        try await withThrowingTaskGroup(of: Void.self) { group in
            for w in 0..<workerCount {
                let start = w * sliceSize
                let end   = min(start + sliceSize, total)
                guard start < end else { continue }

                let slice = Array(inputRecords[start..<end])
                let sliceStart = start

                group.addTask {
                    try Task.checkCancellation()
                    // Each worker owns its own SEWrapper — no actor serialisation
                    let seWrapper = SEWrapper()
                    guard let handle = try? FileHandle(forWritingTo: resultsBinURL) else {
                        throw PipelineError.binaryFileCreationFailed(
                            ResultsBinaryFileError.cannotOpenFile(resultsBinURL.path))
                    }
                    defer { try? handle.close() }

                    for (localIndex, record) in slice.enumerated() {
                        try Task.checkCancellation()

                        let chart = Self.calculateChart(
                            record: record, factors: factors,
                            calcConfig: calcConfig, seWrapper: seWrapper
                        )

                        let globalIndex = sliceStart + localIndex
                        try Self.writeRecord(
                            chart: chart, record: record,
                            at: globalIndex, recordSize: recordSize,
                            layouts: layouts,
                            handle: handle, fileURL: resultsBinURL
                        )

                        await counter.increment(onProgress: onProgress)
                    }
                }
            }
            try await group.waitForAll()
        }

        return PipelineProgress(phase: .completed, recordsDone: total, totalRecords: total)
    }

    // MARK: - Per-record helpers (nonisolated, no allocation of CalcRequest inside actor)

    private static func calculateChart(
        record: ResearchInputRecord,
        factors: [Factors],
        calcConfig: CalculationConfig,
        seWrapper: SEWrapper
    ) -> FullChart {
        let localDecimal = Double(record.hour) + Double(record.minute) / 60.0 + Double(record.second) / 3600.0
        let utHour = localDecimal - record.offset
        let date = AstronomicalDate(Year: record.year, Month: record.month, Day: record.day)
        let time = AstronomicalTime(HourDecimal: utHour)
        let julDay = seWrapper.julianDay(date: date, time: time)

        let request = CalcRequest(
            JulianDay: julDay,
            FactorsToUse: factors,
            HouseSystem: calcConfig.houseSystem.rawValue,
            Latitude: record.geoLat,
            Longitude: record.geoLon,
            Height: 0,
            calculationConfig: calcConfig
        )
        return AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
    }

    private static func writeRecord(
        chart: FullChart,
        record: ResearchInputRecord,
        at position: Int,
        recordSize: Int,
        layouts: [FactorLayout],
        handle: FileHandle,
        fileURL: URL
    ) throws {
        // Build the raw record bytes inline (avoids ResultsBinaryFile.write overhead
        // of opening/closing the handle and the per-call seek overhead being serialised)
        var bytes = [UInt8](repeating: 0, count: recordSize)

        // Prefix: recordId (Int64 LE) at 0, isData at 8, 7 pad bytes
        var rid = Int64(record.id).littleEndian
        withUnsafeMutableBytes(of: &rid) { bytes.replaceSubrange(0..<8, with: $0) }
        bytes[8] = record.isData ? 1 : 0

        let kRecordPrefix = 16
        let kBytesPerCoord = 40   // 5 Doubles × 8

        var byteOffset = kRecordPrefix
        for layout in layouts {
            guard let pos = chart.Coordinates[layout.factor] else {
                byteOffset += layout.byteSize; continue
            }
            if layout.hasEcliptical {
                if let ecl = pos.ecliptical.first {
                    byteOffset = writeCoordBytes(ecl.mainPos, ecl.deviation, ecl.distance,
                                                  ecl.mainPosSpeed, ecl.deviationSpeed,
                                                  into: &bytes, at: byteOffset)
                } else { byteOffset += kBytesPerCoord }
            }
            if layout.hasEquatorial {
                if let eq = pos.equatorial.first {
                    byteOffset = writeCoordBytes(eq.mainPos, eq.deviation, eq.distance,
                                                  eq.mainPosSpeed, eq.deviationSpeed,
                                                  into: &bytes, at: byteOffset)
                } else { byteOffset += kBytesPerCoord }
            }
        }

        let kHeaderSize = 256
        let fileOffset = UInt64(kHeaderSize + position * recordSize)
        try handle.seek(toOffset: fileOffset)
        handle.write(Data(bytes))
    }

    @inline(__always)
    private static func writeCoordBytes(
        _ v0: Double, _ v1: Double, _ v2: Double, _ v3: Double, _ v4: Double,
        into buf: inout [UInt8], at offset: Int
    ) -> Int {
        var o = offset
        for v in [v0, v1, v2, v3, v4] {
            var le = v.bitPattern.littleEndian
            withUnsafeMutableBytes(of: &le) { buf.replaceSubrange(o..<o+8, with: $0) }
            o += 8
        }
        return o
    }
}

// MARK: - Shared atomic progress counter

/// Tracks records completed across all parallel workers and fires throttled progress callbacks.
private actor ProgressCounter {
    private let total: Int
    private let updateInterval: Int
    private var done: Int = 0
    private var lastPublished: Int = 0

    init(total: Int) {
        self.total = total
        self.updateInterval = max(100, total / 200)
    }

    func increment(onProgress: PipelineRunner.ProgressCallback) async {
        done += 1
        if done - lastPublished >= updateInterval || done == total {
            lastPublished = done
            await onProgress(PipelineProgress(phase: .calculating, recordsDone: done, totalRecords: total))
        }
    }
}
