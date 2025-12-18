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
        #expect(Coordinates.validateLongitude(-180.0) == true)
    }
    
    @Test("Longitude: valid value at upper bound (180.0)")
    func testLongitudeUpperBound() {
        #expect(Coordinates.validateLongitude(180.0) == true)
    }
    
    @Test("Longitude: valid value in middle (0.0)")
    func testLongitudeMiddle() {
        #expect(Coordinates.validateLongitude(0.0) == true)
    }
    
    @Test("Longitude: valid positive value")
    func testLongitudeValidPositive() {
        #expect(Coordinates.validateLongitude(45.5) == true)
    }
    
    @Test("Longitude: valid negative value")
    func testLongitudeValidNegative() {
        #expect(Coordinates.validateLongitude(-120.25) == true)
    }
    
    @Test("Longitude: invalid value below lower bound")
    func testLongitudeBelowLowerBound() {
        #expect(Coordinates.validateLongitude(-180.1) == false)
    }
    
    @Test("Longitude: invalid value above upper bound")
    func testLongitudeAboveUpperBound() {
        #expect(Coordinates.validateLongitude(180.1) == false)
    }
    
    @Test("Longitude: invalid value far below range")
    func testLongitudeFarBelowRange() {
        #expect(Coordinates.validateLongitude(-360.0) == false)
    }
    
    @Test("Longitude: invalid value far above range")
    func testLongitudeFarAboveRange() {
        #expect(Coordinates.validateLongitude(360.0) == false)
    }
    
    // MARK: - Latitude Validation Tests
    
    @Test("Latitude: valid value just above lower bound")
    func testLatitudeJustAboveLowerBound() {
        #expect(Coordinates.validateLatitude(-89.999) == true)
    }
    
    @Test("Latitude: valid value just below upper bound")
    func testLatitudeJustBelowUpperBound() {
        #expect(Coordinates.validateLatitude(89.999) == true)
    }
    
    @Test("Latitude: valid value at middle (0.0)")
    func testLatitudeMiddle() {
        #expect(Coordinates.validateLatitude(0.0) == true)
    }
    
    @Test("Latitude: valid positive value")
    func testLatitudeValidPositive() {
        #expect(Coordinates.validateLatitude(45.5) == true)
    }
    
    @Test("Latitude: valid negative value")
    func testLatitudeValidNegative() {
        #expect(Coordinates.validateLatitude(-30.25) == true)
    }
    
    @Test("Latitude: invalid value at lower bound (exclusive)")
    func testLatitudeAtLowerBound() {
        #expect(Coordinates.validateLatitude(-90.0) == false)
    }
    
    @Test("Latitude: invalid value at upper bound (exclusive)")
    func testLatitudeAtUpperBound() {
        #expect(Coordinates.validateLatitude(90.0) == false)
    }
    
    @Test("Latitude: invalid value below lower bound")
    func testLatitudeBelowLowerBound() {
        #expect(Coordinates.validateLatitude(-90.1) == false)
    }
    
    @Test("Latitude: invalid value above upper bound")
    func testLatitudeAboveUpperBound() {
        #expect(Coordinates.validateLatitude(90.1) == false)
    }
    
    @Test("Latitude: invalid value far below range")
    func testLatitudeFarBelowRange() {
        #expect(Coordinates.validateLatitude(-180.0) == false)
    }
    
    @Test("Latitude: invalid value far above range")
    func testLatitudeFarAboveRange() {
        #expect(Coordinates.validateLatitude(180.0) == false)
    }
}

