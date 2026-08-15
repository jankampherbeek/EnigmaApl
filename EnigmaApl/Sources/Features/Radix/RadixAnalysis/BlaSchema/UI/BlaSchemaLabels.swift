// BlaSchemaLabels.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftUI

/// Localized labels for the category enums shared across the BLA schema sub-screens.
enum BlaSchemaLabels {
    private static func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "BlaSchema", bundle: .main, comment: "")
    }

    static func groupLabel(_ group: CrossElementGroup) -> String {
        switch group {
        case .cardinal: return t(BlaSchemaKeys.groupCardinal)
        case .fixed: return t(BlaSchemaKeys.groupFixed)
        case .mutable: return t(BlaSchemaKeys.groupMutable)
        case .fire: return t(BlaSchemaKeys.groupFire)
        case .earth: return t(BlaSchemaKeys.groupEarth)
        case .air: return t(BlaSchemaKeys.groupAir)
        case .water: return t(BlaSchemaKeys.groupWater)
        }
    }

    static func detailLabel(_ kind: BlaDetailKind) -> String {
        switch kind {
        case .sisterSignAsc: return t(BlaSchemaKeys.detailSisterSignAsc)
        case .clampedHouses: return t(BlaSchemaKeys.detailClampedHouses)
        case .interceptedSigns: return t(BlaSchemaKeys.detailInterceptedSigns)
        case .groundNote: return t(BlaSchemaKeys.detailGroundNote)
        case .lordAscInHouses: return t(BlaSchemaKeys.detailLordAscInHouses)
        case .moonInHouse: return t(BlaSchemaKeys.detailMoonInHouse)
        }
    }

    /// Fixed, non-cycled color per group — traditional astrological element/cross colors,
    /// distinct enough for the two pie charts (Elements: fire/earth/air/water; Crosses: cardinal/fixed/mutable).
    static func groupColor(_ group: CrossElementGroup) -> Color {
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
