//
//  AspectGlyphs.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 08/03/2026.
//

/// Default Unicode glyphs for astrological aspects.
/// Use GlyphSelector to retrieve glyphs; it falls back to these defaults
/// when no override is defined in the configuration.
struct AspectGlyphs {
    private init() {}

    static let glyphs: [Aspects: String] = [
        .conjunction:     "\u{E700}",   
        .opposition:      "\u{E710}",   
        .trine:           "\u{E720}",   
        .square:          "\u{E730}",   
        .septile:         "\u{E810}",   
        .sextile:         "\u{E740}",   
        .quintile:        "\u{E790}",   
        .semisextile:     "\u{E750}",   
        .semisquare:      "\u{E770}",   
        .semiquintile:    "\u{E830}",   
        .biquintile:      "\u{E800}",   
        .inconjunct:      "\u{E760}",   
        .sesquiquadrate:  "\u{E780}",   
        .tridecile:       "\u{E840}",   
        .biseptile:       "\u{E850}",   
        .triseptile:      "\u{E860}",   
        .novile:          "\u{E870}",   
        .binovile:        "\u{E880}",   
        .quadranovile:    "\u{E890}",   
        .undecile:        "\u{E900}",   
        .centile:         "\u{E910}",   
        .vigintile:       "\u{E820}",   
    ]

    /// Returns the glyph for an aspect, or an empty string if none is defined.
    static func glyph(for aspect: Aspects) -> String {
        glyphs[aspect] ?? ""
    }
}
