//
//  LongitudeHemisphere.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 04/03/2026.
//

// Directions in longitude: east and west
enum LongitudeHemisphere: CaseIterable, Identifiable, Hashable {
    case east
    case west

    var id: Self { self }
    var rbKey: String { LongitudeHemisphereKeys.key(for: self) }
}
