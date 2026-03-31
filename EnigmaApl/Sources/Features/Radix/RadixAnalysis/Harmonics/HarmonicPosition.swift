// HarmonicPosition.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// The harmonic position of an astrological factor on the ecliptic (0–360°).
struct HarmonicPosition {
    /// The astrological factor.
    let factor: Factors
    /// Harmonic ecliptic longitude (0–360°).
    let longitude: Double
}
