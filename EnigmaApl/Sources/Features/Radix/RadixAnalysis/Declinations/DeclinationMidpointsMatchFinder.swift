// DeclinationMidpointsMatchFinder.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Finds all factors whose declination coincides with a declination midpoint within the allowed orb.
///
/// Comparable to `MidpointMatchFinder` for ecliptic midpoints, but operates on the linear
/// declination scale (roughly −90° to +90°) so no circular reduction is needed.
///
/// Algorithm:
/// 1. For each `DeclBaseMidpoint`, compare its position with every (factor, declination) pair.
/// 2. `deviation = |midpointPosition − factorDeclination|`
/// 3. If `deviation ≤ orb`, record a `DeclOccupiedMidpoint` with
///    `exactness = 100 − (deviation / orb × 100)`.
struct DeclinationMidpointsMatchFinder {

    private init() {}

    /// Returns all occupied declination midpoints, sorted by `actualOrb` ascending (most exact first).
    ///
    /// - Parameters:
    ///   - baseMidpoints: All declination base midpoints (as produced by `DeclMidpointsCalculator`).
    ///   - positions: All active (factor, declination) pairs to test against each midpoint.
    ///   - orb: Maximum allowed deviation in degrees.
    /// - Returns: Every combination of midpoint + occupying factor whose deviation ≤ orb,
    ///   sorted by `actualOrb` ascending.
    static func find(
        baseMidpoints: [DeclBaseMidpoint],
        positions: [(Factors, Double)],
        orb: Double
    ) -> [DeclOccupiedMidpoint] {
        var results: [DeclOccupiedMidpoint] = []

        for midpoint in baseMidpoints {
            for (factor, declination) in positions {
                let deviation = abs(midpoint.position - declination)
                guard deviation <= orb else { continue }
                let exactness = orb > 0 ? 100.0 - (deviation / orb * 100.0) : 100.0
                results.append(DeclOccupiedMidpoint(
                    midpoint:          midpoint,
                    occupyingFactor:   factor,
                    occupyingPosition: declination,
                    actualOrb:         deviation,
                    exactness:         exactness
                ))
            }
        }

        return results.sorted { $0.actualOrb < $1.actualOrb }
    }
}
