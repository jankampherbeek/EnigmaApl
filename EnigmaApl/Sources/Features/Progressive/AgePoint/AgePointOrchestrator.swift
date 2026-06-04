// AgePointOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Orchestrates calculations for the Huber Age Point technique.
///
/// The Age Point starts at the Ascendant at birth and moves linearly through the 12 houses
/// in 72 years, spending exactly 6 years per house, then cycles back to the Ascendant.
struct AgePointOrchestrator {

    private let cycleDuration = 72.0
    private let houseDuration = 6.0   // 72 / 12 houses

    /// Returns the ecliptic longitude of the Age Point for a given age.
    ///
    /// - Parameters:
    ///   - age: Age in years (may exceed 72; the cycle repeats every 72 years).
    ///   - cusps: 12-element array of house-cusp longitudes (0-based: cusps[0] = house 1 = Ascendant).
    /// - Returns: Ecliptic longitude in degrees (0–360).
    func agePointLongitude(age: Double, cusps: [Double]) -> Double {
        guard cusps.count >= 12 else { return cusps.first ?? 0 }

        var aNorm = age.truncatingRemainder(dividingBy: cycleDuration)
        if aNorm < 0 { aNorm += cycleDuration }

        let houseIdx = min(Int(aNorm / houseDuration), 11)
        let fraction = (aNorm - Double(houseIdx) * houseDuration) / houseDuration
        let fromLong = cusps[houseIdx]
        let toLong   = cusps[(houseIdx + 1) % 12]

        var dist = toLong - fromLong
        if dist < 0 { dist += 360 }

        var position = fromLong + fraction * dist
        while position >= 360 { position -= 360 }
        while position < 0    { position += 360 }
        return position
    }

    /// Returns (years, months, totalYears) for the age at which the Age Point
    /// reaches the given longitude.
    ///
    /// - Parameters:
    ///   - longitude: Target ecliptic longitude (0–360).
    ///   - cusps: 12-element array of house-cusp longitudes (0-based).
    /// - Returns: Tuple with whole years, remaining months, and decimal total years.
    func ageFromLongitude(longitude: Double, cusps: [Double]) -> (years: Int, months: Int, totalYears: Double) {
        guard cusps.count >= 12 else { return (0, 0, 0) }

        for houseIdx in 0..<12 {
            let fromLong = cusps[houseIdx]
            let toLong   = cusps[(houseIdx + 1) % 12]
            var dist = toLong - fromLong
            if dist < 0 { dist += 360 }

            var diff = longitude - fromLong
            if diff < 0 { diff += 360 }

            if dist > 0 && diff >= 0 && diff <= dist {
                let fraction   = diff / dist
                let totalYears = Double(houseIdx) * houseDuration + fraction * houseDuration
                let wholeYears = Int(totalYears)
                let months     = Int((totalYears - Double(wholeYears)) * 12)
                return (wholeYears, months, totalYears)
            }
        }
        return (0, 0, 0)
    }
}
