// ZodiacSign.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Returns the sign index for a given ecliptic longitude.
struct ZodiacSign {
    private init() {}

    /// - Returns: 0 (Aries) … 11 (Pisces), or -1 if longitude is out of bounds.
    static func indexForSign(_ longitude: Double) -> Int {
        guard longitude >= 0.0, longitude < 360.0 else { return -1 }
        return Int(longitude / 30.0)
    }
}
