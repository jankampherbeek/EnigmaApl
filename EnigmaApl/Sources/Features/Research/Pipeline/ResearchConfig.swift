// ResearchConfig.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Describes the layout of one factor's block inside a results.bin record.
public struct FactorLayout: Sendable {
    /// The factor this layout entry belongs to.
    public let factor: Factors
    /// Byte offset of this factor's block from the start of the record's data region.
    public let byteOffset: Int
    /// Whether ecliptical coordinates are stored.
    public let hasEcliptical: Bool
    /// Whether equatorial coordinates are stored.
    public let hasEquatorial: Bool
    /// Whether horizontal coordinates are stored.
    public let hasHorizontal: Bool

    /// Number of Double values stored for this factor.
    /// Each enabled coordinate system stores: mainPos, secondPos, distance, speedMain, speedSecond (5 Doubles).
    public var doubleCount: Int {
        let systems = [hasEcliptical, hasEquatorial, hasHorizontal].filter { $0 }.count
        return systems * 5
    }

    /// Byte size of this factor's block (each Double is 8 bytes).
    public var byteSize: Int { doubleCount * 8 }
}

/// Decoded form of the JSON config stored in `ResearchProjectModel.config`.
/// Computes the binary record layout for `results.bin`.
public struct ResearchConfig: Codable, Sendable {

    // MARK: - Stored properties (from JSON)

    /// Factor raw values (Int) that are enabled for this research project.
    public let enabledFactorIds: [Int]
    /// Raw value of the `Inquiries` enum, used to derive coordinate requirements.
    public let inquiryId: Int
    /// Raw value of the `HouseSystems` enum. Only used when inquiry == .factorsInHouses.
    public let houseSystemId: Int
    /// CalculationConfig encoded as JSON string (re-used from project model).
    public let calculationConfigJson: String
    /// OrbConfig encoded as JSON string (re-used from project model).
    public let orbConfigJson: String?

    // MARK: - Optional inquiry-specific settings

    /// Aspect raw values (Int) selected for this project. Only used when inquiry == .aspects.
    public let enabledAspectIds: [Int]?
    /// Override orb in degrees for aspects. nil = use the value from OrbConfig.
    public let aspectOrbOverride: Double?
    /// Override orb in degrees for unaspected. nil = use the value from OrbConfig.
    public let unaspectOrbOverride: Double?
    /// Override orb in degrees for declination midpoints. nil = use the value from OrbConfig.
    public let declMidpointOrbOverride: Double?
    /// Dial sizes (360, 90, 45) enabled for midpoint analysis.
    public let enabledDialSizes: [Int]?
    /// Harmonic number for harmonics analysis. nil = use default (5).
    public let harmonicNumber: Int?

    // MARK: - Derived coordinate flags

    private var inquiry: Inquiries? { Inquiries(rawValue: inquiryId) }

    /// Ecliptical coordinates are stored for all inquiries except OOB, parallels, declMidpoints.
    public var useEcliptical: Bool { inquiry?.usesEcliptical ?? true }
    /// Equatorial coordinates are stored for OOB, parallels, and declMidpoints.
    public var useEquatorial: Bool { inquiry?.usesEquatorial ?? false }
    /// Horizontal coordinates are never stored in the research binary file.
    public var useHorizontal: Bool { false }

    /// The resolved house system for this project.
    public var houseSystem: HouseSystems { HouseSystems(rawValue: houseSystemId) ?? .placidus }

    // MARK: - Computed layout

    /// Resolved `Factors` values from `enabledFactorIds`.
    public var enabledFactors: [Factors] {
        enabledFactorIds.compactMap { Factors(rawValue: $0) }
    }

    /// Per-factor layout entries in stable order (Factors.allCases order, filtered to enabled).
    public var factorLayouts: [FactorLayout] {
        var offset = 0
        let ordered = Factors.allCases.filter { enabledFactors.contains($0) }
        return ordered.map { factor in
            let layout = FactorLayout(
                factor: factor,
                byteOffset: offset,
                hasEcliptical: useEcliptical,
                hasEquatorial: useEquatorial,
                hasHorizontal: false
            )
            offset += layout.byteSize
            return layout
        }
    }

    /// Total byte size of the variable data region per record.
    public var dataRegionSize: Int {
        factorLayouts.reduce(0) { $0 + $1.byteSize }
    }

    /// Total byte size of one record:
    /// recordId (8) + isData (1) + padding (7 to align data region to 8 bytes) + data region.
    public var recordSize: Int {
        8 + 1 + 7 + dataRegionSize
    }

    /// Decoded `CalculationConfig`, or `nil` if the JSON is malformed.
    public var calculationConfig: CalculationConfig? {
        try? JSONDecoder().decode(CalculationConfig.self, from: Data(calculationConfigJson.utf8))
    }

    /// Decoded `OrbConfig`, or `nil` if the JSON is missing or malformed.
    public var orbConfig: OrbConfig? {
        guard let json = orbConfigJson else { return nil }
        return try? JSONDecoder().decode(OrbConfig.self, from: Data(json.utf8))
    }

    // MARK: - Init

    public init(
        enabledFactorIds: [Int],
        inquiryId: Int,
        houseSystemId: Int,
        calculationConfigJson: String,
        orbConfigJson: String? = nil,
        enabledAspectIds: [Int]? = nil,
        aspectOrbOverride: Double? = nil,
        unaspectOrbOverride: Double? = nil,
        declMidpointOrbOverride: Double? = nil,
        enabledDialSizes: [Int]? = nil,
        harmonicNumber: Int? = nil
    ) {
        self.enabledFactorIds = enabledFactorIds
        self.inquiryId = inquiryId
        self.houseSystemId = houseSystemId
        self.calculationConfigJson = calculationConfigJson
        self.orbConfigJson = orbConfigJson
        self.enabledAspectIds = enabledAspectIds
        self.aspectOrbOverride = aspectOrbOverride
        self.unaspectOrbOverride = unaspectOrbOverride
        self.declMidpointOrbOverride = declMidpointOrbOverride
        self.enabledDialSizes = enabledDialSizes
        self.harmonicNumber = harmonicNumber
    }

    // MARK: - JSON helpers

    /// Decodes a `ResearchConfig` from the JSON string stored in `ResearchProjectModel.config`.
    public static func from(json: String) throws -> ResearchConfig {
        guard let data = json.data(using: .utf8) else {
            throw ResearchConfigError.invalidJson
        }
        return try JSONDecoder().decode(ResearchConfig.self, from: data)
    }

    /// Encodes this config to a JSON string suitable for storage.
    public func toJson() throws -> String {
        let data = try JSONEncoder().encode(self)
        guard let json = String(data: data, encoding: .utf8) else {
            throw ResearchConfigError.encodingFailed
        }
        return json
    }
}

public enum ResearchConfigError: Error {
    case invalidJson
    case encodingFailed
}
