// SignColorSelector.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct SignColorSelector {
    private init() {}

    private static var colorMap: [Signs: Color] = defaultMap()

    /// Updates the color map from the active display configuration.
    /// Call on app launch and whenever the active configuration changes.
    static func configure(with displayConfig: DisplayConfig) {
        var map = defaultMap()
        for override in displayConfig.signColors {
            map[override.sign] = Color(override.color)
        }
        colorMap = map
    }

    /// Returns the background color for a zodiac sign.
    static func getColorForSign(_ sign: Signs) -> Color {
        colorMap[sign] ?? Color(ColorConfig.defaultSignColor)
    }

    // MARK: - Private

    private static func defaultMap() -> [Signs: Color] {
        let defaultColor = Color(ColorConfig.defaultSignColor)
        return Dictionary(uniqueKeysWithValues: Signs.allCases.map { ($0, defaultColor) })
    }
}
