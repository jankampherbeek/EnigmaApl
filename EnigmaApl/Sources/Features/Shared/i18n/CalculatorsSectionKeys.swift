// CalculatorsSectionKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for CalculatorsSection enum values.
struct CalculatorsSectionKeys {
    private init() {}

    static let keys: [CalculatorsSection: String] = [
        .julianDay:  "enum.calculatorssection.julianday",
        .obliquity:  "enum.calculatorssection.obliquity",
    ]

    static func key(for value: CalculatorsSection) -> String {
        keys[value] ?? ""
    }
}
