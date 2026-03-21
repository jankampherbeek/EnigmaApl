//
//  GlyphsConfig.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Foundation

/// Glyph selection for a single zodiac sign.
public struct SignGlyphSetting: Codable, Equatable {
    public let sign: Signs
    public let glyph: String

    public init(sign: Signs, glyph: String) {
        self.sign = sign
        self.glyph = glyph
    }
}

/// Glyph selection for a single celestial factor.
public struct FactorGlyphSetting: Codable, Equatable {
    public let factor: Factors
    public let glyph: String

    public init(factor: Factors, glyph: String) {
        self.factor = factor
        self.glyph = glyph
    }
}

/// Glyph selection for a single aspect.
public struct AspectGlyphSetting: Codable, Equatable {
    public let aspect: Aspects
    public let glyph: String

    public init(aspect: Aspects, glyph: String) {
        self.aspect = aspect
        self.glyph = glyph
    }
}

/// Configuration for glyph selections for all signs, factors and aspects.
public struct GlyphsConfig: Codable {
    public let signGlyphs: [SignGlyphSetting]
    public let factorGlyphs: [FactorGlyphSetting]
    public let aspectGlyphs: [AspectGlyphSetting]

    public init(
        signGlyphs: [SignGlyphSetting] = GlyphsConfig.defaultSignGlyphs,
        factorGlyphs: [FactorGlyphSetting] = GlyphsConfig.defaultFactorGlyphs,
        aspectGlyphs: [AspectGlyphSetting] = GlyphsConfig.defaultAspectGlyphs
    ) {
        self.signGlyphs = signGlyphs
        self.factorGlyphs = factorGlyphs
        self.aspectGlyphs = aspectGlyphs
    }

    public static let defaultSignGlyphs: [SignGlyphSetting] = Signs.allCases.map { sign in
        let glyph: String
        switch sign {
        case .Aries:       glyph = "\u{E000}"
        case .Taurus:      glyph = "\u{E001}"
        case .Gemini:      glyph = "\u{E002}"
        case .Cancer:      glyph = "\u{E003}"
        case .Leo:         glyph = "\u{E004}"
        case .Virgo:       glyph = "\u{E005}"
        case .Libra:       glyph = "\u{E006}"
        case .Scorpio:     glyph = "\u{E007}"
        case .Sagittarius: glyph = "\u{E008}"
        case .Capricorn:   glyph = "\u{E009}"
        case .Aquarius:    glyph = "\u{E010}"
        case .Pisces:      glyph = "\u{E011}"
        }
        return SignGlyphSetting(sign: sign, glyph: glyph)
    }

    public static let defaultFactorGlyphs: [FactorGlyphSetting] = Factors.allCases.map { factor in
        let glyph: String
        switch factor {
        case .sun:                  glyph = "\u{E200}"
        case .moon:                 glyph = "\u{E201}"
        case .mercury:              glyph = "\u{E202}"
        case .venus:                glyph = "\u{E203}"
        case .earth:                glyph = "\u{E204}"
        case .mars:                 glyph = "\u{E205}"
        case .jupiter:              glyph = "\u{E206}"
        case .saturn:               glyph = "\u{E207}"
        case .uranus:               glyph = "\u{E208}"
        case .neptune:              glyph = "\u{E209}"
        case .pluto:                glyph = "\u{E210}"
        case .northNode:            glyph = "\u{E520}"
        case .chiron:               glyph = "\u{E400}"
        case .persephoneRam:        glyph = "\u{E608}"
        case .hermesRam:            glyph = "\u{E609}"
        case .demeterRam:           glyph = "\u{E610}"
        case .cupidoUra:            glyph = "\u{E600}"
        case .hadesUra:             glyph = "\u{E601}"
        case .zeusUra:              glyph = "\u{E602}"
        case .kronosUra:            glyph = "\u{E603}"
        case .apollonUra:           glyph = "\u{E604}"
        case .admetosUra:           glyph = "\u{E605}"
        case .vulcanusUra:          glyph = "\u{E606}"
        case .poseidonUra:          glyph = "\u{E607}"
        case .eris:                 glyph = "\u{E407}"
        case .pholus:               glyph = "\u{E402}"
        case .ceres:                glyph = "\u{E411}"
        case .pallas:               glyph = "\u{E412}"
        case .juno:                 glyph = "\u{E413}"
        case .vesta:                glyph = "\u{E414}"
        case .isis:                 glyph = "\u{E611}"
        case .nessus:               glyph = "\u{E401}"
        case .huya:                 glyph = "\u{E417}"
        case .varuna:               glyph = "\u{E403}"
        case .ixion:                glyph = "\u{E404}"
        case .quaoar:               glyph = "\u{E405}"
        case .haumea:               glyph = "\u{E406}"
        case .orcus:                glyph = "\u{E409}"
        case .makemake:             glyph = "\u{E410}"
        case .sedna:                glyph = "\u{E408}"
        case .hygieia:              glyph = "\u{E415}"
        case .astraea:              glyph = "\u{E416}"
        case .apogeeMean:           glyph = "\u{E530}"
        case .apogeeCorrected:      glyph = "\u{E531}"
        case .apogeeInterpolated:   glyph = "\u{E531}"
        case .persephoneCarteret:   glyph = "\u{E612}"
        case .vulcanusCarteret:     glyph = "\u{E613}"
        case .perigeeInterpolated:  glyph = "\u{2609}"    // TODO add glyph for perigee
        case .priapus:              glyph = "\u{E535}"
        case .priapusCorrected:     glyph = "\u{2609}"    // TODO add glyph for Priapus corrected
        case .dragon:               glyph = "\u{2609}"    // TODO add glyph for Dragon
        case .beast:                glyph = "\u{2609}"    // TODO add glyph for Beast
        case .southNode:            glyph = "\u{E521}"
        case .blackSun:             glyph = "\u{E534}"
        case .diamond:              glyph = "\u{E536}"
        case .ascendant:            glyph = "\u{E500}"
        case .mc:                   glyph = "\u{E501}"
        case .eastPoint:            glyph = "\u{E503}"
        case .vertex:               glyph = "\u{E502}"
        case .zeroAries:            glyph = "\u{E000}"
        case .parsfortuna:          glyph = "\u{F400}"
        default:                    glyph = "?"
        }
        return FactorGlyphSetting(factor: factor, glyph: glyph)
    }

    public static let defaultAspectGlyphs: [AspectGlyphSetting] = Aspects.allCases.map { aspect in
        let glyph: String
        switch aspect {
        case .conjunction:    glyph = "\u{E700}"
        case .opposition:     glyph = "\u{E710}"
        case .trine:          glyph = "\u{E720}"
        case .square:         glyph = "\u{E730}"
        case .septile:        glyph = "\u{E810}"
        case .sextile:        glyph = "\u{E740}"
        case .quintile:       glyph = "\u{E790}"
        case .semisextile:    glyph = "\u{E750}"
        case .semisquare:     glyph = "\u{E770}"
        case .semiquintile:   glyph = "\u{E830}"
        case .biquintile:     glyph = "\u{E800}"
        case .inconjunct:     glyph = "\u{E760}"
        case .sesquiquadrate: glyph = "\u{E780}"
        case .tridecile:      glyph = "\u{E840}"
        case .biseptile:      glyph = "\u{E850}"
        case .triseptile:     glyph = "\u{E860}"
        case .novile:         glyph = "\u{E870}"
        case .binovile:       glyph = "\u{E880}"
        case .quadranovile:   glyph = "\u{E890}"
        case .undecile:       glyph = "\u{E900}"
        case .centile:        glyph = "\u{E910}"
        case .vigintile:      glyph = "\u{E820}"
        }
        return AspectGlyphSetting(aspect: aspect, glyph: glyph)
    }
}
