//
//  DateTimeValidation.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 20/12/2025.
//

import Foundation

public struct DateComponentsValidationResult {
    public let isValid: Bool
    public let message: String?

    public init(isValid: Bool, message: String? = nil) {
        self.isValid = isValid
        self.message = message
    }
}

/// Validate astronomical dates and times.
public struct AstronomicalDateValidation {

    /// Validates an AstronomicalDate by checking if it can be converted to a Julian Day and back.
    /// Uses the SEWrapper to perform the conversion and verify consistency.
    public static func validateDate(_ date: AstronomicalDate) -> Bool {
        let seWrapper = SEWrapper()

        // Create a time at midnight (0:00:00) for date-only validation.
        let midnightTime = AstronomicalTime(Hour: 0, Minute: 0, Second: 0)

        // Convert the date to Julian Day.
        let julianDay = seWrapper.julianDay(date: date, time: midnightTime)

        // Convert back from Julian Day to date.
        let convertedDateTime = seWrapper.dateFromJulianDay(julianDay, gregorian: date.Gregorian)

        // Check if the converted date matches the original.
        return convertedDateTime.Date.Year == date.Year &&
               convertedDateTime.Date.Month == date.Month &&
               convertedDateTime.Date.Day == date.Day &&
               convertedDateTime.Date.Gregorian == date.Gregorian
    }

    /// Validates date components against Gregorian/Julian calendar rules,
    /// including leap-year handling and month-length constraints.
    public static func validateDateComponents(year: Int, month: Int, day: Int, gregorian: Bool) -> DateComponentsValidationResult {
        guard month >= 1 && month <= 12 else {
            return DateComponentsValidationResult(isValid: false, message: "Month must be between 1 and 12")
        }

        guard day >= 1 else {
            return DateComponentsValidationResult(isValid: false, message: "Day must be at least 1")
        }

        let maxDay = daysInMonth(year: year, month: month, gregorian: gregorian)
        guard day <= maxDay else {
            let cal = gregorian ? "Gregorian" : "Julian"
            return DateComponentsValidationResult(
                isValid: false,
                message: "Day \(day) is invalid for month \(month) in the \(cal) calendar (max \(maxDay))"
            )
        }

        return DateComponentsValidationResult(isValid: true)
    }

    /// Validates an AstronomicalTime using a 24-hour clock.
    public static func validateTime(_ time: AstronomicalTime) -> Bool {
        return time.Hour >= 0 && time.Hour <= 23 &&
               time.Minute >= 0 && time.Minute <= 59 &&
               time.Second >= 0 && time.Second <= 59
    }

    public static func isGregorianLeapYear(_ year: Int) -> Bool {
        return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
    }

    public static func isJulianLeapYear(_ year: Int) -> Bool {
        return year % 4 == 0
    }

    public static func daysInMonth(year: Int, month: Int, gregorian: Bool) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12:
            return 31
        case 4, 6, 9, 11:
            return 30
        case 2:
            let leap = gregorian ? isGregorianLeapYear(year) : isJulianLeapYear(year)
            return leap ? 29 : 28
        default:
            return 0
        }
    }
}
