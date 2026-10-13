// HarmonicExactAspect.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// The aspect with the smallest orb within one harmonic.
struct HarmonicExactAspect {
    /// The harmonic number.
    let harmonic: Int
    let factor1: Factors
    let factor2: Factors
    let aspect: Aspects
    /// Actual orb in degrees between the harmonic positions and the exact aspect angle.
    let orb: Double
}

/// Which aspects are used when searching for the most exact aspect.
enum HarmonicAspectSelection: CaseIterable {
    /// The aspects that are in use in the active configuration.
    case configured
    /// Conjunction, opposition, square, trine and sextile.
    case major

    static let majorAspects: [Aspects] = [.conjunction, .opposition, .square, .trine, .sextile]
}
