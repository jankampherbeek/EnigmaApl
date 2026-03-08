//
//  GlyphSelector.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 08/03/2026.
//

/// Select a glyph
struct GlyphSelector {
    private init() {}

    /// Select a glyph for an aspect
    static func getGlyphForAspect(_ aspect: Aspects) -> String {
        AspectGlyphs.glyph(for: aspect)
    }

    /// Select a glyph for a factor
    static func getGlyphForFactor(_ factor: Factors) -> String {
        FactorGlyphs.glyph(for: factor)
    }

    /// Select a glyph for a sign
    static func getGlyphForSign(_ sign: Signs) -> String {
        SignGlyphs.glyph(for: sign)
    }
}
