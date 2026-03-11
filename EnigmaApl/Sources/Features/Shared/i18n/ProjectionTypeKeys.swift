//
//  ProjectionTypeKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 11/03/2026.
//

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
