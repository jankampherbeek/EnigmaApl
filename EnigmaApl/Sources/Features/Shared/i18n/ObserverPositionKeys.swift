// ObserverPositionKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for ObserverPositions enum values.
struct ObserverPositionKeys {
    private init() {}

    static let keys: [ObserverPositions: String] = [
        .geoCentric:  "enum.observerpos.geocentric",
        .topoCentric: "enum.observerpos.topocentric",
        .helioCentric:"enum.observerpos.heliocentric",
    ]

    static func key(for position: ObserverPositions) -> String {
        keys[position] ?? ""
    }
}
