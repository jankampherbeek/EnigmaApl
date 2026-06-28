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
    public let fixStarSettings: [FixStarSettings]

    public init(fixStarSettings: [FixStarSettings] = FixStarConfig.defaultSettings) {
        self.fixStarSettings = fixStarSettings
    }

    /// Default configuration: no fixed stars active.
    public static let defaultSettings: [FixStarSettings] = StarDefinitions.allCases.map { star in
        FixStarSettings(fixStar: star, isUsed: false, selection: .magnitude)
    }
}
