//
//  OrbConfig.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Foundation

/// The method used to calculate effective orbs.
public enum OrbSystem: Int, CaseIterable, Codable {
    case procentual = 0
    case fixed = 1
    case harmonicBased = 2

    var rbKey: String {
        switch self {
        case .procentual:    return "enum.orbsystem.procentual"
        case .fixed:         return "enum.orbsystem.fixed"
        case .harmonicBased: return "enum.orbsystem.harmonicbased"
        }
    }
}

/// Configuration for global orb values used in different calculation types.
/// The effective orb for an aspect is derived by combining the base orb with
/// the orb percentages from FactorConfig and AspectConfig.
public struct OrbConfig: Codable {
    /// The method used to calculate effective orbs.
    public let orbSystem: OrbSystem
    /// Base orb in degrees for aspect calculations, before factor and aspect percentages are applied.
    public let aspectBaseOrb: Double
    /// Orb in degrees for midpoint calculations.
    public let midpointOrb: Double
    /// Orb in degrees for harmonic calculations.
    public let harmonicOrb: Double
    /// Orb in degrees for parallels and contra-parallels.
    public let parallelOrb: Double

    public init(
        orbSystem: OrbSystem = .procentual,
        aspectBaseOrb: Double = 10.0,
        midpointOrb: Double = 1.6,
        harmonicOrb: Double = 2.0,
        parallelOrb: Double = 1.0
    ) {
        self.orbSystem = orbSystem
        self.aspectBaseOrb = aspectBaseOrb
        self.midpointOrb = midpointOrb
        self.harmonicOrb = harmonicOrb
        self.parallelOrb = parallelOrb
    }
}
