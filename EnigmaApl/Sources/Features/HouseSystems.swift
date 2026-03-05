//
//  HouseSystems.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/12/2025.
//


import Foundation

/// House systems for astrological calculations
public enum HouseSystems: Int, CaseIterable {
    case noHouses = 0
    case placidus = 1
    case koch = 2
    case porphyri = 3
    case regiomontanus = 4
    case campanus = 5
    case alcabitius = 6
    case topoCentric = 7
    case krusinski = 8
    case apc = 9
    case morin = 10
    case wholeSign = 11
    case equalAsc = 12
    case equalMc = 13
    case equalAries = 14
    case vehlow = 15
    case axial = 16
    case horizon = 17
    case carter = 18
    case gauquelin = 19
    case sunShine = 20
    case sunShineTreindl = 21
    case pullenSd = 22
    case pullenSr = 23
    case sripati = 24
    
    var seId: Character {
        switch self {
        case .noHouses: return "W"
        case .placidus: return "P"
        case .koch: return "K"
        case .porphyri: return "O"
        case .regiomontanus: return "R"
        case .campanus: return "C"
        case .alcabitius: return "B"
        case .topoCentric: return "T"
        case .krusinski: return "U"
        case .apc: return "Y"
        case .morin: return "M"
        case .wholeSign: return "W"
        case .equalAsc: return "A"
        case .equalMc: return "D"
        case .equalAries: return "N"
        case .vehlow: return "V"
        case .axial: return "X"
        case .horizon: return "H"
        case .carter: return "F"
        case .gauquelin: return "G"
        case .sunShine: return "i"
        case .sunShineTreindl: return "I"
        case .pullenSd: return "L"
        case .pullenSr: return "Q"
        case .sripati: return "S"
        }
    }
    
    var localizedName: String {
        switch self {
        case .noHouses: return "enum.housesystem.nohouses"
        case .placidus: return "enum.housesystem.placidus"
        case .koch: return "enum.housesystem.koch"
        case .porphyri: return "enum.housesystem.porphyri"
        case .regiomontanus: return "enum.housesystem.regiomontanus"
        case .campanus: return "enum.housesystem.campanus"
        case .alcabitius: return "enum.housesystem.alcabitius"
        case .topoCentric: return "enum.housesystem.topocentric"
        case .krusinski: return "enum.housesystem.krusinski"
        case .apc: return "enum.housesystem.apc"
        case .morin: return "enum.housesystem.morin"
        case .wholeSign: return "enum.housesystem.whole_sign"
        case .equalAsc: return "enum.housesystem.equal_from_ascendant"
        case .equalMc: return "enum.housesystem.equal_from_mc"
        case .equalAries: return "enum.housesystem.equal_from_0_aries"
        case .vehlow: return "enum.housesystem.vehlow"
        case .axial: return "enum.housesystem.axial_rotation"
        case .horizon: return "enum.housesystem.horizon"
        case .carter: return "enum.housesystem.carter"
        case .gauquelin: return "enum.housesystem.gauquelin"
        case .sunShine: return "enum.housesystem.sunshine"
        case .sunShineTreindl: return "enum.housesystem.sunshine_treindl"
        case .pullenSd: return "enum.housesystem.pullen_sin_diff"
        case .pullenSr: return "enum.housesys.pullen_sin_ratio"
        case .sripati: return "enum.housesys.sripati"
        }
    }
    
    static func fromIndex(_ index: Int) -> HouseSystems? {
        guard index >= 0 && index < HouseSystems.allCases.count else {
            return nil
        }
        return HouseSystems.allCases.dropFirst(index).first
    }
}
