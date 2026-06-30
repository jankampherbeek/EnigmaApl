// UserConfiguration.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

/// A named user configuration stored in Swift Data.
/// The active configuration is determined by the isActive flag.
/// Sub-configs are stored as JSON Data to avoid Swift Data's internal Codable
/// transformer failing on nested enum properties.
@Model
public class UserConfiguration {
    public var name: String
    public var isActive: Bool

    // MARK: - Backing Data stores (persisted by Swift Data)
    public var calculationConfigData: Data
    public var displayConfigData: Data
    public var glyphsConfigData: Data
    public var factorConfigData: Data
    public var aspectConfigData: Data
    public var orbConfigData: Data
    public var progressionsConfigData: Data
    public var fixStarConfigData: Data?

    // MARK: - Computed accessors (not persisted — Swift Data ignores computed properties)

    public var calculationConfig: CalculationConfig {
        get { Self.decode(CalculationConfig.self, from: calculationConfigData) ?? CalculationConfig() }
        set { calculationConfigData = Self.encode(newValue) }
    }
    public var displayConfig: DisplayConfig {
        get { Self.decode(DisplayConfig.self, from: displayConfigData) ?? DisplayConfig() }
        set { displayConfigData = Self.encode(newValue) }
    }
    public var glyphsConfig: GlyphsConfig {
        get { Self.decode(GlyphsConfig.self, from: glyphsConfigData) ?? GlyphsConfig() }
        set { glyphsConfigData = Self.encode(newValue) }
    }
    public var factorConfig: FactorConfig {
        get { Self.decode(FactorConfig.self, from: factorConfigData) ?? FactorConfig() }
        set { factorConfigData = Self.encode(newValue) }
    }
    public var aspectConfig: AspectConfig {
        get { Self.decode(AspectConfig.self, from: aspectConfigData) ?? AspectConfig() }
        set { aspectConfigData = Self.encode(newValue) }
    }
    public var orbConfig: OrbConfig {
        get { Self.decode(OrbConfig.self, from: orbConfigData) ?? OrbConfig() }
        set { orbConfigData = Self.encode(newValue) }
    }
    public var progressionsConfig: ProgressionsConfig {
        get { Self.decode(ProgressionsConfig.self, from: progressionsConfigData) ?? ProgressionsConfig() }
        set { progressionsConfigData = Self.encode(newValue) }
    }
    public var fixStarConfig: FixStarConfig {
        get {
            guard let data = fixStarConfigData else { return FixStarConfig() }
            return Self.decode(FixStarConfig.self, from: data) ?? FixStarConfig()
        }
        set { fixStarConfigData = Self.encode(newValue) }
    }

    // MARK: - Init

    public init(
        name: String,
        isActive: Bool = false,
        calculationConfig: CalculationConfig = CalculationConfig(),
        displayConfig: DisplayConfig = DisplayConfig(),
        glyphsConfig: GlyphsConfig = GlyphsConfig(),
        factorConfig: FactorConfig = FactorConfig(),
        aspectConfig: AspectConfig = AspectConfig(),
        orbConfig: OrbConfig = OrbConfig(),
        progressionsConfig: ProgressionsConfig = ProgressionsConfig(),
        fixStarConfig: FixStarConfig = FixStarConfig()
    ) {
        self.name = name
        self.isActive = isActive
        self.calculationConfigData = (try? JSONEncoder().encode(calculationConfig)) ?? Data()
        self.displayConfigData = (try? JSONEncoder().encode(displayConfig)) ?? Data()
        self.glyphsConfigData = (try? JSONEncoder().encode(glyphsConfig)) ?? Data()
        self.factorConfigData = (try? JSONEncoder().encode(factorConfig)) ?? Data()
        self.aspectConfigData = (try? JSONEncoder().encode(aspectConfig)) ?? Data()
        self.orbConfigData = (try? JSONEncoder().encode(orbConfig)) ?? Data()
        self.progressionsConfigData = (try? JSONEncoder().encode(progressionsConfig)) ?? Data()
        self.fixStarConfigData = (try? JSONEncoder().encode(fixStarConfig)) ?? Data()
    }

    // MARK: - Private helpers

    private static func encode<T: Encodable>(_ value: T) -> Data {
        (try? JSONEncoder().encode(value)) ?? Data()
    }

    private static func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        guard !data.isEmpty else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
