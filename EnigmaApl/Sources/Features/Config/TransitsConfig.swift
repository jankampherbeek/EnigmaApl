//
//  TransitsConfig.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Foundation

/// Configuration for transits.
public struct TransitsConfig: Codable {
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
