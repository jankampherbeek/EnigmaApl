// LatitudeHemisphere.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

// Directions in latitude: north and south
enum LatitudeHemisphere: CaseIterable, Identifiable, Hashable {
    case north
    case south

    var id: Self { self }
    var rbKey: String { LatitudeHemisphereKeys.key(for: self) }
}
