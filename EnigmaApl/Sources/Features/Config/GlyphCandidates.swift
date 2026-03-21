//
//  GlyphCandidates.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Foundation

/// Static lookup of available glyph candidates per sign, factor and aspect.
/// Items with one candidate have no alternative. Items with multiple candidates
/// allow the user to choose in the configuration UI.
/// Replace "?" placeholders with the correct Unicode character codes.
public struct GlyphCandidates {

    public static func candidates(for sign: Signs) -> [String] {
        switch sign {
        case .Aries:       return ["?"]
        case .Taurus:      return ["?"]
        case .Gemini:      return ["?"]
        case .Cancer:      return ["?"]
        case .Leo:         return ["?"]
        case .Virgo:       return ["?"]
        case .Libra:       return ["?"]
        case .Scorpio:     return ["?"]
        case .Sagittarius: return ["?"]
        case .Capricorn:   return ["?"]
        case .Aquarius:    return ["?"]
        case .Pisces:      return ["?"]
        }
    }

    public static func candidates(for factor: Factors) -> [String] {
        switch factor {
        case .sun:                  return ["?"]
        case .moon:                 return ["?"]
        case .mercury:              return ["?"]
        case .venus:                return ["?"]
        case .earth:                return ["?"]
        case .mars:                 return ["?"]
        case .jupiter:              return ["?"]
        case .saturn:               return ["?"]
        case .uranus:               return ["?"]
        case .neptune:              return ["?"]
        case .pluto:                return ["?"]
        case .northNode:            return ["?"]
        case .chiron:               return ["?"]
        case .persephoneRam:        return ["?"]
        case .hermesRam:            return ["?"]
        case .demeterRam:           return ["?"]
        case .cupidoUra:            return ["?"]
        case .hadesUra:             return ["?"]
        case .zeusUra:              return ["?"]
        case .kronosUra:            return ["?"]
        case .apollonUra:           return ["?"]
        case .admetosUra:           return ["?"]
        case .vulcanusUra:          return ["?"]
        case .poseidonUra:          return ["?"]
        case .eris:                 return ["?"]
        case .pholus:               return ["?"]
        case .ceres:                return ["?"]
        case .pallas:               return ["?"]
        case .juno:                 return ["?"]
        case .vesta:                return ["?"]
        case .isis:                 return ["?"]
        case .nessus:               return ["?"]
        case .huya:                 return ["?"]
        case .varuna:               return ["?"]
        case .ixion:                return ["?"]
        case .quaoar:               return ["?"]
        case .haumea:               return ["?"]
        case .orcus:                return ["?"]
        case .makemake:             return ["?"]
        case .sedna:                return ["?"]
        case .hygieia:              return ["?"]
        case .astraea:              return ["?"]
        case .apogeeMean:           return ["?"]
        case .apogeeCorrected:      return ["?"]
        case .apogeeInterpolated:   return ["?"]
        case .persephoneCarteret:   return ["?"]
        case .vulcanusCarteret:     return ["?"]
        case .perigeeInterpolated:  return ["?"]
        case .priapus:              return ["?"]
        case .priapusCorrected:     return ["?"]
        case .dragon:               return ["?"]
        case .beast:                return ["?"]
        case .southNode:            return ["?"]
        case .blackSun:             return ["?"]
        case .diamond:              return ["?"]
        case .ascendant:            return ["?"]
        case .mc:                   return ["?"]
        case .eastPoint:            return ["?"]
        case .vertex:               return ["?"]
        case .zeroAries:            return ["?"]
        case .parsfortuna:          return ["?"]
        default:                    return ["?"]
        }
    }

    public static func candidates(for aspect: Aspects) -> [String] {
        switch aspect {
        case .conjunction:    return ["?"]
        case .opposition:     return ["?"]
        case .trine:          return ["?"]
        case .square:         return ["?"]
        case .septile:        return ["?"]
        case .sextile:        return ["?"]
        case .quintile:       return ["?"]
        case .semisextile:    return ["?"]
        case .semisquare:     return ["?"]
        case .semiquintile:   return ["?"]
        case .biquintile:     return ["?"]
        case .inconjunct:     return ["?"]
        case .sesquiquadrate: return ["?"]
        case .tridecile:      return ["?"]
        case .biseptile:      return ["?"]
        case .triseptile:     return ["?"]
        case .novile:         return ["?"]
        case .binovile:       return ["?"]
        case .quadranovile:   return ["?"]
        case .undecile:       return ["?"]
        case .centile:        return ["?"]
        case .vigintile:      return ["?"]
        }
    }
}
