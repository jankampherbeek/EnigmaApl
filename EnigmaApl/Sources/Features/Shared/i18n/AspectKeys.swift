//
//  AspectKeys.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 11/03/2026.
//

/// Localization keys for Aspects enum values.
struct AspectKeys {
    private init() {}

    static let keys: [Aspects: String] = [
        .conjunction:    "enum.aspects.conjunction",
        .opposition:     "enum.aspects.oppposition",
        .trine:          "enum.aspects.trine",
        .square:         "enum.aspects.square",
        .septile:        "enum.aspects.septile",
        .sextile:        "enum.aspects.sextile",
        .quintile:       "enum.aspects.quintile",
        .semisextile:    "enum.aspects.semisextile",
        .semisquare:     "enum.aspects.semisquare",
        .semiquintile:   "enum.aspects.semiquintile",
        .biquintile:     "enum.aspects.biquintile",
        .inconjunct:     "enum.aspects.inconjunct",
        .sesquiquadrate: "enum.aspects.sesquiquadrate",
        .tridecile:      "enum.aspects.tridecile",
        .biseptile:      "enum.aspects.biseptile",
        .triseptile:     "enum.aspects.triseptile",
        .novile:         "enum.aspects.novile",
        .binovile:       "enum.aspects.binovile",
        .quadranovile:   "enum.aspects.quadranovile",
        .undecile:       "enum.aspects.undecile",
        .centile:        "enum.aspects.centile",
        .vigintile:      "enum.aspects.vigintile",
    ]

    static func key(for aspect: Aspects) -> String {
        keys[aspect] ?? ""
    }
}
