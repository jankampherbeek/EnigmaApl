// HarmonicsCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates harmonic positions for a list of (factor, longitude) pairs.
struct HarmonicsCalculator {

    private init() {}

    /// Returns harmonic positions for all factors, sorted by harmonic longitude (ascending).
    /// - Parameters:
    ///   - positions: Array of (Factors, ecliptic longitude) tuples.
    ///   - harmonic: The harmonic number to apply.
    /// - Returns: Sorted list of `HarmonicPosition`.
    static func calculate(positions: [(Factors, Double)], harmonic: Double) -> [HarmonicPosition] {
        // Use integer arithmetic when the harmonic is effectively a whole number for better precision.
        let isInteger = harmonic.truncatingRemainder(dividingBy: 1.0) == 0.0
        return positions
            .map { (factor, longitude) in
                let harmonicLongitude: Double
                if isInteger {
                    let n = Int(harmonic)
                    harmonicLongitude = (longitude * Double(n)).truncatingRemainder(dividingBy: 360.0)
                } else {
                    harmonicLongitude = (longitude * harmonic).truncatingRemainder(dividingBy: 360.0)
                }
                return HarmonicPosition(factor: factor, longitude: harmonicLongitude)
            }
            .sorted { $0.longitude < $1.longitude }
    }
}
