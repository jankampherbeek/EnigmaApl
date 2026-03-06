//
//  UTOffsetDirection.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 06/03/2026.
//
enum UTOffsetDirection: String, CaseIterable, Identifiable {
    case later = "enum.utoffsetdirection.later"
    case earlier = "enum.utoffsetdirection.earlier"
    var id: String { rawValue }
}
