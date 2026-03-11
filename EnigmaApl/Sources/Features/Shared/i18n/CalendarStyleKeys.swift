//
//  CalendarStyleKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 11/03/2026.
//

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
