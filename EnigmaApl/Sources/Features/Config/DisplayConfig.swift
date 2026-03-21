//
//  DisplayConfig.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Foundation

/// The visual layout style for the astrological chart drawing.
public enum DrawingType: Int, CaseIterable, Codable {
    case signBased = 0
    case houseBased = 1
    case french = 2

    var rbKey: String {
        switch self {
        case .signBased:  return "enum.drawingtype.signbased"
        case .houseBased: return "enum.drawingtype.housebased"
        case .french:     return "enum.drawingtype.french"
        }
    }
}

/// Color override for a single celestial factor.
public struct FactorColorOverride: Codable, Equatable, Sendable {
    public let factor: Factors
    public let color: ColorConfig

    public init(factor: Factors, color: ColorConfig) {
        self.factor = factor
        self.color = color
    }
}

/// Color override for a single zodiac sign.
public struct SignColorOverride: Codable, Equatable, Sendable {
    public let sign: Signs
    public let color: ColorConfig

    public init(sign: Signs, color: ColorConfig) {
        self.sign = sign
        self.color = color
    }
}

/// Configuration for display and visual settings.
public struct DisplayConfig: Codable, Sendable {
    public let drawingType: DrawingType
    /// Color overrides for factors. Empty by default.
    public let factorColors: [FactorColorOverride]
    /// Color overrides for zodiac signs. Empty by default.
    public let signColors: [SignColorOverride]

    public init(
        drawingType: DrawingType = .signBased,
        factorColors: [FactorColorOverride] = [],
        signColors: [SignColorOverride] = []
    ) {
        self.drawingType = drawingType
        self.factorColors = factorColors
        self.signColors = signColors
    }
}
