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
        let finalProgress = await Task.detached(priority: .userInitiated) { [weak self] in
            await PipelineRunner.run(path: path, config: config, onProgress: { p in
                await MainActor.run { [weak self] in self?.progress = p }
            })
        }.value

        self.progress = finalProgress
    }

    @MainActor
    private func publishOnMain(_ p: PipelineProgress) {
        self.progress = p
    }
}

// MARK: - Off-actor pipeline runner

/// Stateless namespace. Runs entirely off the main actor.
/// Progress callbacks hop to the main actor via `MainActor.run`; the loop awaits each one,
/// guaranteeing SwiftUI sees every update (200 hops max for any practical dataset).
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

        // ── Phase 3 + 4: Serial calculation + write (libswe is not thread-safe) ─
        await onProgress(PipelineProgress(phase: .calculating, recordsDone: 0, totalRecords: total))

        let layouts    = config.factorLayouts
        let recordSize = config.recordSize

        // Pre-compute SE flags once — they are constant across all records.
        let eclFlags = SEFlags.defineFlags(calculationConfig: calcConfig, coordSystem: .ecliptical)
        let eqFlags  = SEFlags.defineFlags(calculationConfig: calcConfig, coordSystem: .equatorial)

        // Flags derived from config — evaluated once, used per-record.
        let isTopocentric = calcConfig.observerPosition == .topoCentric
        let isSidereal    = calcConfig.ayanamsha != .tropical

        let seWrapper = SEWrapper()

        // Sidereal mode does not change between records — set once.
        if isSidereal {
            seWrapper.setAyanamsha(idAyanamsha: calcConfig.ayanamsha.seId)
        }

        guard let handle = try? FileHandle(forWritingTo: resultsBinURL) else {
            throw PipelineError.binaryFileCreationFailed(
                ResultsBinaryFileError.cannotOpenFile(resultsBinURL.path))
        }
        defer { try? handle.close() }

        let updateInterval = max(100, total / 200)
        var lastPublished  = 0

        // Pre-allocate the byte buffer once and reuse it for every record.
        // Only the 16-byte prefix is zeroed each iteration; the data region
        // is always fully overwritten by the factor loop below.
        var bytes = [UInt8](repeating: 0, count: recordSize)

        let kRecordPrefix = 16
        let kBytesPerCoord = 40   // 5 Doubles × 8 bytes
        let kHeaderSize    = 256

        for (index, record) in inputRecords.enumerated() {
            try Task.checkCancellation()

            // ── Reset header (16 bytes) ───────────────────────────────────────
            for i in 0..<kRecordPrefix { bytes[i] = 0 }
            var rid = Int64(record.id).littleEndian
            withUnsafeMutableBytes(of: &rid) { bytes.replaceSubrange(0..<8, with: $0) }
            bytes[8] = record.isData ? 1 : 0

            // ── Julian Day ────────────────────────────────────────────────────
            let utHour = (Double(record.hour) + Double(record.minute) / 60.0
                         + Double(record.second) / 3600.0) - record.offset
            let date   = AstronomicalDate(Year: record.year, Month: record.month, Day: record.day)
            let julDay = seWrapper.julianDay(date: date, time: AstronomicalTime(HourDecimal: utHour))

            // Topocentric origin differs per chart — must be set every record.
            if isTopocentric {
                seWrapper.setTopocentric(geoLon: record.geoLon, geoLat: record.geoLat, height: 0)
            }

            // ── Per-factor calculation + write ────────────────────────────────
            var byteOffset = kRecordPrefix
            for layout in layouts {
                switch layout.factor.calculationType {

                case .CommonSe:
                    // Hot path: direct swe_calc_ut — no intermediate structs,
                    // no Dictionary lookups, no array allocations.
                    if layout.hasEcliptical {
                        if let pos = seWrapper.calculateFactorPosition(
                                julianDay: julDay,
                                factor: layout.factor.seId,
                                flags: eclFlags) {
                            byteOffset = writeCoordBytes(
                                pos.mainPos, pos.deviation, pos.distance,
                                pos.mainPosSpeed, pos.deviationSpeed,
                                into: &bytes, at: byteOffset)
                        } else { byteOffset += kBytesPerCoord }
                    }
                    if layout.hasEquatorial {
                        if let pos = seWrapper.calculateFactorPosition(
                                julianDay: julDay,
                                factor: layout.factor.seId,
                                flags: eqFlags) {
                            byteOffset = writeCoordBytes(
                                pos.mainPos, pos.deviation, pos.distance,
                                pos.mainPosSpeed, pos.deviationSpeed,
                                into: &bytes, at: byteOffset)
                        } else { byteOffset += kBytesPerCoord }
                    }

                // ── Future inquiry types: add cases here ──────────────────────
                // case .Apsides:
                //     // swe_nod_aps_ut — for BlackSun, Diamond
                // case .ZodiacFixed:
                //     // Always 0° longitude — write constant
                // case .CommonFormulaFull:
                //     // Priapus, Dragon, Beast, SouthNode — formula-based
                // case .Mundane:
                //     // Asc, MC, EastPoint, Vertex — requires house calculation
                // Fixed stars (future inquiry):
                //     // swe_fixstar2_ut — needs star name lookup table

                default:
                    // Not yet handled in the research pipeline.
                    // Bytes remain zero (buffer was pre-zeroed at header reset;
                    // data region carries zeros from the initial allocation for
                    // the first record, and from previous overwrite thereafter).
                    // Since layouts always cover the full data region, advancing
                    // past non-implemented types keeps the offset correct.
                    byteOffset += layout.byteSize
                }
            }

            // ── Write to file (pwrite: single syscall, no seek needed) ────────
            let fileOffset = off_t(kHeaderSize + index * recordSize)
            bytes.withUnsafeBytes { ptr in
                _ = Darwin.pwrite(handle.fileDescriptor,
                                  ptr.baseAddress!, recordSize,
                                  fileOffset)
            }

            let done = index + 1
            if done - lastPublished >= updateInterval || done == total {
                lastPublished = done
                let snapshot = PipelineProgress(
                    phase: .calculating, recordsDone: done, totalRecords: total)
                await onProgress(snapshot)
            }
        }

        return PipelineProgress(phase: .completed, recordsDone: total, totalRecords: total)
    }

    // MARK: - Byte-writing helper

    /// Writes five IEEE-754 little-endian doubles into `buf` starting at `offset`.
    /// Returns the next write position.
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

