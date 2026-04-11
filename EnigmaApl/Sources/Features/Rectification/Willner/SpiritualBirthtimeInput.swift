// SpiritualBirthtimeInput.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// All input data required for the Spiritual Birthtime (Moment of Incarnation) calculation.
public struct SpiritualBirthtimeInput {
    /// Birth year (astronomical, so there is a year zero).
    public let year: Int
    /// Birth month (1–12).
    public let month: Int
    /// Birth day (1–31).
    public let day: Int
    /// Birth hour in 24-hour format (0–23).
    public let hour: Int
    /// Birth minute (0–59).
    public let minute: Int
    /// Birth second (0–59).
    public let second: Int
    /// Time zone offset in hours east of Greenwich (negative = west).
    public let timeZone: Double
    /// Geographic latitude in decimal degrees (positive = north, negative = south).
    public let geoLatitude: Double
    /// Geographic longitude in decimal degrees (positive = east, negative = west).
    public let geoLongitude: Double

    public init(year: Int, month: Int, day: Int,
                hour: Int, minute: Int, second: Int,
                timeZone: Double,
                geoLatitude: Double, geoLongitude: Double) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.timeZone = timeZone
        self.geoLatitude = geoLatitude
        self.geoLongitude = geoLongitude
    }
}
