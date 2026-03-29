// MidpointMatchFinder.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Finds all factors that are conjunct with a midpoint (or in a hard aspect within the chosen dial).
struct MidpointMatchFinder {

    private init() {}

    /// Returns all midpoint matches, sorted by actual orb (most exact first).
    /// - Parameters:
    ///   - baseMidpoints: All base midpoints (as produced by `MidpointsCalculator`).
    ///   - positions: All active (factor, ecliptic longitude) pairs.
    ///   - dialType: The dial to use for matching.
    ///   - orb: Maximum allowed orb in degrees.
    static func find(
        baseMidpoints: [BaseMidpoint],
        positions: [(Factors, Double)],
        dialType: MidpointDialType,
        orb: Double
    ) -> [MidpointMatch] {
        let dialSize = dialType.dialSize
        var matches: [MidpointMatch] = []

        for midpoint in baseMidpoints {
            let midPos = reduceToDial(midpoint.position, dialSize: dialSize)
            for (factor, longitude) in positions {
                let factorPos = reduceToDial(longitude, dialSize: dialSize)
                let deviation = shortestDeviation(midPos, factorPos, dialSize: dialSize)
                if deviation <= orb {
                    matches.append(MidpointMatch(
                        factor1: midpoint.factor1,
                        factor2: midpoint.factor2,
                        midpointPosition: midpoint.position,
                        matchingFactor: factor,
                        matchingPosition: longitude,
                        actualOrb: deviation,
                        maxOrb: orb
                    ))
                }
            }
        }

        return matches.sorted { $0.actualOrb < $1.actualOrb }
    }

    // MARK: - Private helpers

    /// Reduces a 360° longitude to the given dial by taking modulo.
    private static func reduceToDial(_ longitude: Double, dialSize: Double) -> Double {
        longitude.truncatingRemainder(dividingBy: dialSize)
    }

    /// Shortest angular distance between two positions within a dial of `dialSize` degrees.
    /// The result lies in 0 ..< dialSize/2.
    private static func shortestDeviation(_ pos1: Double, _ pos2: Double, dialSize: Double) -> Double {
        let small = min(pos1, pos2)
        let large = max(pos1, pos2)
        let diff = large - small
        return diff >= dialSize / 2.0 ? dialSize - diff : diff
    }
}
