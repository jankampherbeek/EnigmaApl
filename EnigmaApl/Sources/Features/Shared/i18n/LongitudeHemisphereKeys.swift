// LongitudeHemisphereKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for LongitudeHemisphere enum values.
struct LongitudeHemisphereKeys {
    private init() {}

    static let keys: [LongitudeHemisphere: String] = [
        .east: "enum.longitudehemisphere.east",
        .west: "enum.longitudehemisphere.west",
    ]

    static func key(for hemisphere: LongitudeHemisphere) -> String {
        keys[hemisphere] ?? ""
    }
}
