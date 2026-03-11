//
//  ZodiacTypeKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 11/03/2026.
//

/// Localization keys for ZodiacTypes enum values.
struct ZodiacTypeKeys {
    private init() {}

    static let keys: [ZodiacTypes: String] = [
        .sidereal: "enum.zodiactype.sidereal",
        .tropical: "enum.zodiactype.tropical",
    ]

    static func key(for type: ZodiacTypes) -> String {
        keys[type] ?? ""
    }
}
