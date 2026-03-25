// UTOffsetDirectionKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for UTOffsetDirection enum values.
struct UTOffsetDirectionKeys {
    private init() {}

    static let keys: [UTOffsetDirection: String] = [
        .later:   "enum.utoffsetdirection.later",
        .earlier: "enum.utoffsetdirection.earlier",
    ]

    static func key(for direction: UTOffsetDirection) -> String {
        keys[direction] ?? ""
    }
}
