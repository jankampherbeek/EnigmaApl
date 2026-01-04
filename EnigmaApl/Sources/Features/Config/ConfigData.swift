//
//  ConfigData.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 01/01/2026.
//

import Foundation



public struct ConfigData {
    public let houseSystem: HouseSystems
    public let ayanamsha: Ayanamshas
    public let observerPosition: ObserverPositions
    public let projectionType: ProjectionTypes
    public let blackMoonCorrectionType: BlackMoonCorrectionTypes
    public let lunarNodeType: LunarNodeTypes
    public let lotsType: LotsTypes
    
    public init(
        houseSystem: HouseSystems,
        ayanamsha: Ayanamshas,
        observerPosition: ObserverPositions,
        projectionType: ProjectionTypes,
        blackMoonCorrectionType: BlackMoonCorrectionTypes,
        lunarNodeType: LunarNodeTypes,
        lotsType: LotsTypes
    ) {
        self.houseSystem = houseSystem
        self.ayanamsha = ayanamsha
        self.observerPosition = observerPosition
        self.projectionType = projectionType
        self.blackMoonCorrectionType = blackMoonCorrectionType
        self.lunarNodeType = lunarNodeType
        self.lotsType = lotsType
    }
}


public enum BlackMoonCorrectionTypes: Int, CaseIterable {
    case duval = 0
    case swisseph = 1
    case interpolated = 2
    
    /// Resource bundle key for localized name
    var rbKey: String {
        switch self {
        case .duval: return "enum.blackmooncorrrectiontype.duval"
        case .swisseph: return "enum.blackmooncorrectiontype.swisseph"
        case .interpolated: return "enum.blackmooncorrectiontype.interpolated"
        }
    }
    
    /// Find black moon correction type for a given index
    /// - Parameter index: The index (raw value)
    /// - Returns: The black moon correction type if found, nil otherwise
    static func fromIndex(_ index: Int) -> BlackMoonCorrectionTypes? {
        return BlackMoonCorrectionTypes(rawValue: index)
    }
}

public enum LunarNodeTypes: Int, CaseIterable {
    case meanNode = 0
    case trueNode = 1
    
    /// Resource bundle key for localized name
    var rbKey: String {
        switch self {
        case .meanNode: return "enum.lunarnodetypes.mean"
        case .trueNode: return "enum.lunarnodetypes.true"
        }
    }
    
    /// Find lunar node type for a given index
    /// - Parameter index: The index (raw value)
    /// - Returns: The lunar node type if found, nil otherwise
    static func fromIndex(_ index: Int) -> LunarNodeTypes? {
        return LunarNodeTypes(rawValue: index)
    }
}



public enum LotsTypes: Int, CaseIterable {
    case sect = 0
    case noSect = 1
    
    /// Resource bundle key for localized name
    var rbKey: String {
        switch self {
        case .sect: return "enum.lotstypes.sect"
        case .noSect: return "enum.lotstypes.nosect"
        }
    }
    
    /// Find lunar node type for a given index
    /// - Parameter index: The index (raw value)
    /// - Returns: The lots type if found, nil otherwise
    static func fromIndex(_ index: Int) -> LunarNodeTypes? {
        return LunarNodeTypes(rawValue: index)
    }
}
