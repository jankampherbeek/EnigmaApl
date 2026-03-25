// TransitsConfig.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Configuration for transits.
public struct TransitsConfig: Codable, Sendable {
    public let factors: [Factors]
    public let orb: Double

    public init(
        factors: [Factors] = TransitsConfig.defaultFactors,
        orb: Double = 1.0
    ) {
        self.factors = factors
        self.orb = orb
    }

    public static let defaultFactors: [Factors] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn,
        .uranus, .neptune, .pluto, .chiron, .northNode
    ]
}
