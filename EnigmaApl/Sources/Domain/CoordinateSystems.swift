// CoordinateSystems.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

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
    var rbKey: String { CoordinateSystemKeys.key(for: self) }
    
    /// Find coordinate system for a given index
    /// - Parameter index: The index (raw value)
    /// - Returns: The coordinate system if found, nil otherwise
    static func fromIndex(_ index: Int) -> CoordinateSystems? {
        return CoordinateSystems(rawValue: index)
    }
}

