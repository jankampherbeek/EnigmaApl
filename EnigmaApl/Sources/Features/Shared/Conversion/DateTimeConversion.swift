//
//  DateTimeConversion.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/12/2025.
//

import Foundation

public struct DateTimeConversion {
    
    /// Converts an AstronomicalDate to a formatted string.
    /// Format: "yyyy/mm/dd G" or "yyyy/mm/dd J" with leading zeros for day/month < 10.
    /// - Parameter date: The AstronomicalDate to convert
    /// - Returns: Formatted string (e.g., "2025/01/15 G" or "2025/01/15 J")
    public static func DateToText(_ date: AstronomicalDate) -> String {
        let year = String(date.Year)
        let month = String(format: "%02d", date.Month)
        let day = String(format: "%02d", date.Day)
        let calendar = date.Gregorian ? "G" : "J"
        
        return "\(year)/\(month)/\(day) \(calendar)"
    }
    
    /// Converts an AstronomicalTime to a formatted string.
    /// Format: "hh:mm:ss" with leading zeros for minutes/seconds < 10.
    /// - Parameter time: The AstronomicalTime to convert
    /// - Returns: Formatted string (e.g., "14:30:45")
    public static func TimeToText(_ time: AstronomicalTime) -> String {
        let hour = String(format: "%02d", time.Hour)
        let minute = String(format: "%02d", time.Minute)
        let second = String(format: "%02d", time.Second)
        
        return "\(hour):\(minute):\(second)"
    }
    
    /// Converts an AstronomicalDateTime to a formatted string.
    /// Combines DateToText and TimeToText separated by a space.
    /// Format: "yyyy/mm/dd G hh:mm:ss" or "yyyy/mm/dd J hh:mm:ss"
    /// - Parameter dateTime: The AstronomicalDateTime to convert
    /// - Returns: Formatted string (e.g., "2025/01/15 G 14:30:45")
    public static func DateTimeToText(_ dateTime: AstronomicalDateTime) -> String {
        let dateText = DateToText(dateTime.Date)
        let timeText = TimeToText(dateTime.Time)
        
        return "\(dateText) \(timeText)"
    }
}
