//
//  LongitudeHemisphere.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 04/03/2026.
//

// Directions in longitude: east and west
enum LongitudeHemisphere: String, CaseIterable, Identifiable {
    case east = "enum.longitudehemisphere.east"
    case west =  "enum.longitudehemisphere.west"
    var id: String { rawValue }
}
