// ParallelsWorker.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Result types

/// Count of a parallel or contra-parallel between two factors.
public struct ParallelCount: Sendable {
    public let factor1: Factors
    public let factor2: Factors
    public let isContraParallel: Bool  // false = parallel, true = contra-parallel
    public let dataCount: Int
    public let controlCount: Int
}

/// Full result of a `ParallelsWorker` run.
public struct ParallelsResult: Sendable {
    public let counts: [ParallelCount]
    public let skippedRecords: Int
}

// MARK: - Errors

public enum ParallelsWorkerError: Error {
    case equatorialNotEnabled
    case fileNotMapped
}

// MARK: - Worker

/// Reads `results.bin` and counts declination parallels and contra-parallels.
///
/// - **Parallel**: |decl_A − decl_B| ≤ orb  (same direction)
/// - **Contra-parallel**: |decl_A + decl_B| ≤ orb  (opposite directions)
///
/// Declination is the second Double in the equatorial block (index 1, byte offset 8
/// within the equatorial region). The equatorial block starts at the factor's
/// `byteOffset` (which is the beginning of its entire data region block).
/// Within that block the layout is: mainPos (lon, 8B), deviation (decl, 8B),
/// distance (8B), speedMain (8B), speedDeviation (8B).
public struct ParallelsWorker {

    private let binaryFile: ResultsBinaryFile
    private let config: ResearchConfig
    private let orb: Double

    public init(binaryFile: ResultsBinaryFile, config: ResearchConfig, orb: Double) {
        self.binaryFile = binaryFile
        self.config = config
        self.orb = orb
    }

    public func run() throws -> ParallelsResult {
        guard config.useEquatorial else { throw ParallelsWorkerError.equatorialNotEnabled }

        let layouts = config.factorLayouts
        let recordCount = Int(binaryFile.recordCount)
        let n = layouts.count

        // dataCounts[i][j][0] = parallel, [i][j][1] = contra-parallel (i < j)
        var dataCounts    = [[[Int]]](repeating: [[Int]](repeating: [Int](repeating: 0, count: 2), count: n), count: n)
        var controlCounts = [[[Int]]](repeating: [[Int]](repeating: [Int](repeating: 0, count: 2), count: n), count: n)
        var skipped = 0

        for position in 0..<recordCount {
            guard let (_, isData, regionData) = try? binaryFile.read(at: position) else {
                skipped += 1; continue
            }

            var declinations = [Double?](repeating: nil, count: n)
            for (fi, layout) in layouts.enumerated() {
                guard layout.hasEquatorial else { continue }
                // Equatorial block starts at byteOffset; declination is at offset + 8
                let declOffset = layout.byteOffset + 8
                declinations[fi] = readDouble(from: regionData, at: declOffset)
            }

            for i in 0..<n {
                guard let decl_i = declinations[i] else { continue }
                for j in (i + 1)..<n {
                    guard let decl_j = declinations[j] else { continue }
                    if abs(decl_i - decl_j) <= orb {
                        if isData { dataCounts[i][j][0] += 1 }
                        else       { controlCounts[i][j][0] += 1 }
                    }
                    if abs(decl_i + decl_j) <= orb {
                        if isData { dataCounts[i][j][1] += 1 }
                        else       { controlCounts[i][j][1] += 1 }
                    }
                }
            }
        }

        var counts: [ParallelCount] = []
        for i in 0..<n {
            for j in (i + 1)..<n {
                for k in 0..<2 {
                    let dc = dataCounts[i][j][k]
                    let cc = controlCounts[i][j][k]
                    if dc > 0 || cc > 0 {
                        counts.append(ParallelCount(
                            factor1: layouts[i].factor,
                            factor2: layouts[j].factor,
                            isContraParallel: k == 1,
                            dataCount: dc,
                            controlCount: cc
                        ))
                    }
                }
            }
        }
        return ParallelsResult(counts: counts, skippedRecords: skipped)
    }
}
