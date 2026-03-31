// HarmonicsMatchFinder.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Finds matches between harmonic positions and radix (natal) factor positions.
struct HarmonicsMatchFinder {

    private init() {}

    /// Returns all matches where a harmonic position falls within `orb` of a radix position.
    /// - Parameters:
    ///   - harmonics: Calculated harmonic positions, as returned by `HarmonicsCalculator`.
    ///   - radixPositions: Array of (Factors, ecliptic longitude) tuples from the natal chart.
    ///   - orb: Maximum allowed angular separation for a match (degrees).
    /// - Returns: All matches, sorted by actual orb ascending (most exact first).
    static func find(
        harmonics: [HarmonicPosition],
        radixPositions: [(Factors, Double)],
        orb: Double
    ) -> [HarmonicMatch] {
        var matches: [HarmonicMatch] = []
        for harmonic in harmonics {
            for (radixFactor, radixLongitude) in radixPositions {
                let separation = angularSeparation(harmonic.longitude, radixLongitude)
                if separation <= orb {
                    matches.append(HarmonicMatch(
                        radixFactor: radixFactor,
                        harmonicFactor: harmonic.factor,
                        actualOrb: separation,
                        maxOrb: orb
                    ))
                }
            }
        }
        return matches.sorted { $0.actualOrb < $1.actualOrb }
    }

    // MARK: - Private helpers

    /// Shortest angular separation between two ecliptic longitudes, in the range 0–180°.
    private static func angularSeparation(_ long1: Double, _ long2: Double) -> Double {
        let diff = abs(long1 - long2).truncatingRemainder(dividingBy: 360.0)
        return diff > 180.0 ? 360.0 - diff : diff
    }
}
