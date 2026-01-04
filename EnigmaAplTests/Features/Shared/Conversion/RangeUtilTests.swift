//
//  RangeUtilTests.swift
//  EnigmaAplTests
//
//  Created on 04/01/2026.
//

import Testing
import Foundation
@testable import EnigmaApl

struct RangeUtilTests {
    
    // MARK: - 0-360 Range Tests (Common for longitude normalization)
    
    @Test("RangeUtil: value already within 0-360 range")
    func testValueToRangeAlreadyInRange() {
        let result = RangeUtil.valueToRange(180.0, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 180.0)
    }
    
    @Test("RangeUtil: value at lower boundary (0)")
    func testValueToRangeAtLowerBoundary() {
        let result = RangeUtil.valueToRange(0.0, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 0.0)
    }
    
    @Test("RangeUtil: value just below upper boundary")
    func testValueToRangeJustBelowUpperBoundary() {
        let result = RangeUtil.valueToRange(359.9, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 359.9)
    }
    
    @Test("RangeUtil: value exactly at upper boundary (360) should wrap to 0")
    func testValueToRangeAtUpperBoundary() {
        let result = RangeUtil.valueToRange(360.0, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 0.0)
    }
    
    @Test("RangeUtil: value above upper boundary (370)")
    func testValueToRangeAboveUpperBoundary() {
        let result = RangeUtil.valueToRange(370.0, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 10.0)
    }
    
    @Test("RangeUtil: value well above upper boundary (720)")
    func testValueToRangeWellAboveUpperBoundary() {
        let result = RangeUtil.valueToRange(720.0, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 0.0)
    }
    
    @Test("RangeUtil: value well above upper boundary (1080)")
    func testValueToRangeVeryAboveUpperBoundary() {
        let result = RangeUtil.valueToRange(1080.0, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 0.0)
    }
    
    @Test("RangeUtil: value below lower boundary (-10)")
    func testValueToRangeBelowLowerBoundary() {
        let result = RangeUtil.valueToRange(-10.0, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 350.0)
    }
    
    @Test("RangeUtil: value well below lower boundary (-370)")
    func testValueToRangeWellBelowLowerBoundary() {
        let result = RangeUtil.valueToRange(-370.0, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 350.0)
    }
    
    @Test("RangeUtil: value well below lower boundary (-720)")
    func testValueToRangeVeryBelowLowerBoundary() {
        let result = RangeUtil.valueToRange(-720.0, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 0.0)
    }
    
    // MARK: - -180 to 180 Range Tests (Common for angle differences)
    
    @Test("RangeUtil: value already within -180 to 180 range")
    func testValueToRangeNegativeRangeAlreadyInRange() {
        let result = RangeUtil.valueToRange(90.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == 90.0)
    }
    
    @Test("RangeUtil: negative value within -180 to 180 range")
    func testValueToRangeNegativeValueInRange() {
        let result = RangeUtil.valueToRange(-90.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == -90.0)
    }
    
    @Test("RangeUtil: value at lower boundary (-180)")
    func testValueToRangeAtNegativeLowerBoundary() {
        let result = RangeUtil.valueToRange(-180.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == -180.0)
    }
    
    @Test("RangeUtil: value just below upper boundary (179.9)")
    func testValueToRangeJustBelowNegativeUpperBoundary() {
        let result = RangeUtil.valueToRange(179.9, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == 179.9)
    }
    
    @Test("RangeUtil: value at upper boundary (180) should wrap to -180")
    func testValueToRangeAtNegativeUpperBoundary() {
        let result = RangeUtil.valueToRange(180.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == -180.0)
    }
    
    @Test("RangeUtil: value above upper boundary (190)")
    func testValueToRangeAboveNegativeUpperBoundary() {
        let result = RangeUtil.valueToRange(190.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == -170.0)
    }
    
    @Test("RangeUtil: value well above upper boundary (360)")
    func testValueToRangeWellAboveNegativeUpperBoundary() {
        let result = RangeUtil.valueToRange(360.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == 0.0)
    }
    
    @Test("RangeUtil: value below lower boundary (-190)")
    func testValueToRangeBelowNegativeLowerBoundary() {
        let result = RangeUtil.valueToRange(-190.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == 170.0)
    }
    
    @Test("RangeUtil: value well below lower boundary (-360)")
    func testValueToRangeWellBelowNegativeLowerBoundary() {
        let result = RangeUtil.valueToRange(-360.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == 0.0)
    }
    
    // MARK: - Other Range Tests
    
    @Test("RangeUtil: small range (0-10)")
    func testValueToRangeSmallRange() {
        let result = RangeUtil.valueToRange(15.0, lowerLimit: 0.0, upperLimit: 10.0)
        #expect(result == 5.0)
    }
    
    @Test("RangeUtil: value in small range")
    func testValueToRangeInSmallRange() {
        let result = RangeUtil.valueToRange(5.0, lowerLimit: 0.0, upperLimit: 10.0)
        #expect(result == 5.0)
    }
    
    @Test("RangeUtil: negative range (-10 to 10)")
    func testValueToRangeNegativeSmallRange() {
        let result = RangeUtil.valueToRange(15.0, lowerLimit: -10.0, upperLimit: 10.0)
        #expect(result == -5.0)
    }
    
    @Test("RangeUtil: value in negative small range")
    func testValueToRangeInNegativeSmallRange() {
        let result = RangeUtil.valueToRange(-5.0, lowerLimit: -10.0, upperLimit: 10.0)
        #expect(result == -5.0)
    }
    
    @Test("RangeUtil: fractional range (0.0-1.0)")
    func testValueToRangeFractionalRange() {
        let result = RangeUtil.valueToRange(1.5, lowerLimit: 0.0, upperLimit: 1.0)
        #expect(result == 0.5)
    }
    
    @Test("RangeUtil: value in fractional range")
    func testValueToRangeInFractionalRange() {
        let result = RangeUtil.valueToRange(0.5, lowerLimit: 0.0, upperLimit: 1.0)
        #expect(result == 0.5)
    }
    
    // MARK: - Edge Cases
    
    @Test("RangeUtil: zero value in 0-360 range")
    func testValueToRangeZero() {
        let result = RangeUtil.valueToRange(0.0, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 0.0)
    }
    
    @Test("RangeUtil: very small positive value")
    func testValueToRangeVerySmallPositive() {
        let result = RangeUtil.valueToRange(0.0001, lowerLimit: 0.0, upperLimit: 360.0)
        let difference = abs(result - 0.0001)
        #expect(difference < 1e-10, "Expected 0.0001, got \(result), difference: \(difference)")
    }
    
    @Test("RangeUtil: very small negative value")
    func testValueToRangeVerySmallNegative() {
        let result = RangeUtil.valueToRange(-0.0001, lowerLimit: 0.0, upperLimit: 360.0)
        let difference = abs(result - 359.9999)
        #expect(difference < 1e-10, "Expected ~359.9999, got \(result), difference: \(difference)")
    }
    
    @Test("RangeUtil: large positive value (1000)")
    func testValueToRangeLargePositive() {
        let result = RangeUtil.valueToRange(1000.0, lowerLimit: 0.0, upperLimit: 360.0)
        // 1000 % 360 = 280
        #expect(result == 280.0)
    }
    
    @Test("RangeUtil: large negative value (-1000)")
    func testValueToRangeLargeNegative() {
        let result = RangeUtil.valueToRange(-1000.0, lowerLimit: 0.0, upperLimit: 360.0)
        // -1000 + 3*360 = -1000 + 1080 = 80
        #expect(result == 80.0)
    }
    
    // MARK: - Real-world Use Cases
    
    @Test("RangeUtil: normalize longitude 450 degrees")
    func testValueToRangeLongitude450() {
        let result = RangeUtil.valueToRange(450.0, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 90.0)
    }
    
    @Test("RangeUtil: normalize longitude -45 degrees")
    func testValueToRangeLongitudeNegative45() {
        let result = RangeUtil.valueToRange(-45.0, lowerLimit: 0.0, upperLimit: 360.0)
        #expect(result == 315.0)
    }
    
    @Test("RangeUtil: normalize angle difference 200 degrees")
    func testValueToRangeAngleDifference200() {
        let result = RangeUtil.valueToRange(200.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == -160.0)
    }
    
    @Test("RangeUtil: normalize angle difference -200 degrees")
    func testValueToRangeAngleDifferenceNegative200() {
        let result = RangeUtil.valueToRange(-200.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == 160.0)
    }
    
    @Test("RangeUtil: normalize angle difference 0 degrees")
    func testValueToRangeAngleDifferenceZero() {
        let result = RangeUtil.valueToRange(0.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == 0.0)
    }
    
    @Test("RangeUtil: normalize angle difference 180 degrees")
    func testValueToRangeAngleDifference180() {
        let result = RangeUtil.valueToRange(180.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == -180.0)
    }
    
    @Test("RangeUtil: normalize angle difference -180 degrees")
    func testValueToRangeAngleDifferenceNegative180() {
        let result = RangeUtil.valueToRange(-180.0, lowerLimit: -180.0, upperLimit: 180.0)
        #expect(result == -180.0)
    }
}

