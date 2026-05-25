// ProgressiveCalcRequest.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Request for a progressive calculation.
/// Contains the Julian Day, the progressive method, and — for techniques that
/// require the natal date (e.g. secondary directions) — the natal Julian Day.
public struct ProgressiveCalcRequest {
    /// Julian Day of the event (target date for the progression).
    public let julianDay: Double
    public let method: ProgressiveMethods
    /// Julian Day of the natal chart. Required for secondary directions and other
    /// age-based techniques; `nil` for transits and similar techniques.
    public let natalJulianDay: Double?

    public init(julianDay: Double, method: ProgressiveMethods, natalJulianDay: Double? = nil) {
        self.julianDay = julianDay
        self.method = method
        self.natalJulianDay = natalJulianDay
    }
}
