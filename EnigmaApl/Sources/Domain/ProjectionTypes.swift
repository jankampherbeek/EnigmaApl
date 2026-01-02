//
//  ProjectionTypes.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 01/01/2026.
//

import Foundation

/// Projection of the positions of celestial bodies
/// - TwoDimensional: the default type of projection to a 2-dimensional chart
/// - ObliqueLongitude: a correction for the mundane position, also called 'true location', as used by the School of Ram
public enum ProjectionTypes: Int, CaseIterable {
    case twoDimensional = 0
    case obliqueLongitude = 1
    
    /// Resource bundle key for localized name
    var rbKey: String {
        switch self {
        case .twoDimensional: return "enum.projectiontype.twodimensional"
        case .obliqueLongitude: return "enum.projectiontype.obliquelongitude"
        }
    }
    
    /// Find projection type for a given index
    /// - Parameter index: The index (raw value)
    /// - Returns: The projection type if found, nil otherwise
    static func fromIndex(_ index: Int) -> ProjectionTypes? {
        return ProjectionTypes(rawValue: index)
    }
}
