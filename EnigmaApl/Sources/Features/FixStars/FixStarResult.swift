// FixStarResult.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// The result of a fixed star calculation.
public struct FixStarResult {
    public let starName: String
    public let magnitude: Double
    public let longitude: Double
    public let latitude: Double
    public let declination: Double

    public init(starName: String, magnitude: Double, longitude: Double, latitude: Double, declination: Double) {
        self.starName = starName
        self.magnitude = magnitude
        self.longitude = longitude
        self.latitude = latitude
        self.declination = declination
    }
}
