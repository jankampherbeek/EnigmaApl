// ProgressiveMethods.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Supported progressive techniques.
public enum ProgressiveMethods: Int, CaseIterable {
    case transit    = 0
    case secdir     = 1
    case symdir     = 2
    case primdir    = 3
    case solar      = 4
    case profection = 5
    case firdaria   = 6

    /// Resource bundle key for localized name.
    var rbKey: String {
        switch self {
        case .transit:    return "enum.progressivemethod.transit"
        case .secdir:     return "enum.progressivemethod.secdir"
        case .symdir:     return "enum.progressivemethod.symdir"
        case .primdir:    return "enum.progressivemethod.primdir"
        case .solar:      return "enum.progressivemethod.solar"
        case .profection: return "enum.progressivemethod.profection"
        case .firdaria:   return "enum.progressivemethod.firdaria"
        }
    }
}
