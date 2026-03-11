//
//  Ayanamshas.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/12/2025.
//

import Foundation

/// Supported ayanamshas for sidereal calculations
public enum Ayanamshas: Int, CaseIterable {
    case tropical = 0
    case fagan = 1
    case lahiri = 2
    case deLuce = 3
    case raman = 4
    case ushaShashi = 5
    case krishnamurti = 6
    case djwhalKhul = 7
    case yukteshwar = 8
    case bhasin = 9
    case kugler1 = 10
    case kugler2 = 11
    case kugler3 = 12
    case huber = 13
    case etaPiscium = 14
    case aldebaran15Tau = 15
    case hipparchus = 16
    case sassanian = 17
    case galactCtr0Sag = 18
    case j2000 = 19
    case j1900 = 20
    case b1950 = 21
    case suryaSiddhanta = 22
    case suryaSiddhantaMeanSun = 23
    case aryabhata = 24
    case aryabhataMeanSun = 25
    case ssRevati = 26
    case ssCitra = 27
    case trueCitra = 28
    case trueRevati = 29
    case truePushya = 30
    case galacticCtrBrand = 31
    case galacticEqIau1958 = 32
    case galacticEq = 33
    case galacticEqMidMula = 34
    case skydram = 35
    case trueMula = 36
    case dhruva = 37
    case aryabhata522 = 38
    case britton = 39
    case galacticCtrOCap = 40
    
    /// Swiss Ephemeris ID for this ayanamsha
    var seId: Int {
        switch self {
        case .tropical: return -1
        case .fagan: return 0
        case .lahiri: return 1
        case .deLuce: return 2
        case .raman: return 3
        case .ushaShashi: return 4
        case .krishnamurti: return 5
        case .djwhalKhul: return 6
        case .yukteshwar: return 7
        case .bhasin: return 8
        case .kugler1: return 9
        case .kugler2: return 10
        case .kugler3: return 11
        case .huber: return 12
        case .etaPiscium: return 13
        case .aldebaran15Tau: return 14
        case .hipparchus: return 15
        case .sassanian: return 16
        case .galactCtr0Sag: return 17
        case .j2000: return 18
        case .j1900: return 19
        case .b1950: return 20
        case .suryaSiddhanta: return 21
        case .suryaSiddhantaMeanSun: return 22
        case .aryabhata: return 23
        case .aryabhataMeanSun: return 24
        case .ssRevati: return 25
        case .ssCitra: return 26
        case .trueCitra: return 27
        case .trueRevati: return 28
        case .truePushya: return 29
        case .galacticCtrBrand: return 30
        case .galacticEqIau1958: return 31
        case .galacticEq: return 32
        case .galacticEqMidMula: return 33
        case .skydram: return 34
        case .trueMula: return 35
        case .dhruva: return 36
        case .aryabhata522: return 37
        case .britton: return 38
        case .galacticCtrOCap: return 39
        }
    }
    
    /// Resource bundle key for localized name
    var rbKey: String { AyanamshaKeys.key(for: self) }
    
    /// Find ayanamsha for a given index
    /// - Parameter index: The index (raw value)
    /// - Returns: The ayanamsha if found, nil otherwise
    static func fromIndex(_ index: Int) -> Ayanamshas? {
        return Ayanamshas(rawValue: index)
    }
}
