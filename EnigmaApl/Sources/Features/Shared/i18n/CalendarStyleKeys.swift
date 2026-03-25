// CalendarStyleKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Localization keys for CalendarStyle enum values.
struct CalendarStyleKeys {
    private init() {}

    static let keys: [CalendarStyle: String] = [
        .gregorian: "enum.calendarstyle.gregorian",
        .julian:    "enum.calendarstyle.julian",
    ]

    static func key(for style: CalendarStyle) -> String {
        keys[style] ?? ""
    }
}
