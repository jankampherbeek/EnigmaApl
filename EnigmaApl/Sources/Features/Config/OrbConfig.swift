// OrbConfig.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Configuration for global orb values used in different calculation types.
/// The effective orb for an aspect is derived by combining the base orb with
/// the orb percentages from FactorConfig and AspectConfig.
public nonisolated struct OrbConfig: Codable, Sendable {
    /// Base orb in degrees for aspect calculations, before factor and aspect percentages are applied.
    public let aspectBaseOrb: Double
    /// Orb in degrees for midpoint calculations in the 360° dial.
    public let midpoint360DialOrb: Double
    /// Orb in degrees for midpoint calculations in the 90° dial.
    public let midpoint90DialOrb: Double
    /// Orb in degrees for midpoint calculations in the 45° dial.
    public let midpoint45DialOrb: Double
    /// Orb in degrees for harmonic calculations.
    public let harmonicOrb: Double
    /// Orb in degrees for parallels and contra-parallels.
    public let parallelOrb: Double
    /// Orb in degrees for declination midpoint calculations.
    public let declinationMidpointOrb: Double

    public init(
        aspectBaseOrb: Double = 10.0,
        midpoint360DialOrb: Double = 1.5,
        midpoint90DialOrb: Double = 1.0,
        midpoint45DialOrb: Double = 0.5,
        harmonicOrb: Double = 2.0,
        parallelOrb: Double = 1.0,
        declinationMidpointOrb: Double = 0.75
    ) {
        self.aspectBaseOrb = aspectBaseOrb
        self.midpoint360DialOrb = midpoint360DialOrb
        self.midpoint90DialOrb = midpoint90DialOrb
        self.midpoint45DialOrb = midpoint45DialOrb
        self.harmonicOrb = harmonicOrb
        self.parallelOrb = parallelOrb
        self.declinationMidpointOrb = declinationMidpointOrb
    }
}
