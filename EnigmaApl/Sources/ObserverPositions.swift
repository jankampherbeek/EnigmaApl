//
//  ObserverPositions.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 01/01/2025.
//

import Foundation

/// Observer positions, the center points for the calculation of positions of celestial bodies
public enum ObserverPositions: Int, CaseIterable {
    case geoCentric = 0
    case topoCentric = 1
    case helioCentric = 2
    
    
    /// Resource bundle key for localized name
    var rbKey: String {
        switch self {
        case .geoCentric: return "enum.observerpos.geocentric"
        case .topoCentric: return "enum.observerpos.topocentric"
        case .helioCentric: return "enum.observerpos.heliocentric"
        }
    }
    
    /// Find observer position for a given index
    /// - Parameter index: The index (raw value)
    /// - Returns: The observer position if found, nil otherwise
    static func fromIndex(_ index: Int) -> ObserverPositions? {
        return ObserverPositions(rawValue: index)
    }
}
