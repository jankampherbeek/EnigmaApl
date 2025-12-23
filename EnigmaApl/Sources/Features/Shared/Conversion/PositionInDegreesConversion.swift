//
//  PositionInDegrees
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 18/12/2025.
//

import Foundation

struct PositionInDegreesConversion {
    
    /// Converts a double to a formatted string with degrees, minutes, and seconds.
    /// Format: "degrees°minutes'seconds"" with zero-padding for minutes/seconds < 10.
    /// - Parameter value: The double value in degrees
    /// - Returns: Formatted string (e.g., "45°30'15"")
    static func DoubleToDms(_ value: Double) -> String {
        let totalSeconds = Int(abs(value) * 3600)
        let degrees = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        let sign = value < 0 ? "-" : ""
        let minutesStr = String(format: "%02d", minutes)
        let secondsStr = String(format: "%02d", seconds)
        
        return "\(sign)\(degrees)°\(minutesStr)'\(secondsStr)\""
    }
    
    /// Converts a double to a formatted string with degrees, minutes, seconds, and zodiac sign.
    /// Format: "degrees°minutes'seconds\"" where degrees are within the sign (0-29).
    /// - Parameter value: The double value in degrees (must be >= 0.0 and < 360.0)
    /// - Returns: A tuple containing the DMS string, the Signs enum, and a boolean indicating success (false if value < 0.0 or >= 360.0)
    static func DoubleToDmsSign(_ value: Double) -> (String, Signs?, Bool) {
        guard value >= 0.0 && value < 360.0 else {
            return ("", nil, false)
        }
        
        // Determine the sign
        let signIndex = Int(value / 30.0)
        let sign: Signs
        
        switch signIndex {
        case 0: sign = .Aries
        case 1: sign = .Taurus
        case 2: sign = .Gemini
        case 3: sign = .Cancer
        case 4: sign = .Leo
        case 5: sign = .Virgo
        case 6: sign = .Libra
        case 7: sign = .Scorpio
        case 8: sign = .Sagittarius
        case 9: sign = .Capricorn
        case 10: sign = .Aquarius
        case 11: sign = .Pisces
        default: sign = .Pisces // Should not happen, but handle edge case
        }
        
        // Calculate degrees within the sign (0-29.999...)
        let degreesInSign = value.truncatingRemainder(dividingBy: 30.0)
        
        // Convert to DMS format
        let totalSeconds = Int(abs(degreesInSign) * 3600)
        let degrees = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        let minutesStr = String(format: "%02d", minutes)
        let secondsStr = String(format: "%02d", seconds)
        
        let dmsString = "\(degrees)°\(minutesStr)'\(secondsStr)\""
        return (dmsString, sign, true)
    }
    
    /// Converts a double to a formatted string with decimal degrees.
    /// Format: "degrees.decimal°" with variable precision.
    /// - Parameters:
    ///   - value: The double value in degrees
    ///   - decimalPlaces: Number of digits after the decimal point (default: 2)
    /// - Returns: Formatted string (e.g., "45.50°")
    static func DoubleToDegrees(_ value: Double, decimalPlaces: Int = 2) -> String {
        let format = String(format: "%%.%df", decimalPlaces)
        let formattedValue = String(format: format, abs(value))
        let sign = value < 0 ? "-" : ""
        return "\(sign)\(formattedValue)°"
    }
}
