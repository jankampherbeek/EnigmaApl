// ImportExportSectionKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for ImportExportSection enum values.
struct ImportExportSectionKeys {
    private init() {}

    static let keys: [ImportExportSection: String] = [
        .enigma:      "enum.importexportsection.enigma",
        .quickChart:  "enum.importexportsection.quickchart",
        .aaf97:       "enum.importexportsection.aaf97",
    ]

    static func key(for value: ImportExportSection) -> String {
        keys[value] ?? ""
    }
}
