// SecondaryDirectionsConfig.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Configuration for secondary directions.
public struct SecondaryDirectionsConfig: Codable, Sendable {
    public let factors: [Factors]
    public let orb: Double

    public init(
        factors: [Factors] = SecondaryDirectionsConfig.defaultFactors,
        orb: Double = 1.0
    ) {
        self.factors = factors
        self.orb = orb
    }

    public static let defaultFactors: [Factors] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .northNode
    ]
}
