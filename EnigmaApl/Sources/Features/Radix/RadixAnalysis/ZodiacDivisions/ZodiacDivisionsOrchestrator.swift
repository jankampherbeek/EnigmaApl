// ZodiacDivisionsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Orchestrates the calculation of zodiac divisions (signs, decans, dodecatemoria, bounds).
struct ZodiacDivisionsOrchestrator {
    private init() {}

    /// Returns the index for the given longitude using the specified zodiac division method.
    /// - Parameters:
    ///   - longitude: Ecliptic longitude, must be >= 0 and < 360.
    ///   - method: The zodiac division method to apply.
    /// - Returns: The calculated index, or -1 if longitude is out of bounds.
    static func calculate(longitude: Double, method: ZodiacDivisionMethod) -> Int {
        switch method {
        case .signs:
            return ZodiacSign.indexForSign(longitude)
        case .decansPlanet:
            return DecanPlanets.indexForDecanPlanet(longitude)
        case .decansSign:
            return DecanSign.indexForDecanSign(longitude)
        case .dodecatsOriginal:
            return DodecatOriginal.indexForDodecat(longitude)
        case .dodecatsPaulus:
            return DodecatPaulus.indexForDodecat(longitude)
        case .boundsEgyptian:
            return Bounds.indexBound(longitude, egyptian: true)
        case .boundsPtolemy:
            return Bounds.indexBound(longitude, egyptian: false)
        }
    }
}
