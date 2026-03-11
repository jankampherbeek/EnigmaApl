//
//  UTOffsetDirectionKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 11/03/2026.
//

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
