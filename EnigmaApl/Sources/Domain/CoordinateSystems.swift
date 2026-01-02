//
//  CoordinateSystems.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 01/01/2025.
//

import Foundation

/// Coordinate systems, used to define a position
public enum CoordinateSystems: Int, CaseIterable {
    case ecliptical = 0
    case equatorial = 1
    case horizontal = 3
    
    /// Value for flag construction as defined by the Swiss Ephemeris
    var valueForFlag: Int {
        switch self {
        case .ecliptical: return 0  // No specific flags for ecliptical
        case .equatorial: return 2048  // SEFLG_EQUATORIAL (2*1024)
        case .horizontal: return 0  // No specific flags for horizontal
        }
    }
    
    /// Resource bundle key for localized name
    var rbKey: String {
        switch self {
        case .ecliptical: return "enum.coordinatesys.ecliptic"
        case .equatorial: return "enum.coordinatesys.equatorial"
        case .horizontal: return "enum.coordinatesys.horizontal"
        }
    }
    
    /// Find coordinate system for a given index
    /// - Parameter index: The index (raw value)
    /// - Returns: The coordinate system if found, nil otherwise
    static func fromIndex(_ index: Int) -> CoordinateSystems? {
        return CoordinateSystems(rawValue: index)
    }
}

