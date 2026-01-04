//
//  RangeUtil.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 04/01/2026.
//

import Foundation

/// Utility that handles conformance of a value to a given range
public struct RangeUtil {
    /// Forces a value to be within a given range.
    /// Adds or subtracts the size of the range until the value falls within the limits of the range.
    /// - Parameters:
    ///   - testValue: The value to check/adapt
    ///   - lowerLimit: Lower limit of the range (inclusive)
    ///   - upperLimit: Upper limit (exclusive)
    /// - Returns: The - if necessary corrected - value
    /// - Throws: An error if lowerLimit is not smaller than upperLimit
    public static func valueToRange(_ testValue: Double, lowerLimit: Double, upperLimit: Double) -> Double {
        guard upperLimit > lowerLimit else {
            fatalError("UpperRange: \(upperLimit) <= lowerLimit: \(lowerLimit)")
        }
        return forceToRange(testValue, lowerLimit: lowerLimit, upperLimit: upperLimit)
    }
    
    private static func forceToRange(_ testValue: Double, lowerLimit: Double, upperLimit: Double) -> Double {
        let rangeSize = upperLimit - lowerLimit
        let checkedForLowerLimit = forceLowerLimit(lowerLimit: lowerLimit, rangeSize: rangeSize, toCheck: testValue)
        return forceUpperLimit(upperLimit: upperLimit, rangeSize: rangeSize, toCheck: checkedForLowerLimit)
    }
    
    private static func forceLowerLimit(lowerLimit: Double, rangeSize: Double, toCheck: Double) -> Double {
        var checkedForUpperLimit = toCheck
        while checkedForUpperLimit < lowerLimit {
            checkedForUpperLimit += rangeSize
        }
        return checkedForUpperLimit
    }
    
    private static func forceUpperLimit(upperLimit: Double, rangeSize: Double, toCheck: Double) -> Double {
        var checkedForLowerLimit = toCheck
        while checkedForLowerLimit >= upperLimit {
            checkedForLowerLimit -= rangeSize
        }
        return checkedForLowerLimit
    }
}

