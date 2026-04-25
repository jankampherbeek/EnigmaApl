// AspectsWorker.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Result types

/// Count of a specific aspect between two factors, split by data group.
public struct AspectCount: Sendable {
    public let factor1: Factors
    public let factor2: Factors
    public let aspectAngle: Double    // e.g. 0, 60, 90, 120, 180
    public let dataCount: Int
    public let controlCount: Int
}

/// Full result of an `AspectsWorker` run.
public struct AspectsResult: Sendable {
    public let counts: [AspectCount]
    public let skippedRecords: Int
}

// MARK: - Errors

public enum AspectsWorkerError: Error {
    case eclipticalNotEnabled
    case fileNotMapped
    case noAspectsConfigured
}

// MARK: - Worker

/// Reads `results.bin` and counts how many times each enabled factor pair forms
/// each enabled aspect, separately for real-data and control-group records.
///
/// An aspect is detected when the shortest arc between two longitudes differs from
/// the aspect angle by no more than `orb` degrees.
public struct AspectsWorker {

    private let binaryFile: ResultsBinaryFile
    private let config: ResearchConfig
    /// Aspect angles (degrees) to test, e.g. [0, 60, 90, 120, 180].
    private let aspectAngles: [Double]
    /// Maximum allowed deviation from the exact aspect angle.
    private let orb: Double

    public init(binaryFile: ResultsBinaryFile, config: ResearchConfig,
                aspectAngles: [Double], orb: Double) {
        self.binaryFile = binaryFile
        self.config = config
        self.aspectAngles = aspectAngles
        self.orb = orb
    }

    public func run() throws -> AspectsResult {
        guard config.useEcliptical else { throw AspectsWorkerError.eclipticalNotEnabled }
        guard !aspectAngles.isEmpty else { throw AspectsWorkerError.noAspectsConfigured }

        let layouts = config.factorLayouts
        let recordCount = Int(binaryFile.recordCount)
        let n = layouts.count
        let m = aspectAngles.count

        // dataCounts[i][j][k] = count for factor i, factor j, aspect k (real data)
        var dataCounts    = [[[Int]]](repeating: [[Int]](repeating: [Int](repeating: 0, count: m), count: n), count: n)
        var controlCounts = [[[Int]]](repeating: [[Int]](repeating: [Int](repeating: 0, count: m), count: n), count: n)
        var skipped = 0

        for position in 0..<recordCount {
            guard let (_, isData, regionData) = try? binaryFile.read(at: position) else {
                skipped += 1; continue
            }

            // Read all longitudes for this record
            var longitudes = [Double?](repeating: nil, count: n)
            for (fi, layout) in layouts.enumerated() {
                guard layout.hasEcliptical, layout.byteOffset + 8 <= regionData.count else { continue }
                let raw = regionData.withUnsafeBytes {
                    $0.load(fromByteOffset: layout.byteOffset, as: UInt64.self).littleEndian
                }
                let lon = Double(bitPattern: raw)
                longitudes[fi] = ((lon.truncatingRemainder(dividingBy: 360)) + 360)
                    .truncatingRemainder(dividingBy: 360)
            }

            // Check every ordered pair (i, j) where i < j
            for i in 0..<n {
                guard let lonI = longitudes[i] else { continue }
                for j in (i + 1)..<n {
                    guard let lonJ = longitudes[j] else { continue }
                    let arc = shortestArc(lonI, lonJ)
                    for (k, angle) in aspectAngles.enumerated() {
                        if abs(arc - angle) <= orb {
                            if isData {
                                dataCounts[i][j][k] += 1
                            } else {
                                controlCounts[i][j][k] += 1
                            }
                        }
                    }
                }
            }
        }

        // Flatten to AspectCount array
        var counts: [AspectCount] = []
        for i in 0..<n {
            for j in (i + 1)..<n {
                for (k, angle) in aspectAngles.enumerated() {
                    let dc = dataCounts[i][j][k]
                    let cc = controlCounts[i][j][k]
                    if dc > 0 || cc > 0 {
                        counts.append(AspectCount(
                            factor1: layouts[i].factor,
                            factor2: layouts[j].factor,
                            aspectAngle: angle,
                            dataCount: dc,
                            controlCount: cc
                        ))
                    }
                }
            }
        }
        return AspectsResult(counts: counts, skippedRecords: skipped)
    }

    /// Shortest arc between two longitudes (0…180°).
    private func shortestArc(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 360)
        return diff > 180 ? 360 - diff : diff
    }
}
