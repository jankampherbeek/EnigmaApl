//
//  DSTOption.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 06/03/2026.
//

enum DSTOption: String, CaseIterable, Identifiable {
    case dst = "enum.dstoption.dst"
    case noDST = "enum.dstoption.nodst"
    var id: String { rawValue }
}
