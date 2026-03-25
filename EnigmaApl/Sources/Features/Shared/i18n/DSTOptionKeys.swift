// DSTOptionKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for DSTOption enum values.
struct DSTOptionKeys {
    private init() {}

    static let keys: [DSTOption: String] = [
        .dst:   "enum.dstoption.dst",
        .noDST: "enum.dstoption.nodst",
    ]

    static func key(for option: DSTOption) -> String {
        keys[option] ?? ""
    }
}
