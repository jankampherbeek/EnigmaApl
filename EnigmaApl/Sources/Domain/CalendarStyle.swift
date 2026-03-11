//
//  CalendarStyle.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 04/03/2026.
//

// Gregorian or Julian calendar
enum CalendarStyle: CaseIterable, Identifiable, Hashable {
    case gregorian
    case julian

    var id: Self { self }
    var rbKey: String { CalendarStyleKeys.key(for: self) }
}
