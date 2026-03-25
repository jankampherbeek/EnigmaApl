// ProjectionTypeKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for ProjectionTypes enum values.
struct ProjectionTypeKeys {
    private init() {}

    static let keys: [ProjectionTypes: String] = [
        .twoDimensional:  "enum.projectiontype.twodimensional",
        .obliqueLongitude:"enum.projectiontype.obliquelongitude",
    ]

    static func key(for type: ProjectionTypes) -> String {
        keys[type] ?? ""
    }
}
