// EnneagramData.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Result for one enneagram type: type number (1-9) and its cumulative strength.
struct EnneagramTypeResult: Identifiable {
    let id = UUID()
    let type: Int
    let strength: Double
}

/// A detail line showing one factor's contribution across all 9 enneagram types.
struct EnneagramDetailLine: Identifiable {
    let id = UUID()
    /// The astrological factor, or nil for Ascendant / MC.
    let factor: Factors?
    /// Display label used when factor is nil.
    let specialLabel: String
    /// Sign or house number (1–12).
    let positionIndex: Int
    /// true = position in sign; false = position in house.
    let inSigns: Bool
    /// Multipliers for types 1–9.
    let typeValues: [Double]
}
