// BlaSchemaDomain.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

// MARK: - Black Moon / Priapus correction type

/// Correction method for the "corrected" Black Moon (Apogee) and Priapus points shown alongside
/// the mean position in the BLA schema. This is a BLA-only setting (not part of `CalculationConfig`):
/// elsewhere in the app a chart can already show several apogee/priapus variants at once via the
/// regular Factors configuration, so this picker only decides which single variant the BLA screen adds.
public enum BlackMoonCorrectionType: Int, CaseIterable, Codable {
    case duval = 0
    case swissEph = 1
    case interpolated = 2

    var rbKey: String {
        switch self {
        case .duval: return "enum.blackmooncorrectiontype.duval"
        case .swissEph: return "enum.blackmooncorrectiontype.swisseph"
        case .interpolated: return "enum.blackmooncorrectiontype.interpolated"
        }
    }

    /// The concrete "corrected" Black Moon (Apogee) factor for this correction method.
    var apogeeFactor: Factors {
        switch self {
        case .duval: return .apogeeDuval
        case .swissEph: return .apogeeKoch
        case .interpolated: return .apogeeInterpolated
        }
    }

    /// The concrete "corrected" Priapus factor for this correction method.
    var priapusFactor: Factors {
        switch self {
        case .duval: return .priapusDuval
        case .swissEph: return .priapusKoch
        case .interpolated: return .priapusInterpolated
        }
    }
}

// MARK: - Chart input

/// Ecliptical longitudes for points and house cusps, as used by the BLA schema ("Invisible Luminaries Astrology") calculations.
public struct BlaChartLongitudes {
    public let points: [Factors: Double]
    public let cusps: [Int: Double]

    public init(points: [Factors: Double], cusps: [Int: Double]) {
        self.points = points
        self.cusps = cusps
    }
}

// MARK: - Per-point / per-house details

public struct BlaPointDetails {
    public let point: Factors
    public let longitude: Double
    public let sign: Int
    public let decanate: Int
    public let house: Int
    public let mainRuledSign: Int
    public let subRuledSign: Int
    public let mainRuledHouses: [Int]
    public let subRuledHouses: [Int]
}

public struct BlaHouseDetails {
    public let houseNr: Int
    public let signOnCusp: Int
    public let decanate: Int
    public let longitude: Double
    public let mainRuler: Factors
    public let subRuler: Factors
    public let pointsInHouse: [Factors]
}

// MARK: - Counts

public struct BlaSignHouseCountLine {
    public let sign: Int
    public let house: Int
    public let sum: Int
    public let hCusp: Int
    public let total: Int
}

public struct BlaDispositorLine {
    public let mainRuler: Factors
    public let subRuler: Factors
    public let mainRulerSignCount: Int
    public let subRulerSignCount: Int
    public let sumRulerSignCount: Int
    public let indirectRulerSignCount: Int
    public let totalRulerSignCount: Int
    public let directRulerHouseCount: Int
    public let indirectRulerHouseCount: Int
    public let sumRulerHouseCount: Int
    public let directRulerDecanateCount: Int
    public let total: Int
}

// MARK: - Details / cycles / reinforcements

public struct BlaDetailsData {
    public let sisterSignAsc: Int
    public let clampedHouses: [Int]
    public let interceptedSigns: [Int]
    public let groundNote: [Int]
    public let lordAscInHouses: [Int]
    public let moonInHouse: Int
}

public struct BlaCyclesData {
    public let cardinal: [(Int, Int)]
    public let fixed: [(Int, Int)]
    public let mutable: [(Int, Int)]
    public let fire: [(Int, Int)]
    public let earth: [(Int, Int)]
    public let air: [(Int, Int)]
    public let water: [(Int, Int)]
}

public struct FactorPairAnalogHouseSign {
    public let pointInSign: Factors
    public let sign: Int
    public let pointInHouse: Factors
    public let house: Int
}

public struct Reception: Equatable {
    public let point1: Factors
    public let signOrHouse1: Int
    public let point2: Factors
    public let signOrHouse2: Int
}

// MARK: - Ruler tables

public struct RulerPair {
    public let signIndex: Int
    public let mainRuler: Factors
    public let subRuler: Factors
}

public struct RulerAndSigns {
    public let ruler: Factors
    public let mainSign: Int
    public let subSign: Int
}

public struct DecanateRuler {
    public let ruler: Factors
    public let decan: Int
}

/// Static ruler tables for the BLA schema ("Invisible Luminaries Astrology") calculations.
/// Ported from Enigma.Core/Slices/BlaSchema/BlaDomain.cs.
enum BlaSchemaDomain {

    /// The canonical BLA point order, ported from the Windows `BlaSchemaModel.DefineChartPoints()`
    /// (insertion order of its `Dictionary<ChartPoints, ...>`, which the Windows/.NET runtime
    /// preserves). Swift's `Dictionary` gives no such guarantee, so every BLA list that is built
    /// from a `[Factors: ...]` dictionary must be ordered against this sequence instead of relying
    /// on the dictionary's own (effectively random) iteration order.
    ///
    /// Windows always shows both the mean and the "corrected" Black Moon/Priapus side by side;
    /// `blackMoonCorrectionType` picks which concrete factor plays that "corrected" role.
    static func standardSequence(blackMoonCorrectionType: BlackMoonCorrectionType) -> [Factors] {
        [
            .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto,
            .northNode, .southNode, .persephoneCarteret, .vulcanusCarteret,
            .apogeeMean, blackMoonCorrectionType.apogeeFactor,
            .blackSun, .diamond,
            .priapus, blackMoonCorrectionType.priapusFactor,
            .dragon, .beast, .parsfortuna, .chiron, .ceres, .ascendant, .mc
        ]
    }

    /// Main/sub ruler for each of the 12 signs. Signs 6-12 mirror signs 1-5,9 with main/sub swapped
    /// (the "sister" axis of each ruler pair).
    static func rulerPairs() -> [RulerPair] {
        [
            RulerPair(signIndex: 1, mainRuler: .mars, subRuler: .pluto),
            RulerPair(signIndex: 2, mainRuler: .venus, subRuler: .persephoneCarteret),
            RulerPair(signIndex: 3, mainRuler: .mercury, subRuler: .vulcanusCarteret),
            RulerPair(signIndex: 4, mainRuler: .moon, subRuler: .priapus),
            RulerPair(signIndex: 5, mainRuler: .sun, subRuler: .apogeeMean),
            RulerPair(signIndex: 6, mainRuler: .vulcanusCarteret, subRuler: .mercury),
            RulerPair(signIndex: 7, mainRuler: .persephoneCarteret, subRuler: .venus),
            RulerPair(signIndex: 8, mainRuler: .pluto, subRuler: .mars),
            RulerPair(signIndex: 9, mainRuler: .jupiter, subRuler: .neptune),
            RulerPair(signIndex: 10, mainRuler: .apogeeMean, subRuler: .sun),
            RulerPair(signIndex: 11, mainRuler: .priapus, subRuler: .moon),
            RulerPair(signIndex: 12, mainRuler: .neptune, subRuler: .jupiter)
        ]
    }

    /// Inverse view of `rulerPairs()`: each of the 12 sign-rulers with its main and sub ruled sign.
    static func allRulerAndSigns() -> [RulerAndSigns] {
        [
            RulerAndSigns(ruler: .sun, mainSign: 5, subSign: 10),
            RulerAndSigns(ruler: .moon, mainSign: 4, subSign: 11),
            RulerAndSigns(ruler: .mercury, mainSign: 3, subSign: 6),
            RulerAndSigns(ruler: .venus, mainSign: 2, subSign: 7),
            RulerAndSigns(ruler: .mars, mainSign: 1, subSign: 8),
            RulerAndSigns(ruler: .jupiter, mainSign: 9, subSign: 12),
            RulerAndSigns(ruler: .neptune, mainSign: 12, subSign: 9),
            RulerAndSigns(ruler: .pluto, mainSign: 8, subSign: 1),
            RulerAndSigns(ruler: .persephoneCarteret, mainSign: 7, subSign: 2),
            RulerAndSigns(ruler: .vulcanusCarteret, mainSign: 6, subSign: 3),
            RulerAndSigns(ruler: .apogeeMean, mainSign: 10, subSign: 5),
            RulerAndSigns(ruler: .priapus, mainSign: 11, subSign: 4)
        ]
    }

    /// Logical pairs of related factors, used to detect "analog house/sign" reinforcements.
    static func factorPairs() -> [(Factors, Factors)] {
        [
            (.mars, .pluto),
            (.venus, .persephoneCarteret),
            (.mercury, .vulcanusCarteret),
            (.moon, .priapus),
            (.sun, .apogeeMean),
            (.jupiter, .neptune),
            (.saturn, .uranus),
            (.northNode, .southNode),
            (.northNode, .beast),
            (.northNode, .dragon),
            (.southNode, .beast),
            (.southNode, .dragon),
            (.beast, .dragon)
        ]
    }

    /// Chaldean-order rulers for the 7-decan cycle used by the BLA schema.
    static func decanateRulers() -> [DecanateRuler] {
        [
            DecanateRuler(ruler: .mars, decan: 1),
            DecanateRuler(ruler: .sun, decan: 2),
            DecanateRuler(ruler: .venus, decan: 3),
            DecanateRuler(ruler: .mercury, decan: 4),
            DecanateRuler(ruler: .moon, decan: 5),
            DecanateRuler(ruler: .saturn, decan: 6),
            DecanateRuler(ruler: .jupiter, decan: 7)
        ]
    }
}
