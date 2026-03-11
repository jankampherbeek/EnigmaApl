//
//  LatitudeHemisphere.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 04/03/2026.
//

// Directions in latitude: north and south
enum LatitudeHemisphere: CaseIterable, Identifiable, Hashable {
    case north
    case south

    var id: Self { self }
    var rbKey: String { LatitudeHemisphereKeys.key(for: self) }
}
