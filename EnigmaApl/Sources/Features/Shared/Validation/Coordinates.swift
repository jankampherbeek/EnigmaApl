//
//  coordinates.swift
//  EnigmaApl
//
//  Created on 17/12/2025.
//

import Foundation

/// Struct for validating geographic coordinates (latitude and longitude)
public struct coordinates {
    
    /// Validates a longitude value
    /// - Parameter value: The longitude value to validate
    /// - Returns: True if the value is between -180.0 and 180.0 (inclusive), false otherwise
    public static func validateLongitude(_ value: Double) -> Bool {
        return value >= -180.0 && value <= 180.0
    }
    
    /// Validates a latitude value
    /// - Parameter value: The latitude value to validate
    /// - Returns: True if the value is between -90.0 and 90.0 (exclusive), false otherwise
    public static func validateLatitude(_ value: Double) -> Bool {
        return value > -90.0 && value < 90.0
    }
}

