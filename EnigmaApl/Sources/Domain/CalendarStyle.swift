//
//  CalendarStyle.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 04/03/2026.
//

// Gregorian or Julian calendar
enum CalendarStyle: String, CaseIterable, Identifiable {
    case gregorian = "enum.calendarstyle.gregorian"
    case julian = "enum.calendarstyle.julian"
    var id: String { rawValue }
}
