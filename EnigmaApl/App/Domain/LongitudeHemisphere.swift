// LongitudeHemisphere.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

// Directions in longitude: east and west
enum LongitudeHemisphere: CaseIterable, Identifiable, Hashable {
    case east
    case west

    var id: Self { self }
    var rbKey: String { LongitudeHemisphereKeys.key(for: self) }
}
