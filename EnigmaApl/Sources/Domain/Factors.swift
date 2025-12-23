//
//  Factors.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 22/12/2025.
//

import Foundation

/// Factors, lgihts, planets, mathematical points etc. Solar system points. .
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
    case northNodeMean = 11
    case northNodeTrue = 12
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
    case southNodeMean = 54
    case southNodeTrue = 55
    case blackSun = 56
    case diamond = 57
    case ascendant = 1001
    case mc = 1002
    case eastPoint = 1003
    case vertex = 1004
    case zeroAries = 3001
    case fortunaSect = 4001
    case fortunaNoSect = 4002
    
    /// Indicates if the calculation of this point can be performed by the Swiss Ephemeris
    var se: Bool {
        switch self {
        case .sun, .moon, .mercury, .venus, .earth, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto,
             .northNodeMean, .northNodeTrue, .apogeeMean, .apogeeCorrected, .chiron, .pholus, .ceres, .pallas, .juno, .vesta,
             .apogeeInterpolated, .perigeeInterpolated, .cupidoUra, .hadesUra, .zeusUra, .kronosUra, .apollonUra, .admetosUra, .vulcanusUra, .poseidonUra,
             .isis, .eris, .nessus, .huya, .varuna, .ixion, .quaoar, .haumea, .orcus, .makemake, .sedna, .hygieia, .astraea,
             .persephoneRam, .hermesRam, .demeterRam, .persephoneCarteret, .vulcanusCarteret,
             .priapus, .priapusCorrected, .dragon, .beast, .southNodeMean, .southNodeTrue, .blackSun, .diamond,
             .mc, .ascendant, .eastPoint, .vertex, .zeroAries, .fortunaSect, .fortunaNoSect:
            return true
        default:
            return false
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
        case .northNodeMean: return 10
        case .northNodeTrue: return 11
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
        case .southNodeMean: return 505
        case .southNodeTrue: return 506  // TODO check
        case .blackSun: return 601
        case .diamond: return 602
        case .mc: return 700
        case .ascendant: return 701
        case .eastPoint: return 702
        case .vertex: return 703
        case .zeroAries: return 800
        case .fortunaSect: return 900
        case .fortunaNoSect: return 901
        default: return 0
        }
    }
    
    var localizedName: String {
        switch self {
        case .sun: return "enum.factor.sun"
        case .moon: return "enum.factor.moon"
        case .mercury: return "enum.factor.mercury"
        case .venus: return "enum.factor.venus"
        case .earth: return "enum.factor.earth"
        case .mars: return "enum.factor.mars"
        case .jupiter: return "enum.factor.jupiter"
        case .saturn: return "enum.factor.saturn"
        case .uranus: return "enum.factor.uranus"
        case .neptune: return "enum.factor.neptune"
        case .pluto: return "enum.factor.pluto"
        case .northNodeMean: return "enum.factor.northnode"
        case .northNodeTrue: return "enum.factor.truenode"
        case .chiron: return "enum.factor.chiron"
        case .persephoneRam: return "enum.factor.persephoneram"
        case .hermesRam: return "enum.factor.hermesram"
        case .demeterRam: return "enum.factor.demeterram"
        case .cupidoUra: return "enum.factor.cupidoura"
        case .hadesUra: return "enum.factor.hadesura"
        case .zeusUra: return "enum.factor.zeusura"
        case .kronosUra: return "enum.factor.kronosura"
        case .apollonUra: return "enum.factor.apollonura"
        case .admetosUra: return "enum.factor.admetosura"
        case .vulcanusUra: return "enum.factor.vulcanusura"
        case .poseidonUra: return "enum.factor.poseidonura"
        case .eris: return "enum.factor.eris"
        case .pholus: return "enum.factor.pholus"
        case .ceres: return "enum.factor.ceres"
        case .pallas: return "enum.factor.pallas"
        case .juno: return "enum.factor.juno"
        case .vesta: return "enum.factor.vesta"
        case .isis: return "enum.factor.isis"
        case .nessus: return "enum.factor.nessus"
        case .huya: return "enum.factor.huya"
        case .varuna: return "enum.factor.varuna"
        case .ixion: return "enum.factor.ixion"
        case .quaoar: return "enum.factor.quaoar"
        case .haumea: return "enum.factor.haumea"
        case .orcus: return "enum.factor.orcus"
        case .makemake: return "enum.factor.makemake"
        case .sedna: return "enum.factor.sedna"
        case .hygieia: return "enum.factor.hygieia"
        case .astraea: return "enum.factor.astraea"
        case .apogeeMean: return "enum.factor.apogeemean"
        case .apogeeCorrected: return "enum.factor.apogeecorrected"
        case .apogeeInterpolated: return "enum.factor.apogeeinterpolated"
        case .persephoneCarteret: return "enum.factor.persephonecarteret"
        case .vulcanusCarteret: return "enum.factor.vulcanuscarteret"
        case .perigeeInterpolated: return "enum.factor.perigeeinterpolated"
        case .priapus: return "enum.factor.priapus"
        case .priapusCorrected: return "enum.factor.priapuscorrected"
        case .dragon: return "enum.factor.dragon"
        case .beast: return "enum.factor.beast"
        case .southNodeMean: return "enum.factor.southnodemean"
        case .southNodeTrue: return "enum.factor.southnodetrue"
        case .blackSun: return "enum.factor.blacksun"
        case .diamond: return "enum.factor.diamond"
        case .ascendant: return "enum.factor.ascendant"
        case .mc: return "enum.factor.mc"
        case .eastPoint: return "enum.factor.eastpoint"
        case .vertex: return "enum.factor.vertex"
        case .zeroAries: return "enum.factor.zeroaries"
        case .fortunaSect: return "enum.factor.fortunasect"
        case .fortunaNoSect: return "enum.factor.fortunanosect"
        }
    }
    
    static func fromIndex(_ index: Int) -> Factors? {
        guard index >= 0 && index < Factors.allCases.count else {
            return nil
        }
        return Factors.allCases.dropFirst(index).first
    }
}

