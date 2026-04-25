// OobWorker.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Result types

/// Count of OOB occurrences for one factor.
public struct OobCount: Sendable {
    public let factor: Factors
    public let dataCount: Int
    public let controlCount: Int
}

/// Full result of an `OobWorker` run.
public struct OobResult: Sendable {
    public let counts: [OobCount]
    /// Maximum solar declination used as the OOB threshold.
    public let obliquity: Double
    public let skippedRecords: Int
}

// MARK: - Errors

public enum OobWorkerError: Error {
    case equatorialNotEnabled
    case fileNotMapped
}

// MARK: - Worker

/// Reads `results.bin` and counts how many times each factor's declination exceeds
/// the obliquity of the ecliptic (i.e. is Out Of Bounds).
///
/// The standard obliquity used is 23.4393° (mean value for the current epoch).
/// A factor is OOB when |declination| > obliquity.
public struct OobWorker {

    /// Mean obliquity of the ecliptic used as the OOB threshold.
    public static let defaultObliquity: Double = 23.4393

    private let binaryFile: ResultsBinaryFile
    private let config: ResearchConfig
    private let obliquity: Double

    public init(binaryFile: ResultsBinaryFile, config: ResearchConfig,
                obliquity: Double = OobWorker.defaultObliquity) {
        self.binaryFile = binaryFile
        self.config = config
        self.obliquity = obliquity
    }

    public func run() throws -> OobResult {
        guard config.useEquatorial else { throw OobWorkerError.equatorialNotEnabled }

        let layouts = config.factorLayouts
        let recordCount = Int(binaryFile.recordCount)
        let n = layouts.count

        var dataCounts    = [Int](repeating: 0, count: n)
        var controlCounts = [Int](repeating: 0, count: n)
        var skipped = 0

        for position in 0..<recordCount {
            guard let (_, isData, regionData) = try? binaryFile.read(at: position) else {
                skipped += 1; continue
            }

            for (fi, layout) in layouts.enumerated() {
                guard layout.hasEquatorial else { continue }
                // Declination is the second Double (offset +8) within the equatorial block
                let declOffset = layout.byteOffset + 8
                guard let declination = readDouble(from: regionData, at: declOffset) else { continue }
                if abs(declination) > obliquity {
                    if isData { dataCounts[fi] += 1 }
                    else       { controlCounts[fi] += 1 }
                }
            }
        }

        let counts = layouts.enumerated().map { (fi, layout) in
            OobCount(factor: layout.factor,
                     dataCount: dataCounts[fi],
                     controlCount: controlCounts[fi])
        }
        return OobResult(counts: counts, obliquity: obliquity, skippedRecords: skipped)
    }
}
