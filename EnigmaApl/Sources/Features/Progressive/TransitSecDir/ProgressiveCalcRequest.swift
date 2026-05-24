// ProgressiveCalcRequest.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Request for a progressive calculation (transits, secondary directions).
/// Contains only the Julian Day; all other settings are derived from the configuration.
public struct ProgressiveCalcRequest {
    public let julianDay: Double

    public init(julianDay: Double) {
        self.julianDay = julianDay
    }
}
