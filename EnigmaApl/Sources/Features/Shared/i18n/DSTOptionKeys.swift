//
//  DSTOptionKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 11/03/2026.
//

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
