// LatitudeHemisphereKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for LatitudeHemisphere enum values.
struct LatitudeHemisphereKeys {
    private init() {}

    static let keys: [LatitudeHemisphere: String] = [
        .north: "enum.latitudehemisphere.north",
        .south: "enum.latitudehemisphere.south",
    ]

    static func key(for hemisphere: LatitudeHemisphere) -> String {
        keys[hemisphere] ?? ""
    }
}
