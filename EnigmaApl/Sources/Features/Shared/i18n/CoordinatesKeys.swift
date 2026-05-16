// CoordinatesKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for Coordinates enum values.
struct CoordinatesKeys {
    private init() {}

    static let keys: [Coordinates: String] = [
        .longitude:      "enum.coordinates.longitude",
        .latitude:       "enum.coordinates.latitude",
        .rightAscension: "enum.coordinates.rightascension",
        .declination:    "enum.coordinates.declination",
        .distance:       "enum.coordinates.distance",
    ]

    static func key(for coordinate: Coordinates) -> String {
        keys[coordinate] ?? ""
    }
}
