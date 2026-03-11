//
//  Factors.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 22/12/2025.
//

import Foundation

// MARK: - CalculationTypes
/// Methods for the calculation of a factor
/// CommonSE: Calculation of celestial points via the Swiss Ephemeris.
/// CommonElements: Calculation of celestial points based on ecliptical elements.
/// CommonFormula: Calculation of celestial points based on a formula.
/// Mundane: Calculation of mundane points, either via the Swiss Ephemeris of based on a formula.
/// Lots: Calculation of Hellenistic lots.
public enum CalculationTypes: Int, CaseIterable {
    case Unknown = 0
    case CommonSe = 1
    case CommonElements = 2
    case CommonFormulaLongitude = 3
    case CommonFormulaFull = 4
    case Mundane = 5
    case Lots = 6
    case ZodiacFixed = 7
    case Apsides = 8
}

// MARK: - Factors

/// Factors, lights, planets, mathematical points etc. 
public enum Factors: Int, CaseIterable {
    case sun = 0
    case moon = 1
    case mercury = 2
    case venus = 3
    case earth = 4
    case mars = 5
    case jupiter = 6
    case saturn = 7
    case uranus = 8
    case neptune = 9
    case pluto = 10
    case northNode = 11
    case chiron = 13
    case persephoneRam = 14
    case hermesRam = 15
    case demeterRam = 16
    case cupidoUra = 17
    case hadesUra = 18
    case zeusUra = 19
    case kronosUra = 20
    case apollonUra = 21
    case admetosUra = 22
    case vulcanusUra = 23
    case poseidonUra = 24
    case eris = 25
    case pholus = 26
    case ceres = 27
    case pallas = 28
    case juno = 29
    case vesta = 30
    case isis = 31
    case nessus = 32
    case huya = 33
    case varuna = 34
    case ixion = 35
    case quaoar = 36
    case haumea = 37
    case orcus = 38
    case makemake = 39
    case sedna = 40
    case hygieia = 41
    case astraea = 42
    case apogeeMean = 43
    case apogeeCorrected = 44
    case apogeeInterpolated = 45
    case persephoneCarteret = 47
    case vulcanusCarteret = 48
    case perigeeInterpolated = 49
    case priapus = 50
    case priapusCorrected = 51
    case dragon = 52
    case beast = 53
    case southNode = 54
    case blackSun = 56
    case diamond = 57
    case ascendant = 1001
    case mc = 1002
    case eastPoint = 1003
    case vertex = 1004
    case zeroAries = 3001
    case parsfortuna = 4001
    
    /// Indicates if the calculation of this point can be performed by the Swiss Ephemeris
    var calculationType: CalculationTypes {
        switch self {
        case .sun, .moon, .mercury, .venus, .earth, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto,
             .northNode, .apogeeMean, .apogeeCorrected, .chiron, .pholus, .ceres, .pallas, .juno, .vesta,
             .apogeeInterpolated, .perigeeInterpolated, .cupidoUra, .hadesUra, .zeusUra, .kronosUra, .apollonUra, .admetosUra, .vulcanusUra, .poseidonUra,
             .isis, .eris, .nessus, .huya, .varuna, .ixion, .quaoar, .haumea, .orcus, .makemake, .sedna, .hygieia, .astraea:
            return .CommonSe
        case .persephoneRam, .hermesRam, .demeterRam:
            return .CommonElements
        case .persephoneCarteret, .vulcanusCarteret:
            return .CommonFormulaLongitude
        case .priapus, .priapusCorrected, .dragon, .beast, .southNode:
            return .CommonFormulaFull
        case .mc, .ascendant, .eastPoint, .vertex:
            return .Mundane
        case .zeroAries:
            return .ZodiacFixed
        case .parsfortuna:
            return .Lots
        case .blackSun, .diamond:
            return .Apsides
        default:
            return .Unknown
        }
    }
    
    /// Swiss Ephemeris index for this point
    var seId: Int {
        switch self {
        case .sun: return 0
        case .moon: return 1
        case .mercury: return 2
        case .venus: return 3
        case .mars: return 4
        case .jupiter: return 5
        case .saturn: return 6
        case .uranus: return 7
        case .neptune: return 8
        case .pluto: return 9
        case .northNode: return 10
        case .apogeeMean: return 12
        case .apogeeCorrected: return 13
        case .earth: return 14
        case .chiron: return 15
        case .pholus: return 16
        case .ceres: return 17
        case .pallas: return 18
        case .juno: return 19
        case .vesta: return 20
        case .apogeeInterpolated: return 21
        case .perigeeInterpolated: return 22
        case .cupidoUra: return 40
        case .hadesUra: return 41
        case .zeusUra: return 42
        case .kronosUra: return 43
        case .apollonUra: return 44
        case .admetosUra: return 45
        case .vulcanusUra: return 46
        case .poseidonUra: return 47
        case .isis: return 48
        case .eris: return 1009001
        case .nessus: return 17066
        case .huya: return 48628
        case .varuna: return 30000
        case .ixion: return 38978
        case .quaoar: return 60000
        case .haumea: return 146108
        case .orcus: return 100482
        case .makemake: return 146472
        case .sedna: return 100377
        case .hygieia: return 10010
        case .astraea: return 10005
        case .persephoneRam: return 300
        case .hermesRam: return 301
        case .demeterRam: return 302
        case .persephoneCarteret: return 400
        case .vulcanusCarteret: return 401
        case .priapus: return 501
        case .priapusCorrected: return 502
        case .dragon: return 503
        case .beast: return 504
        case .southNode: return 505
        case .blackSun: return 601
        case .diamond: return 602
        case .mc: return 700
        case .ascendant: return 701
        case .eastPoint: return 702
        case .vertex: return 703
        case .zeroAries: return 800
        case .parsfortuna: return 900
        default: return 0
        }
    }
    
    var localizedName: String { FactorKeys.key(for: self) }
    
    static func fromIndex(_ index: Int) -> Factors? {
        guard index >= 0 && index < Factors.allCases.count else {
            return nil
        }
        return Factors.allCases.dropFirst(index).first
    }
}

