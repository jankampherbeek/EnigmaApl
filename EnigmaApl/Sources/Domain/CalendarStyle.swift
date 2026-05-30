// CalendarStyle.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

// Gregorian or Julian calendar
enum CalendarStyle: CaseIterable, Identifiable, Hashable {
    case gregorian
    case julian

    var id: Self { self }
    var rbKey: String { CalendarStyleKeys.key(for: self) }
}
