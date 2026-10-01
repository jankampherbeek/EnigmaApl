// ProgressiveSectionKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for ProgressiveSection enum values.
struct ProgressiveSectionKeys {
    private init() {}

    static let keys: [ProgressiveSection: String] = [
        .events:                "enum.progressivesection.events",
        .primary:               "enum.progressivesection.primary",
        .secondary:             "enum.progressivesection.secondary",
        .transit:               "enum.progressivesection.transit",
        .symbolic:              "enum.progressivesection.symbolic",
        .solar:                 "enum.progressivesection.solar",
        .prenatal:              "enum.progressivesection.prenatal",
        .logarithmicTimescale:  "enum.progressivesection.logarithmictimescale",
        .agePoint:              "enum.progressivesection.agepoint",
        .progressiveCalendar:   "enum.progressivesection.progressivecalendar",
    ]

    static func key(for value: ProgressiveSection) -> String {
        keys[value] ?? ""
    }
}
