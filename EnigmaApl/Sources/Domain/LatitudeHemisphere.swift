//
//  LatitudeHemisphere.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 04/03/2026.
//

// Directions in latitude: north and south
enum LatitudeHemisphere: String, CaseIterable, Identifiable {
    case north = "enum.latitudehemisphere.north"
    case south = "enum.latitudehemisphere.south"
    var id: String { rawValue }
}
