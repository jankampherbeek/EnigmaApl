//
//  DateTimeValidation.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 20/12/2025.
//

import Foundation

/// Validate astronomical dates and times
public struct AstronomicalDateValidation {
    
    /// Validates an AstronomicalDate by checking if it can be converted to a Julian Day and back
    /// Uses the SEWrapper to perform the conversion and verify consistency
    /// - Parameter date: The AstronomicalDate to validate
    /// - Returns: True if the date is valid (can be converted to Julian Day and back without change), false otherwise
    public static func validateDate(_ date: AstronomicalDate) -> Bool {
        let seWrapper = SEWrapper()
        
        // Create a time at midnight (0:00:00) for date-only validation
        let midnightTime = AstronomicalTime(Hour: 0, Minute: 0, Second: 0)
        
        // Convert the date to Julian Day
        let julianDay = seWrapper.julianDay(date: date, time: midnightTime)
        
        // Convert back from Julian Day to date
        let convertedDateTime = seWrapper.dateFromJulianDay(julianDay, gregorian: date.Gregorian)
        
        // Check if the converted date matches the original
        return convertedDateTime.Date.Year == date.Year &&
               convertedDateTime.Date.Month == date.Month &&
               convertedDateTime.Date.Day == date.Day &&
               convertedDateTime.Date.Gregorian == date.Gregorian
    }
    
    /// Validates an AstronomicalTime using a 24-hour clock
    /// - Parameter time: The AstronomicalTime to validate
    /// - Returns: True if the time is valid (hour 0-23, minute 0-59, second 0-59), false otherwise
    public static func validateTime(_ time: AstronomicalTime) -> Bool {
        return time.Hour >= 0 && time.Hour <= 23 &&
               time.Minute >= 0 && time.Minute <= 59 &&
               time.Second >= 0 && time.Second <= 59
    }
}
