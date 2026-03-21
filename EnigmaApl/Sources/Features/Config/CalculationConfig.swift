//
//  CalculationConfig.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Foundation

public enum BlackMoonCorrectionTypes: Int, CaseIterable, Codable {
    case duval = 0
    case swisseph = 1
    case interpolated = 2

    var rbKey: String {
        switch self {
        case .duval:        return "enum.blackmooncorrrectiontype.duval"
        case .swisseph:     return "enum.blackmooncorrectiontype.swisseph"
        case .interpolated: return "enum.blackmooncorrectiontype.interpolated"
        }
    }

    static func fromIndex(_ index: Int) -> BlackMoonCorrectionTypes? {
        return BlackMoonCorrectionTypes(rawValue: index)
    }
}

public enum LunarNodeTypes: Int, CaseIterable, Codable {
    case meanNode = 0
    case trueNode = 1

    var rbKey: String {
        switch self {
        case .meanNode: return "enum.lunarnodetypes.mean"
        case .trueNode: return "enum.lunarnodetypes.true"
        }
    }

    static func fromIndex(_ index: Int) -> LunarNodeTypes? {
        return LunarNodeTypes(rawValue: index)
    }
}

public enum LotsTypes: Int, CaseIterable, Codable {
    case sect = 0
    case noSect = 1

    var rbKey: String {
        switch self {
        case .sect:   return "enum.lotstypes.sect"
        case .noSect: return "enum.lotstypes.nosect"
        }
    }

    static func fromIndex(_ index: Int) -> LotsTypes? {
        return LotsTypes(rawValue: index)
    }
}

/// Configuration for astrological calculation settings.
public struct CalculationConfig: Codable {
    public let houseSystem: HouseSystems
    public let ayanamsha: Ayanamshas
    public let observerPosition: ObserverPositions
    public let projectionType: ProjectionTypes
    public let blackMoonCorrectionType: BlackMoonCorrectionTypes
    public let lunarNodeType: LunarNodeTypes
    public let lotsType: LotsTypes
    /// Percentage of average daily speed below which a planet is considered stationary.
    public let stationaryPercentage: Int
    /// Percentage of average daily speed below which a planet is considered slow.
    public let slowPercentage: Int

    public init(
        houseSystem: HouseSystems = .placidus,
        ayanamsha: Ayanamshas = .tropical,
        observerPosition: ObserverPositions = .geoCentric,
        projectionType: ProjectionTypes = .twoDimensional,
        blackMoonCorrectionType: BlackMoonCorrectionTypes = .duval,
        lunarNodeType: LunarNodeTypes = .meanNode,
        lotsType: LotsTypes = .sect,
        stationaryPercentage: Int = 10,
        slowPercentage: Int = 20
    ) {
        self.houseSystem = houseSystem
        self.ayanamsha = ayanamsha
        self.observerPosition = observerPosition
        self.projectionType = projectionType
        self.blackMoonCorrectionType = blackMoonCorrectionType
        self.lunarNodeType = lunarNodeType
        self.lotsType = lotsType
        self.stationaryPercentage = stationaryPercentage
        self.slowPercentage = slowPercentage
    }
}
