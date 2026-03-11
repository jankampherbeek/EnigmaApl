//
//  LatitudeHemisphereKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 11/03/2026.
//

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
