//
//  CoordinatesTests.swift
//  EnigmaAplTests
//
//  Created on 17/12/2025.
//

import Testing
@testable import EnigmaApl

struct CoordinatesTests {
    
    // MARK: - Longitude Validation Tests
    
    @Test("Longitude: valid value at lower bound (-180.0)")
    func testLongitudeLowerBound() {
        #expect(CoordinateValidation.validateLongitude(-180.0) == true)
    }
    
    @Test("Longitude: valid value at upper bound (180.0)")
    func testLongitudeUpperBound() {
        #expect(CoordinateValidation.validateLongitude(180.0) == true)
    }
    
    @Test("Longitude: valid value in middle (0.0)")
    func testLongitudeMiddle() {
        #expect(CoordinateValidation.validateLongitude(0.0) == true)
    }
    
    @Test("Longitude: valid positive value")
    func testLongitudeValidPositive() {
        #expect(CoordinateValidation.validateLongitude(45.5) == true)
    }
    
    @Test("Longitude: valid negative value")
    func testLongitudeValidNegative() {
        #expect(CoordinateValidation.validateLongitude(-120.25) == true)
    }
    
    @Test("Longitude: invalid value below lower bound")
    func testLongitudeBelowLowerBound() {
        #expect(CoordinateValidation.validateLongitude(-180.1) == false)
    }
    
    @Test("Longitude: invalid value above upper bound")
    func testLongitudeAboveUpperBound() {
        #expect(CoordinateValidation.validateLongitude(180.1) == false)
    }
    
    @Test("Longitude: invalid value far below range")
    func testLongitudeFarBelowRange() {
        #expect(CoordinateValidation.validateLongitude(-360.0) == false)
    }
    
    @Test("Longitude: invalid value far above range")
    func testLongitudeFarAboveRange() {
        #expect(CoordinateValidation.validateLongitude(360.0) == false)
    }
    
    // MARK: - Latitude Validation Tests
    
    @Test("Latitude: valid value just above lower bound")
    func testLatitudeJustAboveLowerBound() {
        #expect(CoordinateValidation.validateLatitude(-89.999) == true)
    }
    
    @Test("Latitude: valid value just below upper bound")
    func testLatitudeJustBelowUpperBound() {
        #expect(CoordinateValidation.validateLatitude(89.999) == true)
    }
    
    @Test("Latitude: valid value at middle (0.0)")
    func testLatitudeMiddle() {
        #expect(CoordinateValidation.validateLatitude(0.0) == true)
    }
    
    @Test("Latitude: valid positive value")
    func testLatitudeValidPositive() {
        #expect(CoordinateValidation.validateLatitude(45.5) == true)
    }
    
    @Test("Latitude: valid negative value")
    func testLatitudeValidNegative() {
        #expect(CoordinateValidation.validateLatitude(-30.25) == true)
    }
    
    @Test("Latitude: invalid value at lower bound (exclusive)")
    func testLatitudeAtLowerBound() {
        #expect(CoordinateValidation.validateLatitude(-90.0) == false)
    }
    
    @Test("Latitude: invalid value at upper bound (exclusive)")
    func testLatitudeAtUpperBound() {
        #expect(CoordinateValidation.validateLatitude(90.0) == false)
    }
    
    @Test("Latitude: invalid value below lower bound")
    func testLatitudeBelowLowerBound() {
        #expect(CoordinateValidation.validateLatitude(-90.1) == false)
    }
    
    @Test("Latitude: invalid value above upper bound")
    func testLatitudeAboveUpperBound() {
        #expect(CoordinateValidation.validateLatitude(90.1) == false)
    }
    
    @Test("Latitude: invalid value far below range")
    func testLatitudeFarBelowRange() {
        #expect(CoordinateValidation.validateLatitude(-180.0) == false)
    }
    
    @Test("Latitude: invalid value far above range")
    func testLatitudeFarAboveRange() {
        #expect(CoordinateValidation.validateLatitude(180.0) == false)
    }
}

