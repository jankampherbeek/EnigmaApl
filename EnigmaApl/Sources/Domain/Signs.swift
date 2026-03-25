// Signs.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026


/// Zodiac signs
public enum Signs: Int, CaseIterable, Codable {
    case Aries = 1
    case Taurus = 2
    case Gemini = 3
    case Cancer = 4
    case Leo = 5
    case Virgo = 6
    case Libra = 7
    case Scorpio = 8
    case Sagittarius = 9
    case Capricorn = 10
    case Aquarius = 11
    case Pisces = 12

    var rbKey: String {
        switch self {
        case .Aries:       return "enum.sign.aries"
        case .Taurus:      return "enum.sign.taurus"
        case .Gemini:      return "enum.sign.gemini"
        case .Cancer:      return "enum.sign.cancer"
        case .Leo:         return "enum.sign.leo"
        case .Virgo:       return "enum.sign.virgo"
        case .Libra:       return "enum.sign.libra"
        case .Scorpio:     return "enum.sign.scorpio"
        case .Sagittarius: return "enum.sign.sagittarius"
        case .Capricorn:   return "enum.sign.capricorn"
        case .Aquarius:    return "enum.sign.aquarius"
        case .Pisces:      return "enum.sign.pisces"
        }
    }
}

