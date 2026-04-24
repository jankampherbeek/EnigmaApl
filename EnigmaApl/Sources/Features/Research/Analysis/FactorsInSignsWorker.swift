// FactorsInSignsWorker.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Result types

/// Count of occurrences for one sign, split by data group.
public struct SignCount: Sendable {
    public let sign: Signs
    /// Count in the real-data group.
    public let dataCount: Int
    /// Count in the control-group.
    public let controlCount: Int
}

/// Analysis result for one factor: how many times it falls in each sign,
/// separately for real data and control group.
public struct FactorSignDistribution: Sendable {
    public let factor: Factors
    /// One entry per sign (Aries … Pisces), always 12 elements.
    public let signCounts: [SignCount]

    /// Total records in the real-data group for this factor.
    public var totalData: Int { signCounts.reduce(0) { $0 + $1.dataCount } }
    /// Total records in the control group for this factor.
    public var totalControl: Int { signCounts.reduce(0) { $0 + $1.controlCount } }
}

/// Full result of a `FactorsInSignsWorker` run.
public struct FactorsInSignsResult: Sendable {
    /// One distribution per factor in the order they appear in the config.
    public let distributions: [FactorSignDistribution]
    /// Number of records that were skipped (e.g. ecliptical data absent).
    public let skippedRecords: Int
}

// MARK: - Errors

public enum FactorsInSignsError: Error {
    /// The config does not include ecliptical coordinates, which are required for sign positions.
    case eclipticalNotEnabled
    /// The binary file has not been memory-mapped yet.
    case fileNotMapped
}

// MARK: - Worker

/// Reads `results.bin` (memory-mapped) and counts how many times each enabled factor
/// falls in each zodiac sign, separately for real-data records and control-group records.
///
/// Requires ecliptical coordinates to be present in the binary file.
/// Runs synchronously — call from a background `Task` to keep the UI responsive.
///
/// Usage:
/// ```swift
/// let worker = FactorsInSignsWorker(binaryFile: file, config: config)
/// let result = try worker.run()
/// ```
public struct FactorsInSignsWorker {

    private let binaryFile: ResultsBinaryFile
    private let config: ResearchConfig

    public init(binaryFile: ResultsBinaryFile, config: ResearchConfig) {
        self.binaryFile = binaryFile
        self.config = config
    }

    /// Performs the analysis and returns sign-distribution tallies.
    /// - Throws: `FactorsInSignsError.eclipticalNotEnabled` if the config has no ecliptical data.
    public func run() throws -> FactorsInSignsResult {
        guard config.useEcliptical else {
            throw FactorsInSignsError.eclipticalNotEnabled
        }

        let layouts = config.factorLayouts
        let recordCount = Int(binaryFile.recordCount)

        // Accumulators: [factorIndex][signIndex 0-11] → (dataCount, controlCount)
        let factorCount = layouts.count
        var dataCounts    = [[Int]](repeating: [Int](repeating: 0, count: 12), count: factorCount)
        var controlCounts = [[Int]](repeating: [Int](repeating: 0, count: 12), count: factorCount)
        var skipped = 0

        for position in 0..<recordCount {
            guard let (_, isData, regionData) = try? binaryFile.read(at: position) else {
                skipped += 1
                continue
            }

            for (factorIndex, layout) in layouts.enumerated() {
                guard layout.hasEcliptical else { continue }

                // mainPos (longitude) is the first Double in the ecliptical block,
                // which is the first block in the factor's data region.
                let byteOffset = layout.byteOffset  // offset within the data region
                guard byteOffset + 8 <= regionData.count else {
                    skipped += 1
                    continue
                }

                let longitude = regionData.withUnsafeBytes { ptr in
                    ptr.load(fromByteOffset: byteOffset, as: UInt64.self).littleEndian
                }
                let lonDouble = Double(bitPattern: longitude)

                // Normalise to 0 ..< 360 (guard against tiny negatives from rounding)
                let normalised = ((lonDouble.truncatingRemainder(dividingBy: 360)) + 360)
                    .truncatingRemainder(dividingBy: 360)
                let signIndex = min(Int(normalised / 30.0), 11)   // 0 = Aries … 11 = Pisces

                if isData {
                    dataCounts[factorIndex][signIndex] += 1
                } else {
                    controlCounts[factorIndex][signIndex] += 1
                }
            }
        }

        // Build result
        let distributions: [FactorSignDistribution] = layouts.enumerated().map { (fi, layout) in
            let signCounts: [SignCount] = (0..<12).map { si in
                // Signs.rawValue is 1-based (Aries = 1)
                let sign = Signs(rawValue: si + 1)!
                return SignCount(
                    sign: sign,
                    dataCount: dataCounts[fi][si],
                    controlCount: controlCounts[fi][si]
                )
            }
            return FactorSignDistribution(factor: layout.factor, signCounts: signCounts)
        }

        return FactorsInSignsResult(distributions: distributions, skippedRecords: skipped)
    }
}
