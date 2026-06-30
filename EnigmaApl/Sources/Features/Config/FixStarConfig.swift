// FixStarConfig.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Settings for a single fixed star.
public struct FixStarSettings: Codable, Equatable, Sendable {
    public let fixStar: StarDefinitions
    public let isUsed: Bool
    public let selection: FixStarSelections

    public init(fixStar: StarDefinitions, isUsed: Bool, selection: FixStarSelections) {
        self.fixStar = fixStar
        self.isUsed = isUsed
        self.selection = selection
    }
}

/// Configuration for which fixed stars are active and how they are selected.
public struct FixStarConfig: Codable, Sendable {
    public let includeGalacticCenter: Bool
    public let fixStarOrb: Double
    public let paranTimeOrb: Double
    public let activeSelection: FixStarSelections
    public let magnitudeLimit: Int
    public let fixStarSettings: [FixStarSettings]

    public init(
        includeGalacticCenter: Bool = false,
        fixStarOrb: Double = 1.0,
        paranTimeOrb: Double = 10.0,
        activeSelection: FixStarSelections = .magnitude,
        magnitudeLimit: Int = 4,
        fixStarSettings: [FixStarSettings] = FixStarConfig.defaultSettings
    ) {
        self.includeGalacticCenter = includeGalacticCenter
        self.fixStarOrb = fixStarOrb
        self.paranTimeOrb = paranTimeOrb
        self.activeSelection = activeSelection
        self.magnitudeLimit = magnitudeLimit
        self.fixStarSettings = fixStarSettings
    }

    /// Default configuration: no fixed stars active, magnitude selection up to 4.
    public static let defaultSettings: [FixStarSettings] = StarDefinitions.allCases.map { star in
        FixStarSettings(fixStar: star, isUsed: false, selection: .magnitude)
    }
}
