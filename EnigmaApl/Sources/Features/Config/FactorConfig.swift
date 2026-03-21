//
//  FactorConfig.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Foundation

/// Settings for a single celestial factor.
public struct FactorSettings: Codable, Equatable {
    public let factor: Factors
    /// Whether this factor is included in calculations.
    public let isUsed: Bool
    /// Whether this factor is shown in the chart drawing.
    public let isDrawn: Bool
    /// Percentage of the aspect orb applied when this factor is involved (0–100).
    public let orbPercentage: Int

    public init(factor: Factors, isUsed: Bool, isDrawn: Bool, orbPercentage: Int = 100) {
        self.factor = factor
        self.isUsed = isUsed
        self.isDrawn = isDrawn
        self.orbPercentage = orbPercentage
    }
}

/// Configuration for which celestial factors are active and how they participate in orb calculations.
public struct FactorConfig: Codable {
    public let factorSettings: [FactorSettings]

    public init(factorSettings: [FactorSettings] = FactorConfig.defaultSettings) {
        self.factorSettings = factorSettings
    }

    /// Default western tropical configuration: classic planets and angles active, all others inactive.
    public static let defaultSettings: [FactorSettings] = Factors.allCases.map { factor in
        switch factor {
        case .sun, .moon, .ascendant, .mc:
            return FactorSettings(factor: factor, isUsed: true, isDrawn: true, orbPercentage: 100)
        case .mercury, .venus, .mars, .jupiter:
            return FactorSettings(factor: factor, isUsed: true, isDrawn: true, orbPercentage: 85)
        case .saturn, .uranus, .neptune, .pluto, .northNode, .chiron:
            return FactorSettings(factor: factor, isUsed: true, isDrawn: true, orbPercentage: 75)
        default:
            return FactorSettings(factor: factor, isUsed: false, isDrawn: false, orbPercentage: 50)
        }
    }
}
