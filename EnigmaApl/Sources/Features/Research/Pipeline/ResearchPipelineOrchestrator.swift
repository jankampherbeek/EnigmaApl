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
/// 3. For each record: calculate via Swiss Ephemeris on real OS threads
/// 4. Write each result immediately into `results.bin`
/// 5. Publish `PipelineProgress` updates on the main actor (throttled)
/// 6. Honour cancellation between records
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
    /// The heavy computation runs on real OS threads via GCD;
    /// progress updates are marshalled back to the main actor.
    func run(project: ResearchProjectModel, config: ResearchConfig) {
        cancel()

        let projectPath = project.path
        let configSnapshot = config

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

    private func runDetached(path: String, config: ResearchConfig) async {
        // Build a sync progress callback that fires a lightweight main-actor task.
        // Creating a Task is ~µs — fine for throttled updates.
        let progressCallback: @Sendable (PipelineProgress) -> Void = { [weak self] p in
            Task { @MainActor [weak self] in
                self?.progress = p
            }
        }

        let finalProgress = await Task.detached(priority: .userInitiated) {
            await PipelineRunner.run(path: path, config: config, onProgress: progressCallback)
        }.value

        self.progress = finalProgress
    }
}

// MARK: - Off-actor pipeline runner

/// Stateless namespace. Runs entirely off the main actor.
/// Progress callbacks fire synchronously from worker threads; callers must dispatch to main as needed.
private enum PipelineRunner {

    typealias ProgressCallback = @Sendable (PipelineProgress) -> Void

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
        } catch let e as PipelineError {
            if case .cancelled = e {
                return PipelineProgress(phase: .failed(PipelineError.cancelled),
                                        recordsDone: 0, totalRecords: 0)
            }
            return PipelineProgress(phase: .failed(e), recordsDone: 0, totalRecords: 0)
        } catch {
            return PipelineProgress(phase: .failed(error), recordsDone: 0, totalRecords: 0)
        }
    }

    private static func execute(
        path: String,
        config: ResearchConfig,
        onProgress: @escaping ProgressCallback
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
        let resultsBinURL = URL(fileURLWithPath: path, isDirectory: true)
            .appendingPathComponent("results.bin")
        try? FileManager.default.removeItem(at: resultsBinURL)

        do {
            _ = try ResultsBinaryFile.create(at: path, config: config, recordCount: UInt64(total))
        } catch {
            throw PipelineError.binaryFileCreationFailed(error)
        }

        // ── Phase 3 + 4: Parallel calculation + write ────────────────────────
        onProgress(PipelineProgress(phase: .calculating, recordsDone: 0, totalRecords: total))

        let factors = config.enabledFactors
        let layouts = config.factorLayouts
        let recordSize = config.recordSize

        // Swiss Ephemeris (libswe) is not thread-safe — it uses global internal state.
        // All SE calls must be serialized on a single thread. We run the full loop in
        // Task.detached (off main actor) to keep the UI free, and fire lightweight
        // Task { @MainActor in } for throttled progress updates.
        let seWrapper = SEWrapper()
        guard let handle = try? FileHandle(forWritingTo: resultsBinURL) else {
            throw PipelineError.binaryFileCreationFailed(
                ResultsBinaryFileError.cannotOpenFile(resultsBinURL.path))
        }
        defer { try? handle.close() }

        let updateInterval = max(100, total / 200)
        var lastPublished = 0

        for (index, record) in inputRecords.enumerated() {
            try Task.checkCancellation()

            let chart = Self.calculateChart(
                record: record, factors: factors,
                calcConfig: calcConfig, seWrapper: seWrapper
            )

            try Self.writeRecord(
                chart: chart, record: record,
                at: index, recordSize: recordSize,
                layouts: layouts,
                handle: handle, fileURL: resultsBinURL
            )

            let done = index + 1
            if done - lastPublished >= updateInterval || done == total {
                lastPublished = done
                let snapshot = PipelineProgress(phase: .calculating, recordsDone: done, totalRecords: total)
                onProgress(snapshot)
            }
        }

        return PipelineProgress(phase: .completed, recordsDone: total, totalRecords: total)
    }

    // MARK: - Per-record helpers

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
        var bytes = [UInt8](repeating: 0, count: recordSize)

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

