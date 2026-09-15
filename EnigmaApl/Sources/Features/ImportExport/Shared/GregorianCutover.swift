// GregorianCutover.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// The historical Gregorian calendar cutover (1582-10-15), used by formats
/// that leave the calendar implicit (QCK) or define a fallback rule for it
/// when no explicit calendar suffix is given (AAF'97: dates before the
/// cutover default to Julian, on/after default to Gregorian).
enum GregorianCutover {
    static func isBeforeCutover(year: Int, month: Int, day: Int) -> Bool {
        if year != 1582 { return year < 1582 }
        if month != 10 { return month < 10 }
        return day < 15
    }
}
