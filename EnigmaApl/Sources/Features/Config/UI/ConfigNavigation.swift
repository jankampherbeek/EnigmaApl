// ConfigNavigation.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Combine

// MARK: - Config Section

enum ConfigSection: String, CaseIterable, Identifiable, Hashable {
    case calculation
    case display
    case glyphs
    case factors
    case fixstars
    case aspects
    case orbs
    case progressions

    var id: String { rawValue }

    var rbKey: String {
        switch self {
        case .calculation:  return ConfigEditKeys.sectionCalculation
        case .display:      return ConfigEditKeys.sectionDisplay
        case .glyphs:       return ConfigEditKeys.sectionGlyphs
        case .factors:      return ConfigEditKeys.sectionFactors
        case .fixstars:     return ConfigEditKeys.sectionFixstars
        case .aspects:      return ConfigEditKeys.sectionAspects
        case .orbs:         return ConfigEditKeys.sectionOrbs
        case .progressions: return ConfigEditKeys.sectionProgressions
        }
    }

    var localizedName: String {
        NSLocalizedString(rbKey, tableName: "ConfigEdit", bundle: .main, comment: "")
    }

    var systemImage: String {
        switch self {
        case .calculation:  return "function"
        case .display:      return "paintpalette"
        case .glyphs:       return "character.textbox"
        case .factors:      return "sparkles"
        case .fixstars:     return "star"
        case .aspects:      return "angle"
        case .orbs:         return "circle.dashed"
        case .progressions: return "arrow.forward.circle"
        }
    }
}

// MARK: - Navigator

/// Manages the selected configuration in the config feature.
/// Held by AppComposition, injected as EnvironmentObject.
@MainActor
final class ConfigNavigator: ObservableObject {
    @Published var selectedConfig: UserConfiguration? = nil

    func select(_ config: UserConfiguration?) {
        selectedConfig = config
    }
}
