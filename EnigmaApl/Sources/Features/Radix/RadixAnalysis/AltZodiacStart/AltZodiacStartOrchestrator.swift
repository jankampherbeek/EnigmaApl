// AltZodiacStartOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Orchestrates the calculation of positions in an alternative zodiac: one that starts
/// (0° of the first sign) at the ecliptic longitude of a user-chosen factor instead of
/// at the real vernal equinox point.
struct AltZodiacStartOrchestrator {
    private init() {}

    /// Converts a real ecliptic longitude into its position in the alternative zodiac.
    /// - Parameters:
    ///   - longitude: Real ecliptic longitude, must be >= 0 and < 360.
    ///   - zodiacStart: Real ecliptic longitude that defines 0° of the alternative zodiac.
    /// - Returns: The longitude within the alternative zodiac (0..<360), where every 30°
    ///   step corresponds to one of the 12 traditional sign glyphs, starting at Aries.
    static func shiftedLongitude(_ longitude: Double, zodiacStart: Double) -> Double {
        WheelGeometry.normalise(longitude - zodiacStart)
    }
}
