//
//  ZodiacTypes.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 01/01/2025.
//

import Foundation

/// Zodiac types, e.g. sidereal or tropical
public enum ZodiacTypes: Int, CaseIterable {
    case sidereal = 0
    case tropical = 1
    
    /// Value for flag construction as defined by the Swiss Ephemeris
    var valueForFlag: Int {
        switch self {
        case .tropical: return 0  // No specific flag for tropical
        case .sidereal: return 65536  // SEFLG_SIDEREAL (64*1024)
        }
    }
    
    /// Resource bundle key for localized name
    var rbKey: String {
        switch self {
        case .sidereal: return "enum.zodiactype.sidereal"
        case .tropical: return "enum.zodiactype.tropical"
        }
    }
    
    /// Find zodiac type for a given index
    /// - Parameter index: The index (raw value)
    /// - Returns: The zodiac type if found, nil otherwise
    static func fromIndex(_ index: Int) -> ZodiacTypes? {
        return ZodiacTypes(rawValue: index)
    }
}

