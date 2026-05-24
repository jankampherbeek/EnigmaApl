// ProgressivePosition.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Ecliptical longitude and equatorial declination for one factor in a progressive calculation.
public struct ProgressivePosition {
    /// Ecliptical longitude in degrees (0–360).
    public let longitude: Double
    /// Declination in degrees, negative for southern declination.
    public let declination: Double

    public init(longitude: Double, declination: Double) {
        self.longitude = longitude
        self.declination = declination
    }
}
