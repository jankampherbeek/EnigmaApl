// ZodiacTypeKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

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
