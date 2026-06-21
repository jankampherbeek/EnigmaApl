// EphemerisRow.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

struct EphemerisRow: Identifiable {
    let id: Int
    let julianDay: Double
    let positions: [Factors: FullFactorPosition]

    func value(for factor: Factors, coordinate: EphemerisCoordinate) -> Double? {
        guard let pos = positions[factor] else { return nil }
        switch coordinate {
        case .longitude:        return pos.ecliptical.first?.mainPos
        case .latitude:         return pos.ecliptical.first?.deviation
        case .rightAscension:   return pos.equatorial.first?.mainPos
        case .declination:      return pos.equatorial.first?.deviation
        case .distance:         return pos.ecliptical.first?.distance
        case .speedLongitude:   return pos.ecliptical.first?.mainPosSpeed
        case .speedDeclination: return pos.equatorial.first?.deviationSpeed
        }
    }
}
