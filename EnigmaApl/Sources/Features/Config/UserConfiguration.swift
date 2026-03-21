//
//  UserConfiguration.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Foundation
import SwiftData

/// A named user configuration stored in Swift Data.
/// The active configuration is determined by the isActive flag.
/// All sub-configs use their own defaults when a new configuration is created.
@Model
public class UserConfiguration {
    public var name: String
    public var isActive: Bool
    public var calculationConfig: CalculationConfig
    public var displayConfig: DisplayConfig
    public var glyphsConfig: GlyphsConfig
    public var factorConfig: FactorConfig
    public var aspectConfig: AspectConfig
    public var orbConfig: OrbConfig
    public var progressionsConfig: ProgressionsConfig

    public init(
        name: String,
        isActive: Bool = false,
        calculationConfig: CalculationConfig = CalculationConfig(),
        displayConfig: DisplayConfig = DisplayConfig(),
        glyphsConfig: GlyphsConfig = GlyphsConfig(),
        factorConfig: FactorConfig = FactorConfig(),
        aspectConfig: AspectConfig = AspectConfig(),
        orbConfig: OrbConfig = OrbConfig(),
        progressionsConfig: ProgressionsConfig = ProgressionsConfig()
    ) {
        self.name = name
        self.isActive = isActive
        self.calculationConfig = calculationConfig
        self.displayConfig = displayConfig
        self.glyphsConfig = glyphsConfig
        self.factorConfig = factorConfig
        self.aspectConfig = aspectConfig
        self.orbConfig = orbConfig
        self.progressionsConfig = progressionsConfig
    }
}
