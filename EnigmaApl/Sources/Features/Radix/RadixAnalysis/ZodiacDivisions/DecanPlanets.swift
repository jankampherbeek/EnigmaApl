// DecanPlanets.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Returns the planetary ruler index for a decan (10° arc), cycling through the Chaldean order.
/// Ruler indices: Sun 0, Moon 1, Mercury 2, Venus 3, Mars 4, Jupiter 5, Saturn 6.
/// Sequence starts with Mars (Bouché-Leclercq): 4, 0, 3, 2, 1, 6, 5, …
struct DecanPlanets {
    private init() {}

    private static let planets = [4, 0, 3, 2, 1, 6, 5]

    /// - Returns: Planet index (0–6), or -1 if longitude is out of bounds.
    static func indexForDecanPlanet(_ longitude: Double) -> Int {
        guard longitude >= 0.0, longitude < 360.0 else { return -1 }
        let decanIndex = Int(longitude / 10.0)
        return planets[decanIndex % planets.count]
    }
}
