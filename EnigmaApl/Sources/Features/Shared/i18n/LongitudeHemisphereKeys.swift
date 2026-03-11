//
//  LongitudeHemisphereKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 11/03/2026.
//

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
