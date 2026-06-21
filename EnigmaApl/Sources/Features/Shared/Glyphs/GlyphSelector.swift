// GlyphSelector.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Provides glyphs for signs, factors and aspects from the active configuration.
///
/// On startup the static maps are pre-loaded with the default glyphs from
/// `GlyphsConfig`. Call `configure(with:)` whenever the active configuration
/// is loaded or changed to apply the user's glyph selections.
struct GlyphSelector {
    private init() {}

    private static var factorMap: [Factors: String] =
        Dictionary(uniqueKeysWithValues: GlyphsConfig.defaultFactorGlyphs.map { ($0.factor, $0.glyph) })

    private static var signMap: [Signs: String] =
        Dictionary(uniqueKeysWithValues: GlyphsConfig.defaultSignGlyphs.map { ($0.sign, $0.glyph) })

    private static var aspectMap: [Aspects: String] =
        Dictionary(uniqueKeysWithValues: GlyphsConfig.defaultAspectGlyphs.map { ($0.aspect, $0.glyph) })

    /// Updates the glyph maps from the active configuration.
    /// Starts from the current defaults so that factors added after a config was saved
    /// still have their default glyph available; user overrides take precedence.
    static func configure(with glyphsConfig: GlyphsConfig) {
        var fMap = Dictionary(uniqueKeysWithValues: GlyphsConfig.defaultFactorGlyphs.map { ($0.factor, $0.glyph) })
        for s in glyphsConfig.factorGlyphs where GlyphCandidates.candidates(for: s.factor).count > 1 {
            fMap[s.factor] = s.glyph
        }
        factorMap = fMap

        var sMap = Dictionary(uniqueKeysWithValues: GlyphsConfig.defaultSignGlyphs.map { ($0.sign, $0.glyph) })
        for s in glyphsConfig.signGlyphs where GlyphCandidates.candidates(for: s.sign).count > 1 {
            sMap[s.sign] = s.glyph
        }
        signMap = sMap

        var aMap = Dictionary(uniqueKeysWithValues: GlyphsConfig.defaultAspectGlyphs.map { ($0.aspect, $0.glyph) })
        for s in glyphsConfig.aspectGlyphs where GlyphCandidates.candidates(for: s.aspect).count > 1 {
            aMap[s.aspect] = s.glyph
        }
        aspectMap = aMap
    }

    /// Returns the glyph for an aspect from the active configuration.
    static func getGlyphForAspect(_ aspect: Aspects) -> String {
        aspectMap[aspect] ?? "?"
    }

    /// Returns the glyph for a factor from the active configuration.
    static func getGlyphForFactor(_ factor: Factors) -> String {
        factorMap[factor] ?? "?"
    }

    /// Returns the glyph for a sign from the active configuration.
    static func getGlyphForSign(_ sign: Signs) -> String {
        signMap[sign] ?? "?"
    }
}
