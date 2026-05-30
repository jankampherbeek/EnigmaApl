// SpeedType.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Type of movement speed for a celestial factor
public enum SpeedType: Int, CaseIterable {
    case direct = 0
    case retrograde = 1
    case slow = 2
    case slowRetrograde = 3
    case stationaryRetrograde = 4
    case stationaryDirect = 5

    /// Resource bundle key for localized name
    var rbKey: String {
        switch self {
        case .direct:               return "enum.speedtype.direct"
        case .retrograde:           return "enum.speedtype.retrograde"
        case .slow:                 return "enum.speedtype.slow"
        case .slowRetrograde:       return "enum.speedtype.slowretrograde"
        case .stationaryRetrograde: return "enum.speedtype.stationaryretrograde"
        case .stationaryDirect:     return "enum.speedtype.stationarydirect"
        }
    }

    /// Short abbreviation used in chart wheels (Direct is not shown)
    var abbreviation: String {
        switch self {
        case .direct:               return "D"
        case .retrograde:           return "R"
        case .slow:                 return "L"
        case .slowRetrograde:       return "LR"
        case .stationaryRetrograde: return "SR"
        case .stationaryDirect:     return "SD"
        }
    }
}
