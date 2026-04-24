// ResearchInputRecord.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// One row from the horoscope_data SQLite table — represents a single chart to calculate.
/// `isData = true` means real research data; `false` means control-group data.
public struct ResearchInputRecord: Sendable {
    public let id: Int
    public let isData: Bool
    public let geoLat: Double
    public let geoLon: Double
    public let year: Int
    public let month: Int
    public let day: Int
    public let hour: Int
    public let minute: Int
    public let second: Int
    /// UTC offset in hours (e.g. +2.0 for CEST).
    public let offset: Double

    public init(
        id: Int,
        isData: Bool,
        geoLat: Double,
        geoLon: Double,
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int,
        offset: Double
    ) {
        self.id = id
        self.isData = isData
        self.geoLat = geoLat
        self.geoLon = geoLon
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.offset = offset
    }
}
