// GeoCoordinateConversion.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Shared degrees/minutes/seconds <-> decimal-degrees conversion for the
/// exchange-format parsers (QCK, AAF'97, Astro-Databank XML). Each format has
/// its own textual coordinate syntax, but they all resolve to this same
/// arithmetic and to the same validation ranges used by the Enigma domain
/// model (`HoroscopeModel.latitude`/`.longitude`: decimal degrees, West/South negative).
enum GeoCoordinateConversion {

    /// Converts degrees/minutes/seconds into decimal degrees. `isPositiveDirection`
    /// is true for North/East, false for South/West.
    static func decimalDegrees(degrees: Int, minutes: Int, seconds: Int, isPositiveDirection: Bool) -> Double {
        let magnitude = Double(degrees) + Double(minutes) / 60.0 + Double(seconds) / 3600.0
        return isPositiveDirection ? magnitude : -magnitude
    }

    static func isValidLongitude(degrees: Int, minutes: Int, seconds: Int) -> Bool {
        degrees >= 0 && degrees <= 180 && minutes >= 0 && minutes <= 59 && seconds >= 0 && seconds <= 59
    }

    static func isValidLatitude(degrees: Int, minutes: Int, seconds: Int) -> Bool {
        degrees >= 0 && degrees <= 90 && minutes >= 0 && minutes <= 59 && seconds >= 0 && seconds <= 59
    }

    /// Splits a decimal-degree value back into non-negative degrees/minutes/seconds
    /// plus a direction flag, for writers that emit DMS text.
    static func components(fromDecimalDegrees value: Double) -> (degrees: Int, minutes: Int, seconds: Int, isPositiveDirection: Bool) {
        let isPositiveDirection = value >= 0
        let magnitude = abs(value)
        let degrees = Int(magnitude)
        let minutesDecimal = (magnitude - Double(degrees)) * 60.0
        let minutes = Int(minutesDecimal)
        var seconds = Int(((minutesDecimal - Double(minutes)) * 60.0).rounded())
        var carriedMinutes = minutes
        var carriedDegrees = degrees
        if seconds >= 60 { seconds -= 60; carriedMinutes += 1 }
        if carriedMinutes >= 60 { carriedMinutes -= 60; carriedDegrees += 1 }
        return (carriedDegrees, carriedMinutes, seconds, isPositiveDirection)
    }
}
