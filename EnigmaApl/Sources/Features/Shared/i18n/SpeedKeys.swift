// SpeedKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for SpeedType enum values.
struct SpeedKeys {
    private init() {}

    static let keys: [SpeedType: String] = [
        .direct:               "enum.speedtype.direct",
        .retrograde:           "enum.speedtype.retrograde",
        .slow:                 "enum.speedtype.slow",
        .slowRetrograde:       "enum.speedtype.slowretrograde",
        .stationaryRetrograde: "enum.speedtype.stationaryretrograde",
        .stationaryDirect:     "enum.speedtype.stationarydirect",
    ]

    static func key(for speedType: SpeedType) -> String {
        keys[speedType] ?? ""
    }
}
