// FoundAspect.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

struct FoundAspect {
    /// First factor in the aspect pair (lower index in calculation order).
    let factor1: Factors
    /// Second factor in the aspect pair.
    let factor2: Factors
    /// The aspect type that was found.
    let aspect: Aspects
    /// Actual angular deviation from the exact aspect angle (0 = exact).
    let orb: Double
    /// Maximum allowed orb for this factor/aspect combination.
    let maxOrb: Double
}
