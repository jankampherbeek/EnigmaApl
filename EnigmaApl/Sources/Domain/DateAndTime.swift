// DateAndTime.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

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
        let rawHour   = Int(HourDecimal)
        let rawMinute = Int((HourDecimal - Double(rawHour)) * 60.0)
        // lround can produce 60 when the fractional part is ≥ 59.5 seconds;
        // carry the overflow up through minutes and hours.
        var sec = lround(((HourDecimal - Double(rawHour)) * 60.0 - Double(rawMinute)) * 60.0)
        var min = rawMinute
        var hr  = rawHour
        if sec >= 60 { sec -= 60; min += 1 }
        if min >= 60 { min -= 60; hr  += 1 }
        self.Hour   = hr
        self.Minute = min
        self.Second = sec
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
