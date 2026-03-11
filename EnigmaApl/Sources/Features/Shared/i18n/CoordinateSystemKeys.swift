//
//  CoordinateSystemKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 11/03/2026.
//

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
