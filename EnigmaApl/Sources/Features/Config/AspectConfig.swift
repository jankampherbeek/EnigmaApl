// AspectConfig.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

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
    /// Color used when drawing this aspect in the chart.
    public let color: ColorConfig

    public init(aspect: Aspects, isUsed: Bool, isDrawn: Bool,
                orbPercentage: Int = 100,
                color: ColorConfig = ColorConfig(red: 0.5, green: 0.5, blue: 0.5)) {
        self.aspect = aspect
        self.isUsed = isUsed
        self.isDrawn = isDrawn
        self.orbPercentage = orbPercentage
        self.color = color
    }

    // Custom decoder for backward compatibility: existing data without `color` falls back to the default.
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        aspect        = try c.decode(Aspects.self,     forKey: .aspect)
        isUsed        = try c.decode(Bool.self,        forKey: .isUsed)
        isDrawn       = try c.decode(Bool.self,        forKey: .isDrawn)
        orbPercentage = try c.decode(Int.self,         forKey: .orbPercentage)
        color         = try c.decodeIfPresent(ColorConfig.self, forKey: .color)
                        ?? AspectSettings.defaultColor(for: aspect)
    }

    public static func defaultColor(for aspect: Aspects) -> ColorConfig {
        switch aspect {
        case .conjunction:
            return ColorConfig(red: 0.0, green: 0.0, blue: 1.0)
        case .square, .opposition:
            return ColorConfig(red: 1.0, green: 0.0, blue: 0.0)
        case .trine, .sextile:
            return ColorConfig(red: 0.0, green: 0.6, blue: 0.0)
        case .inconjunct:
            return ColorConfig(red: 0.5, green: 0.0, blue: 0.5)
        default:
            return ColorConfig(red: 0.5, green: 0.5, blue: 0.5)
        }
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
            return AspectSettings(aspect: aspect, isUsed: true, isDrawn: true, orbPercentage: 100,
                                  color: AspectSettings.defaultColor(for: aspect))
        case .trine, .square:
            return AspectSettings(aspect: aspect, isUsed: true, isDrawn: true, orbPercentage: 80,
                                  color: AspectSettings.defaultColor(for: aspect))
        case .sextile:
            return AspectSettings(aspect: aspect, isUsed: true, isDrawn: true, orbPercentage: 60,
                                  color: AspectSettings.defaultColor(for: aspect))
        case .inconjunct:
            return AspectSettings(aspect: aspect, isUsed: true, isDrawn: true, orbPercentage: 30,
                                  color: AspectSettings.defaultColor(for: aspect))
        default:
            return AspectSettings(aspect: aspect, isUsed: false, isDrawn: false, orbPercentage: 15,
                                  color: AspectSettings.defaultColor(for: aspect))
        }
    }
}
