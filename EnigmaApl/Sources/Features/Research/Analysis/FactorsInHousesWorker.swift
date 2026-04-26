// FactorsInHousesWorker.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Result types

/// Count of occurrences for one house, split by data group.
public struct HouseCount: Sendable {
    public let houseNr: Int          // 1-based
    public let dataCount: Int
    public let controlCount: Int
}

/// Analysis result for one factor: how many times it falls in each house.
public struct FactorHouseDistribution: Sendable {
    public let factor: Factors
    /// One entry per house, always `nrOfHouses` elements.
    public let houseCounts: [HouseCount]
    public var totalData: Int    { houseCounts.reduce(0) { $0 + $1.dataCount } }
    public var totalControl: Int { houseCounts.reduce(0) { $0 + $1.controlCount } }
}

/// Full result of a `FactorsInHousesWorker` run.
public struct FactorsInHousesResult: Sendable {
    public let distributions: [FactorHouseDistribution]
    public let nrOfHouses: Int
    public let skippedRecords: Int
}

// MARK: - Errors

public enum FactorsInHousesError: Error {
    case eclipticalNotEnabled
    case fileNotMapped
    case noCuspData
}

// MARK: - Worker

/// Reads `results.bin` (memory-mapped) and counts how many times each enabled factor
/// falls in each house, separately for real-data and control-group records.
///
/// House cusp longitudes are taken from the `FullCuspPosition` array stored on the
/// binary file's cusp supplement. Because the current binary format does not store
/// cusp data, this worker reads cusp longitudes from a parallel `[Double]` array
/// that the orchestrator must supply (derived from the calculation pipeline).
///
/// Requires ecliptical coordinates to be present in the binary file.
public struct FactorsInHousesWorker {

    private let binaryFile: ResultsBinaryFile
    private let config: ResearchConfig
    /// Cusp longitudes per record index — outer array indexed by record position,
    /// inner array indexed by cusp (0 = cusp 1, 11 = cusp 12 for a 12-house system).
    private let cuspLongitudesByRecord: [[Double]]

    public init(binaryFile: ResultsBinaryFile, config: ResearchConfig, cuspLongitudesByRecord: [[Double]]) {
        self.binaryFile = binaryFile
        self.config = config
        self.cuspLongitudesByRecord = cuspLongitudesByRecord
    }

    public func run() throws -> FactorsInHousesResult {
        guard config.useEcliptical else { throw FactorsInHousesError.eclipticalNotEnabled }

        let layouts = config.factorLayouts
        let recordCount = Int(binaryFile.recordCount)
        guard !cuspLongitudesByRecord.isEmpty else { throw FactorsInHousesError.noCuspData }
        let nrOfHouses = cuspLongitudesByRecord[0].count

        var dataCounts    = [[Int]](repeating: [Int](repeating: 0, count: nrOfHouses), count: layouts.count)
        var controlCounts = [[Int]](repeating: [Int](repeating: 0, count: nrOfHouses), count: layouts.count)
        var skipped = 0

        for position in 0..<recordCount {
            guard let (_, isData, regionData) = try? binaryFile.read(at: position) else {
                skipped += 1; continue
            }
            guard position < cuspLongitudesByRecord.count else { skipped += 1; continue }
            let cusps = cuspLongitudesByRecord[position]

            for (fi, layout) in layouts.enumerated() {
                guard layout.hasEcliptical else { continue }
                let byteOffset = layout.byteOffset
                guard let longitude = readDouble(from: regionData, at: byteOffset) else { skipped += 1; continue }
                var normalised = ((longitude.truncatingRemainder(dividingBy: 360)) + 360)
                    .truncatingRemainder(dividingBy: 360)
                // The Ascendant defines the 1st house cusp, so it must always land in house 1.
                // Floating-point rounding can store it as (cuspLongitude − ε), causing the
                // boundary check to fail and placing it in house 12 instead.
                // Adding 0.01 arc-second (≈ 0.0000028°) corrects this without any meaningful error.
                if layout.factor.seId == Factors.ascendant.seId {
                    let epsilon = 0.01 / 3600.0
                    normalised = ((normalised + epsilon).truncatingRemainder(dividingBy: 360) + 360)
                        .truncatingRemainder(dividingBy: 360)
                }

                let houseIndex = houseIndexFor(longitude: normalised, cusps: cusps)
                guard houseIndex >= 0 else { skipped += 1; continue }

                if isData { dataCounts[fi][houseIndex] += 1 }
                else       { controlCounts[fi][houseIndex] += 1 }
            }
        }

        let distributions: [FactorHouseDistribution] = layouts.enumerated().map { (fi, layout) in
            let houseCounts = (0..<nrOfHouses).map { hi in
                HouseCount(houseNr: hi + 1,
                           dataCount: dataCounts[fi][hi],
                           controlCount: controlCounts[fi][hi])
            }
            return FactorHouseDistribution(factor: layout.factor, houseCounts: houseCounts)
        }
        return FactorsInHousesResult(distributions: distributions, nrOfHouses: nrOfHouses, skippedRecords: skipped)
    }

    /// Returns the 0-based house index (0 = house 1) for the given longitude.
    /// Returns -1 if the longitude cannot be placed in any house.
    private func houseIndexFor(longitude: Double, cusps: [Double]) -> Int {
        let n = cusps.count
        for i in 0..<n {
            let first  = cusps[i]
            let second = cusps[(i + 1) % n]
            if first > second {
                // House spans the 0°/360° boundary
                if longitude >= first || longitude < second { return i }
            } else {
                if longitude >= first && longitude < second { return i }
            }
        }
        return -1
    }
}
