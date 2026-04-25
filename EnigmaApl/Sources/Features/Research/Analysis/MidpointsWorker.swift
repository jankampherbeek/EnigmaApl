// MidpointsWorker.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Result types

/// Count of an occupied midpoint (factorA/factorB midpoint occupied by factorC).
public struct MidpointCount: Sendable {
    public let factorA: Factors
    public let factorB: Factors
    public let occupant: Factors
    public let dialSize: Int        // 360, 90, or 45
    public let dataCount: Int
    public let controlCount: Int
}

/// Full result of a `MidpointsWorker` run.
public struct MidpointsResult: Sendable {
    public let counts: [MidpointCount]
    public let skippedRecords: Int
}

// MARK: - Errors

public enum MidpointsWorkerError: Error {
    case eclipticalNotEnabled
    case fileNotMapped
    case noDialSizesConfigured
}

// MARK: - Worker

/// Reads `results.bin` and counts occupied midpoints on one or more dial sizes.
///
/// For a given dial `d` (360, 90, or 45): reduce all longitudes modulo `d`,
/// compute midpoint of factorA and factorB as `(lonA + lonB) / 2 mod d`,
/// then check if factorC's reduced longitude is within `orb` of that midpoint.
public struct MidpointsWorker {

    private let binaryFile: ResultsBinaryFile
    private let config: ResearchConfig
    private let dialSizes: [Int]
    private let orb: Double

    public init(binaryFile: ResultsBinaryFile, config: ResearchConfig,
                dialSizes: [Int], orb: Double) {
        self.binaryFile = binaryFile
        self.config = config
        self.dialSizes = dialSizes
        self.orb = orb
    }

    public func run() throws -> MidpointsResult {
        guard config.useEcliptical else { throw MidpointsWorkerError.eclipticalNotEnabled }
        guard !dialSizes.isEmpty   else { throw MidpointsWorkerError.noDialSizesConfigured }

        let layouts = config.factorLayouts
        let recordCount = Int(binaryFile.recordCount)
        let n = layouts.count

        // Key: (indexA, indexB, indexC, dialIndex) → (dataCount, controlCount)
        var dataCounts    = [FourKey: Int]()
        var controlCounts = [FourKey: Int]()
        var skipped = 0

        for position in 0..<recordCount {
            guard let (_, isData, regionData) = try? binaryFile.read(at: position) else {
                skipped += 1; continue
            }

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

            for (di, dial) in dialSizes.enumerated() {
                let d = Double(dial)
                for a in 0..<n {
                    guard let lonA = longitudes[a] else { continue }
                    let ra = lonA.truncatingRemainder(dividingBy: d)
                    for b in (a + 1)..<n {
                        guard let lonB = longitudes[b] else { continue }
                        let rb = lonB.truncatingRemainder(dividingBy: d)
                        let midpoint = ((ra + rb) / 2).truncatingRemainder(dividingBy: d)
                        for c in 0..<n where c != a && c != b {
                            guard let lonC = longitudes[c] else { continue }
                            let rc = lonC.truncatingRemainder(dividingBy: d)
                            let diff = min(abs(rc - midpoint), d - abs(rc - midpoint))
                            if diff <= orb {
                                let key = FourKey(a, b, c, di)
                                if isData { dataCounts[key, default: 0] += 1 }
                                else       { controlCounts[key, default: 0] += 1 }
                            }
                        }
                    }
                }
            }
        }

        var counts: [MidpointCount] = []
        for (key, dc) in dataCounts {
            let cc = controlCounts[key, default: 0]
            counts.append(MidpointCount(
                factorA: layouts[key.a].factor,
                factorB: layouts[key.b].factor,
                occupant: layouts[key.c].factor,
                dialSize: dialSizes[key.d],
                dataCount: dc,
                controlCount: cc
            ))
        }
        // Include entries that exist only in control counts
        for (key, cc) in controlCounts where dataCounts[key] == nil {
            counts.append(MidpointCount(
                factorA: layouts[key.a].factor,
                factorB: layouts[key.b].factor,
                occupant: layouts[key.c].factor,
                dialSize: dialSizes[key.d],
                dataCount: 0,
                controlCount: cc
            ))
        }
        return MidpointsResult(counts: counts.sorted { $0.factorA.rawValue < $1.factorA.rawValue },
                               skippedRecords: skipped)
    }
}

private struct FourKey: Hashable {
    let a, b, c, d: Int
    init(_ a: Int, _ b: Int, _ c: Int, _ d: Int) {
        self.a = a; self.b = b; self.c = c; self.d = d
    }
}
