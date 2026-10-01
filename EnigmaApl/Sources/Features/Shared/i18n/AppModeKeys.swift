// AppModeKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for AppMode enum values.
struct AppModeKeys {
    private init() {}

    static let keys: [AppMode: String] = [
        .radix:         "enum.appmode.radix",
        .progressive:   "enum.appmode.progressive",
        .fixstars:      "enum.appmode.fixstars",
        .research:      "enum.appmode.research",
        .cycles:        "enum.appmode.cycles",
        .calculators:   "enum.appmode.calculators",
        .config:        "enum.appmode.config",
        .synastry:      "enum.appmode.synastry",
        .importExport:  "enum.appmode.importexport",
    ]

    static func key(for value: AppMode) -> String {
        keys[value] ?? ""
    }
}
