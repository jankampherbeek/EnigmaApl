// DataFileTypeKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for DataFileType enum values.
struct DataFileTypeKeys {
    private init() {}

    static let nameKeys: [DataFileType: String] = [
        .standardEnigma: "enum.datafiletype.standardenigma",
        .gauquelin:      "enum.datafiletype.gauquelin",
        .quickChart:     "enum.datafiletype.quickchart",
    ]

    static func nameKey(for type: DataFileType) -> String {
        nameKeys[type] ?? ""
    }
}
