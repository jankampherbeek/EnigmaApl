// DisplayConfig.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// The visual layout style for the astrological chart drawing.
public enum DrawingType: Int, CaseIterable, Codable {
    case signBased = 0
    case houseBased = 1
    case french = 2
    case ring = 3
    case dial360 = 4
    case dial90 = 5
    case dial45 = 6

    var rbKey: String {
        switch self {
        case .signBased:  return "enum.drawingtype.signbased"
        case .houseBased: return "enum.drawingtype.housebased"
        case .french:     return "enum.drawingtype.french"
        case .ring:       return "enum.drawingtype.ring"
        case .dial360:    return "enum.drawingtype.dial360"
        case .dial90:     return "enum.drawingtype.dial90"
        case .dial45:     return "enum.drawingtype.dial45"
        }
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
    /// Color overrides for zodiac signs. Empty by default.
    public let signColors: [SignColorOverride]

    public init(
        drawingType: DrawingType = .signBased,
        signColors: [SignColorOverride] = []
    ) {
        self.drawingType = drawingType
        self.signColors = signColors
    }
}
