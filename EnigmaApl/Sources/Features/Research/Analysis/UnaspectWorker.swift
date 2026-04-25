// UnaspectWorker.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Result types

/// Count of unaspected occurrences for one factor, split by data group.
public struct UnaspectCount: Sendable {
    public let factor: Factors
    public let dataCount: Int
    public let controlCount: Int
}

/// Full result of an `UnaspectWorker` run.
public struct UnaspectResult: Sendable {
    public let counts: [UnaspectCount]
    public let skippedRecords: Int
}

// MARK: - Errors

public enum UnaspectWorkerError: Error {
    case eclipticalNotEnabled
    case fileNotMapped
    case noAspectsConfigured
}

// MARK: - Worker

/// Reads `results.bin` and counts how many times each enabled factor is unaspected —
/// i.e. forms no aspect (within orb) with any other enabled factor — separately for
/// real-data and control-group records.
public struct UnaspectWorker {

    private let binaryFile: ResultsBinaryFile
    private let config: ResearchConfig
    private let aspectAngles: [Double]
    private let orb: Double

    public init(binaryFile: ResultsBinaryFile, config: ResearchConfig,
                aspectAngles: [Double], orb: Double) {
        self.binaryFile = binaryFile
        self.config = config
        self.aspectAngles = aspectAngles
        self.orb = orb
    }

    public func run() throws -> UnaspectResult {
        guard config.useEcliptical else { throw UnaspectWorkerError.eclipticalNotEnabled }
        guard !aspectAngles.isEmpty else { throw UnaspectWorkerError.noAspectsConfigured }

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

            var longitudes = [Double?](repeating: nil, count: n)
            for (fi, layout) in layouts.enumerated() {
                guard layout.hasEcliptical else { continue }
                guard let lon = readDouble(from: regionData, at: layout.byteOffset) else { continue }
                longitudes[fi] = ((lon.truncatingRemainder(dividingBy: 360)) + 360)
                    .truncatingRemainder(dividingBy: 360)
            }

            for i in 0..<n {
                guard let lonI = longitudes[i] else { continue }
                let isUnaspected = !layouts.indices.contains { j in
                    guard j != i, let lonJ = longitudes[j] else { return false }
                    let arc = shortestArc(lonI, lonJ)
                    return aspectAngles.contains { abs(arc - $0) <= orb }
                }
                if isUnaspected {
                    if isData { dataCounts[i] += 1 }
                    else       { controlCounts[i] += 1 }
                }
            }
        }

        let counts = layouts.enumerated().map { (fi, layout) in
            UnaspectCount(factor: layout.factor,
                          dataCount: dataCounts[fi],
                          controlCount: controlCounts[fi])
        }
        return UnaspectResult(counts: counts, skippedRecords: skipped)
    }

    private func shortestArc(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 360)
        return diff > 180 ? 360 - diff : diff
    }
}
