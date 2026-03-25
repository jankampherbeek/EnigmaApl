// YearCountKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for YearCount enum values.
struct YearCountKeys {
    private init() {}

    static let keys: [YearCount: String] = [
        .ce:          "enum.yearcount.ce",
        .bc:          "enum.yearcount.bce",
        .astronomical:"enum.yearcount.astronomical",
    ]

    static func key(for count: YearCount) -> String {
        keys[count] ?? ""
    }
}
