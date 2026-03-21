//
//  ObserverPositions.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 01/01/2025.
//

import Foundation

/// Observer positions, the center points for the calculation of positions of celestial bodies
public enum ObserverPositions: Int, CaseIterable, Codable {
    case geoCentric = 0
    case topoCentric = 1
    case helioCentric = 2
    
    
    /// Resource bundle key for localized name
    var rbKey: String { ObserverPositionKeys.key(for: self) }
    
    /// Find observer position for a given index
    /// - Parameter index: The index (raw value)
    /// - Returns: The observer position if found, nil otherwise
    static func fromIndex(_ index: Int) -> ObserverPositions? {
        return ObserverPositions(rawValue: index)
    }
}
