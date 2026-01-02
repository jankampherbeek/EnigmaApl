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
    
    public init(
        houseSystem: HouseSystems,
        ayanamsha: Ayanamshas,
        observerPosition: ObserverPositions,
        projectionType: ProjectionTypes
    ) {
        self.houseSystem = houseSystem
        self.ayanamsha = ayanamsha
        self.observerPosition = observerPosition
        self.projectionType = projectionType
    }
}
