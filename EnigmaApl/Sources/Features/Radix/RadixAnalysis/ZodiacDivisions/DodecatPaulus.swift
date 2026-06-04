// DodecatPaulus.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Returns the sign index for the dodecatemoria according to Paulus Alexandrinus (13th harmonic).
struct DodecatPaulus {
    private init() {}

    /// - Returns: Sign index 0 (Aries) … 11 (Pisces), or -1 if longitude is out of bounds.
    static func indexForDodecat(_ longitude: Double) -> Int {
        guard longitude >= 0.0, longitude < 360.0 else { return -1 }
        var multiplied = longitude * 13.0
        multiplied = multiplied.truncatingRemainder(dividingBy: 360.0)
        if multiplied < 0.0 { multiplied += 360.0 }
        return Int(multiplied / 30.0)
    }
}
