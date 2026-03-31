// HarmonicMatch.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// A match between a harmonic position and a radix factor position.
struct HarmonicMatch {
    /// The factor whose radix (natal) position matches the harmonic position.
    let radixFactor: Factors
    /// The factor whose harmonic position triggered the match.
    let harmonicFactor: Factors
    /// Actual angular separation between the harmonic and radix positions (0 = exact).
    let actualOrb: Double
    /// Maximum allowed orb for this match.
    let maxOrb: Double
}
