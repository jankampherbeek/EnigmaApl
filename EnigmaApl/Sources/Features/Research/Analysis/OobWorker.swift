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
/// The actual obliquity is supplied per record (computed from Swiss Ephemeris using
/// factor id -1).  A factor is OOB when |declination| > obliquity + roundingMargin.
/// The rounding margin (1/100th of an arc-second) prevents the Sun from being
/// incorrectly flagged as OOB due to floating-point rounding at the solstice points.
public struct OobWorker {

    /// Rounding margin: 1 arc-second in degrees.
    /// Prevents the Sun (whose declination equals the obliquity at the solstices)
    /// from appearing as OOB due to floating-point rounding in the SE calculation.
    public static let roundingMargin: Double = 1.0 / 3_600.0   // 1" = ~2.78e-4°

    private let binaryFile: ResultsBinaryFile
    private let config: ResearchConfig
    /// True obliquity for each record, indexed by binary-file position.
    /// If shorter than the record count, the last value is reused for remaining records.
    private let obliquityPerRecord: [Double]

    public init(binaryFile: ResultsBinaryFile, config: ResearchConfig,
                obliquityPerRecord: [Double]) {
        self.binaryFile = binaryFile
        self.config = config
        self.obliquityPerRecord = obliquityPerRecord
    }

    public func run() throws -> OobResult {
        guard config.useEquatorial else { throw OobWorkerError.equatorialNotEnabled }

        let layouts = config.factorLayouts
        let recordCount = Int(binaryFile.recordCount)
        let n = layouts.count

        var dataCounts    = [Int](repeating: 0, count: n)
        var controlCounts = [Int](repeating: 0, count: n)
        var skipped = 0
        var obliquitySum = 0.0
        var obliquityCount = 0

        for position in 0..<recordCount {
            guard let (_, isData, regionData) = try? binaryFile.read(at: position) else {
                skipped += 1; continue
            }

            let obliquity = obliquityPerRecord.indices.contains(position)
                ? obliquityPerRecord[position]
                : (obliquityPerRecord.last ?? 23.4393)
            let threshold = obliquity + OobWorker.roundingMargin

            if isData {
                obliquitySum += obliquity
                obliquityCount += 1
            }

            for (fi, layout) in layouts.enumerated() {
                guard layout.hasEquatorial else { continue }
                // Declination is the second Double (offset +8) within the equatorial block
                let declOffset = layout.byteOffset + 8
                guard let declination = readDouble(from: regionData, at: declOffset) else { continue }
                if abs(declination) > threshold {
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
        let meanObliquity = obliquityCount > 0
            ? obliquitySum / Double(obliquityCount)
            : (obliquityPerRecord.first ?? 23.4393)
        return OobResult(counts: counts, obliquity: meanObliquity, skippedRecords: skipped)
    }
}
