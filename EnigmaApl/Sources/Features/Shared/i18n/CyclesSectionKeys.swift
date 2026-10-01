// CyclesSectionKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for CyclesSection enum values.
struct CyclesSectionKeys {
    private init() {}

    static let keys: [CyclesSection: String] = [
        .astronomicalCycles:  "enum.cyclessection.astronomicalcycles",
        .waves:               "enum.cyclessection.waves",
        .tablesGraphs:        "enum.cyclessection.tablesgraphs",
        .ephemeris:           "enum.cyclessection.ephemeris",
        .longTimeEphemeris:   "enum.cyclessection.longtimeephemeris",
        .eclipses:            "enum.cyclessection.eclipses",
    ]

    static func key(for value: CyclesSection) -> String {
        keys[value] ?? ""
    }
}
