//
//  AspectConfig.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Foundation

/// Settings for a single aspect.
public struct AspectSettings: Codable, Equatable, Sendable {
    public let aspect: Aspects
    /// Whether this aspect is included in calculations.
    public let isUsed: Bool
    /// Whether this aspect is shown in the chart drawing.
    public let isDrawn: Bool
    /// Percentage of the base orb applied for this aspect (0–100).
    public let orbPercentage: Int

    public init(aspect: Aspects, isUsed: Bool, isDrawn: Bool, orbPercentage: Int = 100) {
        self.aspect = aspect
        self.isUsed = isUsed
        self.isDrawn = isDrawn
        self.orbPercentage = orbPercentage
    }
}

/// Configuration for which aspects are active and their orb percentages.
public struct AspectConfig: Codable, Sendable {
    public let aspectSettings: [AspectSettings]

    public init(aspectSettings: [AspectSettings] = AspectConfig.defaultSettings) {
        self.aspectSettings = aspectSettings
    }

    public static let defaultSettings: [AspectSettings] = Aspects.allCases.map { aspect in
        switch aspect {
        case .conjunction, .opposition:
            return AspectSettings(aspect: aspect, isUsed: true, isDrawn: true, orbPercentage: 100)
        case .trine, .square:
            return AspectSettings(aspect: aspect, isUsed: true, isDrawn: true, orbPercentage: 80)
        case .sextile:
            return AspectSettings(aspect: aspect, isUsed: true, isDrawn: true, orbPercentage: 60)
        case .inconjunct:
            return AspectSettings(aspect: aspect, isUsed: true, isDrawn: true, orbPercentage: 30)
        default:
            return AspectSettings(aspect: aspect, isUsed: false, isDrawn: false, orbPercentage: 15)
        }
    }
}
