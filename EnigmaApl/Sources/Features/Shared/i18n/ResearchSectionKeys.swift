// ResearchSectionKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for ResearchSection enum values.
struct ResearchSectionKeys {
    private init() {}

    static let keys: [ResearchSection: String] = [
        .projects:  "enum.researchsection.projects",
    ]

    static func key(for value: ResearchSection) -> String {
        keys[value] ?? ""
    }
}
