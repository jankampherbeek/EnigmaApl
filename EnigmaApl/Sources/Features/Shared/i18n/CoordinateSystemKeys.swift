// CoordinateSystemKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for CoordinateSystems enum values.
struct CoordinateSystemKeys {
    private init() {}

    static let keys: [CoordinateSystems: String] = [
        .ecliptical: "enum.coordinatesys.ecliptic",
        .equatorial: "enum.coordinatesys.equatorial",
        .horizontal: "enum.coordinatesys.horizontal",
    ]

    static func key(for system: CoordinateSystems) -> String {
        keys[system] ?? ""
    }
}
