// EnneagramCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates enneagram type strengths and detail lines from chart positions.
/// Ported from Enigma.Core.Slices.Enneagram.EnneagramCalc and EnneagramDetails.
struct EnneagramCalculator {

    private init() {}

    // MARK: - Factor → CSV point ID mapping

    /// Maps Swift Factors enum values to the point IDs used in the enneagram CSV data.
    static let factorToPointId: [Factors: Int] = [
        .sun: 0, .moon: 1, .mercury: 2, .venus: 3,
        .mars: 5, .jupiter: 6, .saturn: 7, .uranus: 8,
        .neptune: 9, .pluto: 10,
        .northNode: 12,   // True Node in the CSV
        .chiron: 13,
        .apogeeMean: 43
    ]

    // MARK: - Strength calculation

    /// Returns the 9 enneagram type strengths, sorted highest-first.
    static func calculateStrengths(
        signs: [Int: [Double]],
        houses: [Int: [Double]],
        factorPositions: [(Factors, Double)],
        cuspLongitudes: [Double],  // index 0 unused, [1] = cusp 1 … [12] = cusp 12
        useHouses: Bool,
        doublePluto: Bool
    ) -> [EnneagramTypeResult] {
        var typeAccumulators: [[Double]] = Array(repeating: [], count: 10)  // index 1..9

        // Factors in signs
        for (factor, longitude) in factorPositions {
            guard let pointId = factorToPointId[factor] else { continue }
            let sign = signIndex(longitude)
            if let vals = lookup(signs, point: pointId, index: sign) {
                accumulate(&typeAccumulators, vals)
                if doublePluto && factor == .pluto { accumulate(&typeAccumulators, vals) }
            }
        }

        if useHouses && cuspLongitudes.count >= 13 {
            // Factors in houses
            for (factor, longitude) in factorPositions {
                guard let pointId = factorToPointId[factor] else { continue }
                let house = houseIndex(longitude, cusps: cuspLongitudes)
                if let vals = lookup(houses, point: pointId, index: house) {
                    accumulate(&typeAccumulators, vals)
                    if doublePluto && factor == .pluto { accumulate(&typeAccumulators, vals) }
                }
            }

            // Ascendant in sign
            let ascLong = cuspLongitudes[1]
            if let vals = lookup(signs, point: 1001, index: signIndex(ascLong)) {
                accumulate(&typeAccumulators, vals)
            }
            // Ascendant in house
            if let vals = lookup(houses, point: 1001, index: houseIndex(ascLong, cusps: cuspLongitudes)) {
                accumulate(&typeAccumulators, vals)
            }

            // MC in sign
            let mcLong = cuspLongitudes[10]
            if let vals = lookup(signs, point: 1002, index: signIndex(mcLong)) {
                accumulate(&typeAccumulators, vals)
            }
            // MC in house
            if let vals = lookup(houses, point: 1002, index: houseIndex(mcLong, cusps: cuspLongitudes)) {
                accumulate(&typeAccumulators, vals)
            }

            // Cusps in signs (2001-2012) — all 1.0 in original data, so no net effect, still processed for correctness
            for cuspIdx in 1...12 {
                let cuspLong = cuspLongitudes[cuspIdx]
                let cuspSign = signIndex(cuspLong)
                if let vals = lookup(houses, point: 2000 + cuspIdx, index: cuspSign) {
                    accumulate(&typeAccumulators, vals)
                }
            }
        }

        var results: [EnneagramTypeResult] = []
        for t in 1...9 {
            let strength = typeAccumulators[t].reduce(1.0, *)
            results.append(EnneagramTypeResult(type: t, strength: strength))
        }
        return results.sorted { $0.strength > $1.strength }
    }

    // MARK: - Details calculation

    /// Returns one detail line per factor/position combination (for the Details tab).
    static func calculateDetails(
        signs: [Int: [Double]],
        houses: [Int: [Double]],
        factorPositions: [(Factors, Double)],
        cuspLongitudes: [Double],
        useHouses: Bool,
        doublePluto: Bool
    ) -> [EnneagramDetailLine] {
        var result: [EnneagramDetailLine] = []

        // Factors in signs
        for (factor, longitude) in factorPositions {
            guard let pointId = factorToPointId[factor] else { continue }
            let sign = signIndex(longitude)
            if let vals = lookup(signs, point: pointId, index: sign) {
                result.append(EnneagramDetailLine(factor: factor, specialLabel: "", positionIndex: sign, inSigns: true, typeValues: vals))
                if doublePluto && factor == .pluto {
                    result.append(EnneagramDetailLine(factor: factor, specialLabel: "", positionIndex: sign, inSigns: true, typeValues: vals))
                }
            }
        }

        if useHouses && cuspLongitudes.count >= 13 {
            // Ascendant in sign
            let ascLong = cuspLongitudes[1]
            if let vals = lookup(signs, point: 1001, index: signIndex(ascLong)) {
                result.append(EnneagramDetailLine(factor: nil, specialLabel: "ASC", positionIndex: signIndex(ascLong), inSigns: true, typeValues: vals))
            }
            // MC in sign
            let mcLong = cuspLongitudes[10]
            if let vals = lookup(signs, point: 1002, index: signIndex(mcLong)) {
                result.append(EnneagramDetailLine(factor: nil, specialLabel: "MC", positionIndex: signIndex(mcLong), inSigns: true, typeValues: vals))
            }

            // Factors in houses
            for (factor, longitude) in factorPositions {
                guard let pointId = factorToPointId[factor] else { continue }
                let house = houseIndex(longitude, cusps: cuspLongitudes)
                if let vals = lookup(houses, point: pointId, index: house) {
                    result.append(EnneagramDetailLine(factor: factor, specialLabel: "", positionIndex: house, inSigns: false, typeValues: vals))
                    if doublePluto && factor == .pluto {
                        result.append(EnneagramDetailLine(factor: factor, specialLabel: "", positionIndex: house, inSigns: false, typeValues: vals))
                    }
                }
            }

            // Ascendant in house
            if let vals = lookup(houses, point: 1001, index: houseIndex(ascLong, cusps: cuspLongitudes)) {
                result.append(EnneagramDetailLine(factor: nil, specialLabel: "ASC", positionIndex: houseIndex(ascLong, cusps: cuspLongitudes), inSigns: false, typeValues: vals))
            }
            // MC in house
            if let vals = lookup(houses, point: 1002, index: houseIndex(mcLong, cusps: cuspLongitudes)) {
                result.append(EnneagramDetailLine(factor: nil, specialLabel: "MC", positionIndex: houseIndex(mcLong, cusps: cuspLongitudes), inSigns: false, typeValues: vals))
            }
        }

        return result
    }

    // MARK: - Private helpers

    private static func accumulate(_ acc: inout [[Double]], _ vals: [Double]) {
        for t in 1...9 {
            if t - 1 < vals.count { acc[t].append(vals[t - 1]) }
        }
    }

    private static func lookup(_ table: [Int: [Double]], point: Int, index: Int) -> [Double]? {
        table[point * 100 + index]
    }

    static func signIndex(_ longitude: Double) -> Int {
        var l = longitude.truncatingRemainder(dividingBy: 360.0)
        if l < 0 { l += 360.0 }
        let s = Int(l / 30.0) + 1
        return max(1, min(12, s))
    }

    static func houseIndex(_ longitude: Double, cusps: [Double]) -> Int {
        var l = longitude.truncatingRemainder(dividingBy: 360.0)
        if l < 0 { l += 360.0 }
        for h in 1...12 {
            var cur = cusps[h].truncatingRemainder(dividingBy: 360.0)
            if cur < 0 { cur += 360.0 }
            let nextH = h == 12 ? 1 : h + 1
            var nxt = cusps[nextH].truncatingRemainder(dividingBy: 360.0)
            if nxt < 0 { nxt += 360.0 }
            if cur <= nxt {
                if l >= cur && l < nxt { return h }
            } else {
                if l >= cur || l < nxt { return h }
            }
        }
        return 1
    }
}
