// GlyphOverviewModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

struct GlyphOverviewEntry: Identifiable {
    let id: Int
    let glyph: String
    let name: String
}

/// Model for GlyphOverviewScreen: the currently active glyph (standard or user-customized
/// via GlyphsConfig) for every factor, aspect and sign, together with its display name.
struct GlyphOverviewModel {
    let factorEntries: [GlyphOverviewEntry] = Factors.selectableCases.map { factor in
        GlyphOverviewEntry(
            id: factor.rawValue,
            glyph: GlyphSelector.getGlyphForFactor(factor),
            name: NSLocalizedString(factor.localizedName, comment: "")
        )
    }

    let aspectEntries: [GlyphOverviewEntry] = Aspects.allCases.map { aspect in
        GlyphOverviewEntry(
            id: aspect.rawValue,
            glyph: GlyphSelector.getGlyphForAspect(aspect),
            name: NSLocalizedString(aspect.rbKey, comment: "")
        )
    }

    let otherEntries: [GlyphOverviewEntry] = Signs.allCases.map { sign in
        GlyphOverviewEntry(
            id: sign.rawValue,
            glyph: GlyphSelector.getGlyphForSign(sign),
            name: NSLocalizedString(sign.rbKey, comment: "")
        )
    }
}
