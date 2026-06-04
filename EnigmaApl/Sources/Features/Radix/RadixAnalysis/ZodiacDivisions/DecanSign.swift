// DecanSign.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Returns the sign index for a decan (10° arc) based on the triplicity method.
/// The first decan of each sign maps to that sign; each subsequent decan adds 4 signs (mod 12).
struct DecanSign {
    private init() {}

    /// - Returns: Sign index 0 (Aries) … 11 (Pisces), or -1 if longitude is out of bounds.
    static func indexForDecanSign(_ longitude: Double) -> Int {
        guard longitude >= 0.0, longitude < 360.0 else { return -1 }
        let signIndex = Int(longitude / 30.0)
        let decanWithinSign = Int((longitude.truncatingRemainder(dividingBy: 30.0)) / 10.0)
        var result = signIndex + decanWithinSign * 4
        if result > 11 { result -= 12 }
        return result
    }
}
