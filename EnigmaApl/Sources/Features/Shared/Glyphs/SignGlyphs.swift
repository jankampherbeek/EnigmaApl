//
//  SignGlyphs.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 08/03/2026.
//

/// Default Unicode glyphs for zodiac signs.
/// Use GlyphSelector to retrieve glyphs; it falls back to these defaults
/// when no override is defined in the configuration.
struct SignGlyphs {
    private init() {}

    static let glyphs: [Signs: String] = [
        .Aries:       "\u{E000}",   
        .Taurus:      "\u{E001}",   
        .Gemini:      "\u{E002}",   
        .Cancer:      "\u{E003}",   
        .Leo:         "\u{E004}",   
        .Virgo:       "\u{E005}",   
        .Libra:       "\u{E006}",   
        .Scorpio:     "\u{E007}",   
        .Sagittarius: "\u{E008}",   
        .Capricorn:   "\u{E009}",   
        .Aquarius:    "\u{E010}",   
        .Pisces:      "\u{E011}",   
    ]

    /// Returns the glyph for a sign, or an empty string if none is defined.
    static func glyph(for sign: Signs) -> String {
        glyphs[sign] ?? ""
    }
}
