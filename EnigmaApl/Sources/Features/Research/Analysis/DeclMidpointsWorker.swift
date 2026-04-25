// DeclMidpointsWorker.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Result types

/// Count of an occupied declination midpoint.
public struct DeclMidpointCount: Sendable {
    public let factorA: Factors
    public let factorB: Factors
    public let occupant: Factors
    public let dataCount: Int
    public let controlCount: Int
}

/// Full result of a `DeclMidpointsWorker` run.
public struct DeclMidpointsResult: Sendable {
    public let counts: [DeclMidpointCount]
    public let skippedRecords: Int
}

// MARK: - Errors

public enum DeclMidpointsWorkerError: Error {
    case equatorialNotEnabled
    case fileNotMapped
}

// MARK: - Worker

/// Reads `results.bin` and counts occupied midpoints in declination.
///
/// For each trio (A, B, C): midpoint of A and B in declination = (decl_A + decl_B) / 2.
/// C occupies the midpoint when |decl_C − midpoint| ≤ orb.
///
/// Unlike ecliptical midpoints there is no dial wrapping; declination is linear (−90…+90°).
public struct DeclMidpointsWorker {

    private let binaryFile: ResultsBinaryFile
    private let config: ResearchConfig
    private let orb: Double

    public init(binaryFile: ResultsBinaryFile, config: ResearchConfig, orb: Double) {
        self.binaryFile = binaryFile
        self.config = config
        self.orb = orb
    }

    public func run() throws -> DeclMidpointsResult {
        guard config.useEquatorial else { throw DeclMidpointsWorkerError.equatorialNotEnabled }

        let layouts = config.factorLayouts
        let recordCount = Int(binaryFile.recordCount)
        let n = layouts.count

        var dataCounts    = [TriKey: Int]()
        var controlCounts = [TriKey: Int]()
        var skipped = 0

        for position in 0..<recordCount {
            guard let (_, isData, regionData) = try? binaryFile.read(at: position) else {
                skipped += 1; continue
            }

            var declinations = [Double?](repeating: nil, count: n)
            for (fi, layout) in layouts.enumerated() {
                guard layout.hasEquatorial else { continue }
                let declOffset = layout.byteOffset + 8
                guard declOffset + 8 <= regionData.count else { continue }
                let raw = regionData.withUnsafeBytes {
                    $0.load(fromByteOffset: declOffset, as: UInt64.self).littleEndian
                }
                declinations[fi] = Double(bitPattern: raw)
            }

            for a in 0..<n {
                guard let dA = declinations[a] else { continue }
                for b in (a + 1)..<n {
                    guard let dB = declinations[b] else { continue }
                    let midpoint = (dA + dB) / 2.0
                    for c in 0..<n where c != a && c != b {
                        guard let dC = declinations[c] else { continue }
                        if abs(dC - midpoint) <= orb {
                            let key = TriKey(a, b, c)
                            if isData { dataCounts[key, default: 0] += 1 }
                            else       { controlCounts[key, default: 0] += 1 }
                        }
                    }
                }
            }
        }

        var counts: [DeclMidpointCount] = []
        for (key, dc) in dataCounts {
            counts.append(DeclMidpointCount(
                factorA: layouts[key.a].factor,
                factorB: layouts[key.b].factor,
                occupant: layouts[key.c].factor,
                dataCount: dc,
                controlCount: controlCounts[key, default: 0]
            ))
        }
        for (key, cc) in controlCounts where dataCounts[key] == nil {
            counts.append(DeclMidpointCount(
                factorA: layouts[key.a].factor,
                factorB: layouts[key.b].factor,
                occupant: layouts[key.c].factor,
                dataCount: 0,
                controlCount: cc
            ))
        }
        return DeclMidpointsResult(counts: counts.sorted { $0.factorA.rawValue < $1.factorA.rawValue },
                                   skippedRecords: skipped)
    }
}

private struct TriKey: Hashable {
    let a, b, c: Int
    init(_ a: Int, _ b: Int, _ c: Int) { self.a = a; self.b = b; self.c = c }
}
