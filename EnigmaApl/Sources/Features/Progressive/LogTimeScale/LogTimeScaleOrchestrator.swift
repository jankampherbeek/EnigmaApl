// LogTimeScaleOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Orchestrates calculations for Tad Mann's Logarithmic Time Scale.
struct LogTimeScaleOrchestrator {

    private let Z = 0.0766835

    /// Calculates the age in years corresponding to a planetary position
    /// according to Tad Mann's Logarithmic Time Scale.
    ///
    /// - Parameters:
    ///   - position: Planet position in decimal degrees (0–360, from 0° Aries)
    ///   - ascendant: Ascendant position in decimal degrees (0–360, from 0° Aries)
    /// - Returns: Age in years (decimal)
    func mannAgeFromPosition(position: Double, ascendant: Double) -> Double {
        // Steps 1 & 2: degree difference, corrected to positive value
        var diff = position - ascendant
        if diff < 0 { diff += 360 }

        // Step 3: add the gestation arc (120° = 9th house cusp to Ascendant)
        let withGestation = diff + 120

        // Step 4: divide by 120
        let divided = withGestation / 120

        // Steps 5 & 6: antilog base 10
        let antilog = pow(10, divided)

        // Step 7: subtract 10 (conception = 10 lunar months)
        let shifted = antilog - 10

        // Step 8: multiply by Z to obtain age in years
        return shifted * Z
    }

    /// Returns the age broken down into whole years and months, alongside the total decimal age.
    func mannAgeDetailed(position: Double, ascendant: Double) -> (years: Int, months: Int, totalYears: Double) {
        let totalYears = mannAgeFromPosition(position: position, ascendant: ascendant)
        let wholeYears = Int(totalYears)
        let months = Int((totalYears - Double(wholeYears)) * 12)
        return (wholeYears, months, totalYears)
    }

    /// Calculates the horoscope position in degrees corresponding to an age in years
    /// according to Tad Mann's Logarithmic Time Scale.
    ///
    /// - Parameters:
    ///   - age: Age in years (decimal)
    ///   - ascendant: Ascendant position in decimal degrees (0–360, from 0° Aries)
    /// - Returns: Position in decimal degrees (0–360, from 0° Aries)
    func mannPositionFromAge(age: Double, ascendant: Double) -> Double {
        // Reverse step 7: divide by Z and add 10
        let antilog = (age / Z) + 10

        // Reverse steps 5 & 6: log base 10
        let divided = log10(antilog)

        // Reverse step 4: multiply by 120
        let withGestation = divided * 120

        // Reverse step 3: subtract the gestation arc
        let diff = withGestation - 120

        // Reverse steps 1 & 2: add Ascendant and normalise to 0–360
        var position = ascendant + diff
        while position >= 360 { position -= 360 }
        while position < 0    { position += 360 }

        return position
    }
}
