// CountingsLabels.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftUI

/// Localized labels and colors for `CountingsGroup`.
enum CountingsLabels {
    private static func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Countings", bundle: .main, comment: "")
    }

    static func groupLabel(_ group: CountingsGroup) -> String {
        switch group {
        case .cardinal: return t(CountingsKeys.groupCardinal)
        case .fixed: return t(CountingsKeys.groupFixed)
        case .mutable: return t(CountingsKeys.groupMutable)
        case .fire: return t(CountingsKeys.groupFire)
        case .earth: return t(CountingsKeys.groupEarth)
        case .air: return t(CountingsKeys.groupAir)
        case .water: return t(CountingsKeys.groupWater)
        }
    }

    /// Fixed, non-cycled color per group — traditional astrological element/cross colors.
    static func groupColor(_ group: CountingsGroup) -> Color {
        switch group {
        case .cardinal: return .orange
        case .fixed: return .indigo
        case .mutable: return .teal
        case .fire: return .red
        case .earth: return .brown
        case .air: return .yellow
        case .water: return .blue
        }
    }
}
