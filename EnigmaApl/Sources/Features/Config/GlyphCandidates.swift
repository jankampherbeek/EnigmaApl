// GlyphCandidates.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Static lookup of available glyph candidates per sign, factor and aspect.
/// Items with one candidate have no alternative. Items with multiple candidates
/// allow the user to choose in the configuration UI.
public struct GlyphCandidates {

    public static func candidates(for sign: Signs) -> [String] {
        switch sign {
        case .Aries:       return ["\u{E000}"]
        case .Taurus:      return ["\u{E001}"]
        case .Gemini:      return ["\u{E002}"]
        case .Cancer:      return ["\u{E003}"]
        case .Leo:         return ["\u{E004}"]
        case .Virgo:       return ["\u{E005}"]
        case .Libra:       return ["\u{E006}"]
        case .Scorpio:     return ["\u{E007}"]
        case .Sagittarius: return ["\u{E008}"]
        case .Capricorn:   return ["\u{E009}", "\u{E012}"]
        case .Aquarius:    return ["\u{E010}"]
        case .Pisces:      return ["\u{E011}"]
        }
    }

    public static func candidates(for factor: Factors) -> [String] {
        switch factor {
        case .sun:                  return ["\u{E200}", "\u{E300}"]
        case .moon:                 return ["\u{E201}"]
        case .mercury:              return ["\u{E202}", "\u{E301}"]
        case .venus:                return ["\u{E203}"]
        case .earth:                return ["\u{E204}"]
        case .mars:                 return ["\u{E205}", "\u{E302}"]
        case .jupiter:              return ["\u{E206}", "\u{E303}"]
        case .saturn:               return ["\u{E207}", "\u{E304}"]
        case .uranus:               return ["\u{E208}", "\u{E305}", "\u{E306}"]
        case .neptune:              return ["\u{E209}", "\u{E307}"]
        case .pluto:                return ["\u{E210}", "\u{E308}", "\u{E309}", "\u{E310}", "\u{E311}", "\u{E312}"]
        case .northNode:            return ["\u{E520}"]
        case .chiron:               return ["\u{E400}", "\u{E450}"]
        case .persephoneRam:        return ["\u{E608}"]
        case .hermesRam:            return ["\u{E609}"]
        case .demeterRam:           return ["\u{E610}"]
        case .cupidoUra:            return ["\u{E600}"]
        case .hadesUra:             return ["\u{E601}"]
        case .zeusUra:              return ["\u{E602}"]
        case .kronosUra:            return ["\u{E603}"]
        case .apollonUra:           return ["\u{E604}"]
        case .admetosUra:           return ["\u{E605}"]
        case .vulcanusUra:          return ["\u{E606}"]
        case .poseidonUra:          return ["\u{E607}"]
        case .eris:                 return ["\u{E407}", "\u{E451}", "\u{E452}", "\u{E453}", "\u{E454}", "\u{E455}", "\u{E456}"]
        case .pholus:               return ["\u{E402}"]
        case .ceres:                return ["\u{E411}"]
        case .pallas:               return ["\u{E412}"]
        case .juno:                 return ["\u{E413}"]
        case .vesta:                return ["\u{E414}"]
        case .isis:                 return ["\u{E611}"]
        case .nessus:               return ["\u{E401}"]
        case .huya:                 return ["\u{E417}"]
        case .varuna:               return ["\u{E403}"]
        case .ixion:                return ["\u{E404}"]
        case .quaoar:               return ["\u{E405}"]
        case .haumea:               return ["\u{E406}"]
        case .orcus:                return ["\u{E409}"]
        case .makemake:             return ["\u{E410}"]
        case .sedna:                return ["\u{E408}"]
        case .hygieia:              return ["\u{E415}", "\u{E457}"]
        case .astraea:              return ["\u{E416}"]
        case .apogeeMean:           return ["\u{E530}"]
        case .apogeeCorrected:      return ["\u{E531}"]
        case .apogeeInterpolated:   return ["\u{E531}"]
        case .persephoneCarteret:   return ["\u{E612}"]
        case .vulcanusCarteret:     return ["\u{E613}"]
        case .perigeeInterpolated:  return ["\u{2609}"]   // TODO: add proper glyph
        case .priapus:              return ["\u{E535}"]
        case .priapusCorrected:     return ["\u{2609}"]   // TODO: add proper glyph
        case .dragon:               return ["\u{2609}"]   // TODO: add proper glyph
        case .beast:                return ["\u{2609}"]   // TODO: add proper glyph
        case .southNode:            return ["\u{E521}"]
        case .blackSun:             return ["\u{E534}"]
        case .diamond:              return ["\u{E536}"]
        case .ascendant:            return ["\u{E500}", "\u{E550}"]
        case .mc:                   return ["\u{E501}", "\u{E551}"]
        case .eastPoint:            return ["\u{E503}"]
        case .vertex:               return ["\u{E502}"]
        case .zeroAries:            return ["\u{E000}"]
        case .parsfortuna:          return ["\u{F400}"]
        default:                    return ["?"]
        }
    }

    public static func candidates(for aspect: Aspects) -> [String] {
        switch aspect {
        case .conjunction:    return ["\u{E700}"]
        case .opposition:     return ["\u{E710}"]
        case .trine:          return ["\u{E720}"]
        case .square:         return ["\u{E730}"]
        case .septile:        return ["\u{E810}"]
        case .sextile:        return ["\u{E740}"]
        case .quintile:       return ["\u{E790}"]
        case .semisextile:    return ["\u{E750}"]
        case .semisquare:     return ["\u{E770}"]
        case .semiquintile:   return ["\u{E830}"]
        case .biquintile:     return ["\u{E800}"]
        case .inconjunct:     return ["\u{E760}"]
        case .sesquiquadrate: return ["\u{E780}"]
        case .tridecile:      return ["\u{E840}"]
        case .biseptile:      return ["\u{E850}"]
        case .triseptile:     return ["\u{E860}"]
        case .novile:         return ["\u{E870}"]
        case .binovile:       return ["\u{E880}"]
        case .quadranovile:   return ["\u{E890}"]
        case .undecile:       return ["\u{E900}"]
        case .centile:        return ["\u{E910}"]
        case .vigintile:      return ["\u{E820}"]
        }
    }
}
