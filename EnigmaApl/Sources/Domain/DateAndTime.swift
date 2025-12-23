//
//  DateAndTime.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 20/12/2025.
//

import Foundation

/// Date for astronomical calculations.
/// Assumes the astronomical calendar, so there is a year zero and years BCE should subtract 1 to get the astronomicall date.
/// Gregorian indicates the calender: true (default) is Gregorian calendar, toherwise the Julian calendar is used.
public struct AstronomicalDate {
    public let Year: Int
    public let Month: Int
    public let Day: Int
    public let Gregorian: Bool
    
    public init(Year: Int, Month: Int, Day: Int, Gregorian: Bool = true) {
        self.Year = Year
        self.Month = Month
        self.Day = Day
        self.Gregorian = Gregorian
    }
}

/// Time for all purposes, including astronomical. No timezone is supplied, for astronomical calculations always use UT.
public struct AstronomicalTime {
    public let Hour: Int
    public let Minute: Int
    public let Second: Int
    public let HourDecimal: Double
    
    public init(Hour: Int, Minute: Int, Second: Int) {
        self.Hour = Hour
        self.Minute = Minute
        self.Second = Second
        self.HourDecimal = Double(Hour) + Double(Minute) / 60.0 + Double(Second) / 3600.0
    }
    
    public init (HourDecimal: Double) {
        self.HourDecimal = HourDecimal
        let hour = Int(HourDecimal)
        let minute = Int((HourDecimal - Double(hour)) * 60.0)
        let second = lround(((HourDecimal - Double(hour)) * 60.0 - Double(minute)) * 60.0)
        self.Hour = hour
        self.Minute = minute
        self.Second = second
    }
    
}

/// Astronomical date and timne
public struct AstronomicalDateTime {
    public let Date: AstronomicalDate
    public let Time: AstronomicalTime
    
    public init(Date: AstronomicalDate, Time: AstronomicalTime) {
        self.Date = Date
        self.Time = Time
    }
}
