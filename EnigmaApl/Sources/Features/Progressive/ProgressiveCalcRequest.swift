// ProgressiveCalcRequest.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Request for a progressive calculation.
/// Contains the Julian Day and the progressive method to apply.
public struct ProgressiveCalcRequest {
    public let julianDay: Double
    public let method: ProgressiveMethods

    public init(julianDay: Double, method: ProgressiveMethods) {
        self.julianDay = julianDay
        self.method = method
    }
}
