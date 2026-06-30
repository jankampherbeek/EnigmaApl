// FixStarSelections.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

public enum FixStarSelections: Codable, CaseIterable {
    case ptolemy
    case robson
    case brady
    case magnitude
    case selfDefined

    var rbKey: String {
        switch self {
        case .ptolemy:     return "enum.fixstarselections.ptolemy"
        case .robson:      return "enum.fixstarselections.robson"
        case .brady:       return "enum.fixstarselections.brady"
        case .magnitude:   return "enum.fixstarselections.magnitude"
        case .selfDefined: return "enum.fixstarselections.selfdefined"
        }
    }
}
