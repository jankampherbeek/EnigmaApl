// MidpointsCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates all base midpoints for a list of (factor, longitude) pairs.
struct MidpointsCalculator {

    private init() {}

    /// Returns all base midpoints sorted by position (ascending).
    /// - Parameter positions: Array of (Factors, ecliptic longitude) tuples.
    /// - Returns: Sorted list of `BaseMidpoint`.
    static func calculate(positions: [(Factors, Double)]) -> [BaseMidpoint] {
        var midpoints: [BaseMidpoint] = []
        let count = positions.count
        for i in 0..<count {
            for j in (i + 1)..<count {
                let (f1, long1) = positions[i]
                let (f2, long2) = positions[j]
                let midPos = midpointPosition(long1, long2)
                midpoints.append(BaseMidpoint(factor1: f1, factor2: f2, position: midPos))
            }
        }
        return midpoints.sorted { $0.position < $1.position }
    }

    // MARK: - Helpers

    /// Calculates the midpoint position along the shortest arc between two longitudes.
    /// - Returns: Midpoint longitude in 0–360°.
    static func midpointPosition(_ long1: Double, _ long2: Double) -> Double {
        let small = min(long1, long2)
        let large = max(long1, long2)
        let diff = large - small
        let firstOnArc = diff < 180.0 ? small : large
        var arcedDiff = large - small
        if diff >= 180.0 {
            // Shortest arc wraps around 0°
            arcedDiff = 360.0 - diff
        }
        var midPos = firstOnArc + arcedDiff / 2.0
        if midPos >= 360.0 { midPos -= 360.0 }
        return midPos
    }
}
