// HarmonicsWorker.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Result types

/// Count of a harmonic conjunction: radix factor A's harmonic position conjuncts radix factor B.
public struct HarmonicConjunctionCount: Sendable {
    public let harmonicFactor: Factors   // the factor whose harmonic was computed
    public let radixFactor: Factors      // the factor it conjuncts in the radix
    public let harmonicNumber: Int
    public let dataCount: Int
    public let controlCount: Int
}

/// Full result of a `HarmonicsWorker` run.
public struct HarmonicsResult: Sendable {
    public let counts: [HarmonicConjunctionCount]
    public let harmonicNumber: Int
    public let skippedRecords: Int
}

// MARK: - Errors

public enum HarmonicsWorkerError: Error {
    case eclipticalNotEnabled
    case fileNotMapped
}

// MARK: - Worker

/// For each record, multiplies every factor's longitude by `harmonicNumber` (mod 360)
/// and checks if the result is within `orb` of any other factor's radix longitude.
/// Counts matches per (harmonicFactor, radixFactor) pair.
public struct HarmonicsWorker {

    private let binaryFile: ResultsBinaryFile
    private let config: ResearchConfig
    private let harmonicNumber: Int
    private let orb: Double

    public init(binaryFile: ResultsBinaryFile, config: ResearchConfig,
                harmonicNumber: Int, orb: Double) {
        self.binaryFile = binaryFile
        self.config = config
        self.harmonicNumber = harmonicNumber
        self.orb = orb
    }

    public func run() throws -> HarmonicsResult {
        guard config.useEcliptical else { throw HarmonicsWorkerError.eclipticalNotEnabled }

        let layouts = config.factorLayouts
        let recordCount = Int(binaryFile.recordCount)
        let n = layouts.count
        let h = Double(harmonicNumber)

        // dataCounts[i][j] = harmonicFactor i conjuncts radixFactor j
        var dataCounts    = [[Int]](repeating: [Int](repeating: 0, count: n), count: n)
        var controlCounts = [[Int]](repeating: [Int](repeating: 0, count: n), count: n)
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

            for i in 0..<n {
                guard let lonI = longitudes[i] else { continue }
                let harmonicPos = (lonI * h).truncatingRemainder(dividingBy: 360)
                for j in 0..<n where j != i {
                    guard let lonJ = longitudes[j] else { continue }
                    let diff = abs(harmonicPos - lonJ).truncatingRemainder(dividingBy: 360)
                    let arc = diff > 180 ? 360 - diff : diff
                    if arc <= orb {
                        if isData { dataCounts[i][j] += 1 }
                        else       { controlCounts[i][j] += 1 }
                    }
                }
            }
        }

        var counts: [HarmonicConjunctionCount] = []
        for i in 0..<n {
            for j in 0..<n where j != i {
                let dc = dataCounts[i][j]
                let cc = controlCounts[i][j]
                if dc > 0 || cc > 0 {
                    counts.append(HarmonicConjunctionCount(
                        harmonicFactor: layouts[i].factor,
                        radixFactor: layouts[j].factor,
                        harmonicNumber: harmonicNumber,
                        dataCount: dc,
                        controlCount: cc
                    ))
                }
            }
        }
        return HarmonicsResult(counts: counts, harmonicNumber: harmonicNumber, skippedRecords: skipped)
    }
}
