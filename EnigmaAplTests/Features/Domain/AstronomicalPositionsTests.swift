//
//  AstronomicalPositionsTests.swift
//  EnigmaAplTests
//
//  Created on 21/12/2025.
//

import Testing
@testable import EnigmaApl

struct AstronomicalPositionsTests {
    
    // MARK: - HousePositions Tests
    
    // Helper function to create FullCuspPosition for testing
    func createCuspPosition(longitude: Double, rightAscension: Double = 0.0, declination: Double = 0.0, azimuth: Double = 0.0, altitude: Double = 0.0) -> FullCuspPosition {
        return FullCuspPosition(
            longitude: longitude,
            rightAscension: rightAscension,
            declination: declination,
            horizontal: HorizontalPosition(azimuth: azimuth, altitude: altitude)
        )
    }
    
    @Test("HousePositions: initialization with all parameters")
    func testHousePositionsFullInitialization() {
        let cusps = [
            createCuspPosition(longitude: 0.0),
            createCuspPosition(longitude: 30.0),
            createCuspPosition(longitude: 60.0),
            createCuspPosition(longitude: 90.0),
            createCuspPosition(longitude: 120.0),
            createCuspPosition(longitude: 150.0),
            createCuspPosition(longitude: 180.0),
            createCuspPosition(longitude: 210.0),
            createCuspPosition(longitude: 240.0),
            createCuspPosition(longitude: 270.0),
            createCuspPosition(longitude: 300.0),
            createCuspPosition(longitude: 330.0),
            createCuspPosition(longitude: 360.0)
        ]
        let housePositions = HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: 15.5),
            midheaven: createCuspPosition(longitude: 90.0),
            eastpoint: createCuspPosition(longitude: 105.0),
            vertex: createCuspPosition(longitude: 195.0)
        )
        
        #expect(housePositions.cusps.count == 13)
        #expect(housePositions.ascendant.longitude == 15.5)
        #expect(housePositions.midheaven.longitude == 90.0)
        #expect(housePositions.eastpoint.longitude == 105.0)
        #expect(housePositions.vertex.longitude == 195.0)
    }
    
    @Test("HousePositions: cusps array matches input")
    func testHousePositionsCuspsArray() {
        let cusps = [
            createCuspPosition(longitude: 10.0),
            createCuspPosition(longitude: 20.0),
            createCuspPosition(longitude: 30.0),
            createCuspPosition(longitude: 40.0),
            createCuspPosition(longitude: 50.0),
            createCuspPosition(longitude: 60.0),
            createCuspPosition(longitude: 70.0),
            createCuspPosition(longitude: 80.0),
            createCuspPosition(longitude: 90.0),
            createCuspPosition(longitude: 100.0),
            createCuspPosition(longitude: 110.0),
            createCuspPosition(longitude: 120.0),
            createCuspPosition(longitude: 130.0)
        ]
        let housePositions = HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: 10.0),
            midheaven: createCuspPosition(longitude: 100.0),
            eastpoint: createCuspPosition(longitude: 110.0),
            vertex: createCuspPosition(longitude: 200.0)
        )
        
        #expect(housePositions.cusps.count == 13)
        #expect(housePositions.cusps[0].longitude == 10.0)
        #expect(housePositions.cusps[12].longitude == 130.0)
    }
    
    @Test("HousePositions: empty cusps array")
    func testHousePositionsEmptyCusps() {
        let housePositions = HousePositions(
            cusps: [],
            ascendant: createCuspPosition(longitude: 0.0),
            midheaven: createCuspPosition(longitude: 0.0),
            eastpoint: createCuspPosition(longitude: 0.0),
            vertex: createCuspPosition(longitude: 0.0)
        )
        
        #expect(housePositions.cusps.isEmpty)
        #expect(housePositions.ascendant.longitude == 0.0)
        #expect(housePositions.midheaven.longitude == 0.0)
    }
    
    @Test("HousePositions: standard 12 house cusps")
    func testHousePositionsStandard12Houses() {
        // Standard 12 houses plus one extra (13 elements total)
        let cusps = [
            createCuspPosition(longitude: 0.0),
            createCuspPosition(longitude: 30.0),
            createCuspPosition(longitude: 60.0),
            createCuspPosition(longitude: 90.0),
            createCuspPosition(longitude: 120.0),
            createCuspPosition(longitude: 150.0),
            createCuspPosition(longitude: 180.0),
            createCuspPosition(longitude: 210.0),
            createCuspPosition(longitude: 240.0),
            createCuspPosition(longitude: 270.0),
            createCuspPosition(longitude: 300.0),
            createCuspPosition(longitude: 330.0),
            createCuspPosition(longitude: 360.0)
        ]
        let housePositions = HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: 0.0),
            midheaven: createCuspPosition(longitude: 90.0),
            eastpoint: createCuspPosition(longitude: 90.0),
            vertex: createCuspPosition(longitude: 270.0)
        )
        
        #expect(housePositions.cusps.count == 13)
        #expect(housePositions.cusps[1].longitude == 30.0) // First house cusp
        #expect(housePositions.cusps[12].longitude == 360.0) // Last cusp
    }
    
    @Test("HousePositions: ascendant value")
    func testHousePositionsAscendant() {
        let cusps = [
            createCuspPosition(longitude: 0.0),
            createCuspPosition(longitude: 30.0),
            createCuspPosition(longitude: 60.0),
            createCuspPosition(longitude: 90.0),
            createCuspPosition(longitude: 120.0),
            createCuspPosition(longitude: 150.0),
            createCuspPosition(longitude: 180.0),
            createCuspPosition(longitude: 210.0),
            createCuspPosition(longitude: 240.0),
            createCuspPosition(longitude: 270.0),
            createCuspPosition(longitude: 300.0),
            createCuspPosition(longitude: 330.0),
            createCuspPosition(longitude: 360.0)
        ]
        let housePositions = HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: 15.5125),
            midheaven: createCuspPosition(longitude: 90.0),
            eastpoint: createCuspPosition(longitude: 105.0),
            vertex: createCuspPosition(longitude: 195.0)
        )
        
        #expect(housePositions.ascendant.longitude == 15.5125)
    }
    
    @Test("HousePositions: midheaven value")
    func testHousePositionsMidheaven() {
        let cusps = [
            createCuspPosition(longitude: 0.0),
            createCuspPosition(longitude: 30.0),
            createCuspPosition(longitude: 60.0),
            createCuspPosition(longitude: 90.0),
            createCuspPosition(longitude: 120.0),
            createCuspPosition(longitude: 150.0),
            createCuspPosition(longitude: 180.0),
            createCuspPosition(longitude: 210.0),
            createCuspPosition(longitude: 240.0),
            createCuspPosition(longitude: 270.0),
            createCuspPosition(longitude: 300.0),
            createCuspPosition(longitude: 330.0),
            createCuspPosition(longitude: 360.0)
        ]
        let housePositions = HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: 0.0),
            midheaven: createCuspPosition(longitude: 90.1234),
            eastpoint: createCuspPosition(longitude: 105.0),
            vertex: createCuspPosition(longitude: 195.0)
        )
        
        #expect(housePositions.midheaven.longitude == 90.1234)
    }
    
    @Test("HousePositions: eastpoint value")
    func testHousePositionsEastpoint() {
        let cusps = [
            createCuspPosition(longitude: 0.0),
            createCuspPosition(longitude: 30.0),
            createCuspPosition(longitude: 60.0),
            createCuspPosition(longitude: 90.0),
            createCuspPosition(longitude: 120.0),
            createCuspPosition(longitude: 150.0),
            createCuspPosition(longitude: 180.0),
            createCuspPosition(longitude: 210.0),
            createCuspPosition(longitude: 240.0),
            createCuspPosition(longitude: 270.0),
            createCuspPosition(longitude: 300.0),
            createCuspPosition(longitude: 330.0),
            createCuspPosition(longitude: 360.0)
        ]
        let housePositions = HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: 0.0),
            midheaven: createCuspPosition(longitude: 90.0),
            eastpoint: createCuspPosition(longitude: 105.5678),
            vertex: createCuspPosition(longitude: 195.0)
        )
        
        #expect(housePositions.eastpoint.longitude == 105.5678)
    }
    
    @Test("HousePositions: vertex value")
    func testHousePositionsVertex() {
        let cusps = [
            createCuspPosition(longitude: 0.0),
            createCuspPosition(longitude: 30.0),
            createCuspPosition(longitude: 60.0),
            createCuspPosition(longitude: 90.0),
            createCuspPosition(longitude: 120.0),
            createCuspPosition(longitude: 150.0),
            createCuspPosition(longitude: 180.0),
            createCuspPosition(longitude: 210.0),
            createCuspPosition(longitude: 240.0),
            createCuspPosition(longitude: 270.0),
            createCuspPosition(longitude: 300.0),
            createCuspPosition(longitude: 330.0),
            createCuspPosition(longitude: 360.0)
        ]
        let housePositions = HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: 0.0),
            midheaven: createCuspPosition(longitude: 90.0),
            eastpoint: createCuspPosition(longitude: 105.0),
            vertex: createCuspPosition(longitude: 195.9999)
        )
        
        #expect(housePositions.vertex.longitude == 195.9999)
    }
    
    @Test("HousePositions: all angles at zero")
    func testHousePositionsAllAnglesZero() {
        let cusps = Array(repeating: createCuspPosition(longitude: 0.0), count: 13)
        let housePositions = HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: 0.0),
            midheaven: createCuspPosition(longitude: 0.0),
            eastpoint: createCuspPosition(longitude: 0.0),
            vertex: createCuspPosition(longitude: 0.0)
        )
        
        #expect(housePositions.ascendant.longitude == 0.0)
        #expect(housePositions.midheaven.longitude == 0.0)
        #expect(housePositions.eastpoint.longitude == 0.0)
        #expect(housePositions.vertex.longitude == 0.0)
    }
    
    @Test("HousePositions: negative angle values")
    func testHousePositionsNegativeAngles() {
        let cusps = [
            createCuspPosition(longitude: -10.0),
            createCuspPosition(longitude: 0.0),
            createCuspPosition(longitude: 10.0),
            createCuspPosition(longitude: 20.0),
            createCuspPosition(longitude: 30.0),
            createCuspPosition(longitude: 40.0),
            createCuspPosition(longitude: 50.0),
            createCuspPosition(longitude: 60.0),
            createCuspPosition(longitude: 70.0),
            createCuspPosition(longitude: 80.0),
            createCuspPosition(longitude: 90.0),
            createCuspPosition(longitude: 100.0),
            createCuspPosition(longitude: 110.0)
        ]
        let housePositions = HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: -5.0),
            midheaven: createCuspPosition(longitude: 90.0),
            eastpoint: createCuspPosition(longitude: 105.0),
            vertex: createCuspPosition(longitude: 195.0)
        )
        
        #expect(housePositions.ascendant.longitude == -5.0)
        #expect(housePositions.cusps[0].longitude == -10.0)
    }
    
    @Test("HousePositions: large angle values (over 360)")
    func testHousePositionsLargeAngles() {
        let cusps = [
            createCuspPosition(longitude: 360.0),
            createCuspPosition(longitude: 390.0),
            createCuspPosition(longitude: 420.0),
            createCuspPosition(longitude: 450.0),
            createCuspPosition(longitude: 480.0),
            createCuspPosition(longitude: 510.0),
            createCuspPosition(longitude: 540.0),
            createCuspPosition(longitude: 570.0),
            createCuspPosition(longitude: 600.0),
            createCuspPosition(longitude: 630.0),
            createCuspPosition(longitude: 660.0),
            createCuspPosition(longitude: 690.0),
            createCuspPosition(longitude: 720.0)
        ]
        let housePositions = HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: 375.0),
            midheaven: createCuspPosition(longitude: 450.0),
            eastpoint: createCuspPosition(longitude: 465.0),
            vertex: createCuspPosition(longitude: 555.0)
        )
        
        #expect(housePositions.ascendant.longitude == 375.0)
        #expect(housePositions.midheaven.longitude == 450.0)
        #expect(housePositions.cusps[12].longitude == 720.0)
    }
    
    @Test("HousePositions: precise decimal values")
    func testHousePositionsPreciseDecimals() {
        let cusps = [
            createCuspPosition(longitude: 0.123456),
            createCuspPosition(longitude: 30.234567),
            createCuspPosition(longitude: 60.345678),
            createCuspPosition(longitude: 90.456789),
            createCuspPosition(longitude: 120.567890),
            createCuspPosition(longitude: 150.678901),
            createCuspPosition(longitude: 180.789012),
            createCuspPosition(longitude: 210.890123),
            createCuspPosition(longitude: 240.901234),
            createCuspPosition(longitude: 270.012345),
            createCuspPosition(longitude: 300.123456),
            createCuspPosition(longitude: 330.234567),
            createCuspPosition(longitude: 360.345678)
        ]
        let housePositions = HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: 15.123456789),
            midheaven: createCuspPosition(longitude: 90.987654321),
            eastpoint: createCuspPosition(longitude: 105.111111111),
            vertex: createCuspPosition(longitude: 195.999999999)
        )
        
        #expect(housePositions.ascendant.longitude == 15.123456789)
        #expect(housePositions.midheaven.longitude == 90.987654321)
        #expect(housePositions.eastpoint.longitude == 105.111111111)
        #expect(housePositions.vertex.longitude == 195.999999999)
        #expect(housePositions.cusps[0].longitude == 0.123456)
    }
    
    @Test("HousePositions: cusps array immutability")
    func testHousePositionsCuspsImmutability() {
        var originalCusps = [
            createCuspPosition(longitude: 10.0),
            createCuspPosition(longitude: 20.0),
            createCuspPosition(longitude: 30.0)
        ]
        let housePositions = HousePositions(
            cusps: originalCusps,
            ascendant: createCuspPosition(longitude: 10.0),
            midheaven: createCuspPosition(longitude: 100.0),
            eastpoint: createCuspPosition(longitude: 110.0),
            vertex: createCuspPosition(longitude: 200.0)
        )
        
        // Modify original array
        originalCusps.append(createCuspPosition(longitude: 40.0))
        
        // HousePositions cusps should remain unchanged
        #expect(housePositions.cusps.count == 3)
        #expect(originalCusps.count == 4)
    }
    
    @Test("HousePositions: typical astrological values")
    func testHousePositionsTypicalAstrologicalValues() {
        // Typical house cusps for a chart
        let cusps = [
            createCuspPosition(longitude: 0.0),
            createCuspPosition(longitude: 45.5),
            createCuspPosition(longitude: 75.25),
            createCuspPosition(longitude: 105.0),
            createCuspPosition(longitude: 135.75),
            createCuspPosition(longitude: 165.5),
            createCuspPosition(longitude: 195.0),
            createCuspPosition(longitude: 225.5),
            createCuspPosition(longitude: 255.25),
            createCuspPosition(longitude: 285.0),
            createCuspPosition(longitude: 315.75),
            createCuspPosition(longitude: 345.5),
            createCuspPosition(longitude: 360.0)
        ]
        let housePositions = HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: 15.5),  // Aries 15°30'
            midheaven: createCuspPosition(longitude: 105.0), // Cancer 15°
            eastpoint: createCuspPosition(longitude: 105.0),
            vertex: createCuspPosition(longitude: 195.0)     // Libra 15°
        )
        
        #expect(housePositions.cusps.count == 13)
        #expect(housePositions.ascendant.longitude == 15.5)
        #expect(housePositions.midheaven.longitude == 105.0)
        #expect(housePositions.cusps[1].longitude == 45.5) // First house cusp
        #expect(housePositions.cusps[4].longitude == 135.75) // Fourth house cusp
    }
}

