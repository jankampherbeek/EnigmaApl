// Aspects.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

public enum Aspects: Int, CaseIterable, Codable {
    
    case conjunction = 0
    case opposition = 1
    case trine = 2
    case square = 3
    case septile = 4
    case sextile = 5
    case quintile = 6
    case semisextile = 7
    case semisquare = 8
    case semiquintile = 9
    case biquintile = 10
    case inconjunct = 11
    case sesquiquadrate = 12
    case tridecile = 13
    case biseptile = 14
    case triseptile = 15
    case novile = 16
    case binovile = 17
    case quadranovile = 18
    case undecile = 19
    case centile = 20
    case vigintile = 21
    
    /// Resource bundle key for localized name
    var rbKey: String { AspectKeys.key(for: self) }
    
    /// Angle forn each aspect
    var angle: Double {
        switch self {
        case .conjunction: return 0.0
        case .opposition: return 180.0
        case .trine: return 120.0
        case .square: return 90.0
        case .septile: return 51.42857143
        case .sextile: return 60.0
        case .quintile: return 72.0
        case .semisextile: return 30.0
        case .semisquare: return 45.0
        case .semiquintile: return 36.0
        case .biquintile: return 144.0
        case .inconjunct: return 150.0
        case .sesquiquadrate: return 135.0
        case .tridecile: return 108.0
        case .biseptile: return 102.85714286
        case .triseptile: return 154.28571429
        case .novile: return 40.0
        case .binovile: return 80.0
        case .quadranovile: return 160.0
        case .undecile: return 33.0
        case .centile: return 100.0
        case .vigintile: return 18.0
        }
    }
}
