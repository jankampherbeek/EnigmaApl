// DodecatOriginal.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Returns the sign index for the dodecatemoria in the original (Babylonian) method.
/// Each sign is divided into 12 sub-portions of 2.5°; the first maps to the sign itself,
/// each subsequent sub-portion advances one sign (mod 12).
struct DodecatOriginal {
    private init() {}

    /// - Returns: Sign index 0 (Aries) … 11 (Pisces), or -1 if longitude is out of bounds.
    static func indexForDodecat(_ longitude: Double) -> Int {
        guard longitude >= 0.0, longitude < 360.0 else { return -1 }
        let signIndex = Int(longitude / 30.0)
        let subportion = Int(longitude.truncatingRemainder(dividingBy: 30.0) / 2.5)
        var result = signIndex + subportion
        if result > 11 { result -= 12 }
        return result
    }
}
