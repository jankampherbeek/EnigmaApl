// SymbolicKeys.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// The method used for symbolic directions.
public enum SymbolicKeys: Int, CaseIterable, Codable {
    case trueSun    = 0
    case meanSun    = 1
    case oneDegree  = 2

    var rbKey: String {
        switch self {
        case .trueSun:   return "enum.symbolicmethod.truesun"
        case .meanSun:   return "enum.symbolicmethod.meansun"
        case .oneDegree: return "enum.symbolicmethod.onedegree"
        }
    }
}
