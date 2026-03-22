//
//  GlyphSelector.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 08/03/2026.
//

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
    /// Call this on app launch and whenever the active configuration changes.
    static func configure(with glyphsConfig: GlyphsConfig) {
        factorMap = Dictionary(uniqueKeysWithValues: glyphsConfig.factorGlyphs.map { ($0.factor, $0.glyph) })
        signMap   = Dictionary(uniqueKeysWithValues: glyphsConfig.signGlyphs.map   { ($0.sign,   $0.glyph) })
        aspectMap = Dictionary(uniqueKeysWithValues: glyphsConfig.aspectGlyphs.map { ($0.aspect, $0.glyph) })
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
