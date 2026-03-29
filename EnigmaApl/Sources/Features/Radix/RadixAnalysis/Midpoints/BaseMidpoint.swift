// BaseMidpoint.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// A midpoint between two astrological factors, positioned on the ecliptic (0–360°).
struct BaseMidpoint {
    /// First factor of the midpoint pair.
    let factor1: Factors
    /// Second factor of the midpoint pair.
    let factor2: Factors
    /// Ecliptic longitude of the midpoint (0–360°).
    let position: Double
}
