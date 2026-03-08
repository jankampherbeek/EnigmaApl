//
//  FactorGlyphs.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 08/03/2026.
//

/// Default Unicode glyphs for astrological factors.
/// Use GlyphSelector to retrieve glyphs; it falls back to these defaults
/// when no override is defined in the configuration.
struct FactorGlyphs {
    private init() {}
    
    static let glyphs: [Factors: String] = [
        .sun:                   "\u{E200}",   
        .moon:                  "\u{E201}",   
        .mercury:               "\u{E202}",   
        .venus:                 "\u{E203}",   
        .earth:                 "\u{E204}",   
        .mars:                  "\u{E205}",   
        .jupiter:               "\u{E206}",   
        .saturn:                "\u{E207}",   
        .uranus:                "\u{E208}",   
        .neptune:               "\u{E209}",   
        .pluto:                 "\u{E210}",   
        .northNode:             "\u{E520}",   
        .chiron:                "\u{E400}",   
        .persephoneRam:         "\u{E608}",   
        .hermesRam:             "\u{E609}",   
        .demeterRam:            "\u{E610}",   
        .cupidoUra:             "\u{E600}",   
        .hadesUra:              "\u{E601}",   
        .zeusUra:               "\u{E602}",   
        .kronosUra:             "\u{E603}",   
        .apollonUra:            "\u{E604}",   
        .admetosUra:            "\u{E605}",   
        .vulcanusUra:           "\u{E606}",   
        .poseidonUra:           "\u{E607}",   
        .eris:                  "\u{E407}",   
        .pholus:                "\u{E402}",   
        .ceres:                 "\u{E411}",   
        .pallas:                "\u{E412}",   
        .juno:                  "\u{E413}",   
        .vesta:                 "\u{E414}",   
        .isis:                  "\u{E611}",   
        .nessus:                "\u{E401}",   
        .huya:                  "\u{E417}",   
        .varuna:                "\u{E403}",   
        .ixion:                 "\u{E404}",   
        .quaoar:                "\u{E405}",   
        .haumea:                "\u{E406}",   
        .orcus:                 "\u{E409}",   
        .makemake:              "\u{E410}",   
        .sedna:                 "\u{E408}",   
        .hygieia:               "\u{E415}",   
        .astraea:               "\u{E416}",   
        .apogeeMean:            "\u{E530}",   
        .apogeeCorrected:       "\u{E531}",   
        .apogeeInterpolated:    "\u{E531}",   
        .persephoneCarteret:    "\u{E612}",   
        .vulcanusCarteret:      "\u{E613}",   
        .perigeeInterpolated:   "\u{2609}",   // TODO add glyph for perigee
        .priapus:               "\u{E535}",
        .priapusCorrected:      "\u{2609}",   // TODO add glyph for Priapus corrected
        .dragon:                "\u{2609}",   // TODO add glyph for Dragon
        .beast:                 "\u{2609}",   // TODO add glyph for Beast
        .southNode:             "\u{E521}",
        .blackSun:              "\u{E534}",   
        .diamond:               "\u{E536}",   
        .ascendant:             "\u{E500}",   
        .mc:                    "\u{E501}",   
        .eastPoint:             "\u{E503}",   
        .vertex:                "\u{E502}",   
        .zeroAries:             "\u{E000}",
        .parsfortuna:           "\u{F400}",
    ]

    /// Returns the glyph for a factor, or an empty string if none is defined.
    static func glyph(for factor: Factors) -> String {
        glyphs[factor] ?? ""
    }
}
