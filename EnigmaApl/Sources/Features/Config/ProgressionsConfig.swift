//
//  ProgressionsConfig.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Foundation

/// Container for all progression and direction configurations.
public struct ProgressionsConfig: Codable, Sendable {
    public let primaryDirections: PrimaryDirectionsConfig
    public let transits: TransitsConfig
    public let secondaryDirections: SecondaryDirectionsConfig
    public let symbolicDirections: SymbolicDirectionsConfig
    public let solarReturn: SolarReturnConfig

    public init(
        primaryDirections: PrimaryDirectionsConfig = PrimaryDirectionsConfig(),
        transits: TransitsConfig = TransitsConfig(),
        secondaryDirections: SecondaryDirectionsConfig = SecondaryDirectionsConfig(),
        symbolicDirections: SymbolicDirectionsConfig = SymbolicDirectionsConfig(),
        solarReturn: SolarReturnConfig = SolarReturnConfig()
    ) {
        self.primaryDirections = primaryDirections
        self.transits = transits
        self.secondaryDirections = secondaryDirections
        self.symbolicDirections = symbolicDirections
        self.solarReturn = solarReturn
    }
}
