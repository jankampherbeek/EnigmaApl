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
    
    // MARK: - ApsidesResult Tests
    
    @Test("ApsidesResult: initialization with all parameters")
    func testApsidesResultFullInitialization() {
        let ascendingNode = [120.5, 5.2, 1.0]
        let descendingNode = [300.5, -5.2, 1.0]
        let perihelion = [280.0, 0.0, 0.98]
        let aphelion = [100.0, 0.0, 1.02]
        
        let apsidesResult = ApsidesResult(
            ascendingNode: ascendingNode,
            descendingNode: descendingNode,
            perihelion: perihelion,
            aphelion: aphelion
        )
        
        #expect(apsidesResult.ascendingNode.count == 3)
        #expect(apsidesResult.descendingNode.count == 3)
        #expect(apsidesResult.perihelion.count == 3)
        #expect(apsidesResult.aphelion.count == 3)
        
        #expect(apsidesResult.ascendingNode[0] == 120.5) // longitude
        #expect(apsidesResult.ascendingNode[1] == 5.2)  // latitude
        #expect(apsidesResult.ascendingNode[2] == 1.0)   // distance
        
        #expect(apsidesResult.descendingNode[0] == 300.5) // longitude
        #expect(apsidesResult.descendingNode[1] == -5.2)  // latitude
        #expect(apsidesResult.descendingNode[2] == 1.0)   // distance
        
        #expect(apsidesResult.perihelion[0] == 280.0) // longitude
        #expect(apsidesResult.perihelion[1] == 0.0)    // latitude
        #expect(apsidesResult.perihelion[2] == 0.98)   // distance
        
        #expect(apsidesResult.aphelion[0] == 100.0) // longitude
        #expect(apsidesResult.aphelion[1] == 0.0)   // latitude
        #expect(apsidesResult.aphelion[2] == 1.02)  // distance
    }
    
    @Test("ApsidesResult: all values at zero")
    func testApsidesResultAllValuesZero() {
        let zeroArray = [0.0, 0.0, 0.0]
        let apsidesResult = ApsidesResult(
            ascendingNode: zeroArray,
            descendingNode: zeroArray,
            perihelion: zeroArray,
            aphelion: zeroArray
        )
        
        #expect(apsidesResult.ascendingNode[0] == 0.0)
        #expect(apsidesResult.ascendingNode[1] == 0.0)
        #expect(apsidesResult.ascendingNode[2] == 0.0)
        
        #expect(apsidesResult.descendingNode[0] == 0.0)
        #expect(apsidesResult.perihelion[0] == 0.0)
        #expect(apsidesResult.aphelion[0] == 0.0)
    }
    
    @Test("ApsidesResult: negative latitude values")
    func testApsidesResultNegativeLatitude() {
        let ascendingNode = [180.0, -23.5, 1.0]
        let descendingNode = [0.0, 23.5, 1.0]
        let perihelion = [270.0, -5.0, 0.95]
        let aphelion = [90.0, 5.0, 1.05]
        
        let apsidesResult = ApsidesResult(
            ascendingNode: ascendingNode,
            descendingNode: descendingNode,
            perihelion: perihelion,
            aphelion: aphelion
        )
        
        #expect(apsidesResult.ascendingNode[1] == -23.5)
        #expect(apsidesResult.descendingNode[1] == 23.5)
        #expect(apsidesResult.perihelion[1] == -5.0)
        #expect(apsidesResult.aphelion[1] == 5.0)
    }
    
    @Test("ApsidesResult: large longitude values (over 360)")
    func testApsidesResultLargeLongitudes() {
        let ascendingNode = [450.0, 0.0, 1.0]  // 450° = 90°
        let descendingNode = [720.0, 0.0, 1.0] // 720° = 0°
        let perihelion = [380.0, 0.0, 0.98]    // 380° = 20°
        let aphelion = [500.0, 0.0, 1.02]      // 500° = 140°
        
        let apsidesResult = ApsidesResult(
            ascendingNode: ascendingNode,
            descendingNode: descendingNode,
            perihelion: perihelion,
            aphelion: aphelion
        )
        
        #expect(apsidesResult.ascendingNode[0] == 450.0)
        #expect(apsidesResult.descendingNode[0] == 720.0)
        #expect(apsidesResult.perihelion[0] == 380.0)
        #expect(apsidesResult.aphelion[0] == 500.0)
    }
    
    @Test("ApsidesResult: precise decimal values")
    func testApsidesResultPreciseDecimals() {
        let ascendingNode = [120.123456789, 5.234567890, 1.012345678]
        let descendingNode = [300.987654321, -5.876543210, 0.987654321]
        let perihelion = [280.555555555, 0.111111111, 0.999999999]
        let aphelion = [100.333333333, -0.222222222, 1.000000001]
        
        let apsidesResult = ApsidesResult(
            ascendingNode: ascendingNode,
            descendingNode: descendingNode,
            perihelion: perihelion,
            aphelion: aphelion
        )
        
        #expect(apsidesResult.ascendingNode[0] == 120.123456789)
        #expect(apsidesResult.ascendingNode[1] == 5.234567890)
        #expect(apsidesResult.ascendingNode[2] == 1.012345678)
        
        #expect(apsidesResult.descendingNode[0] == 300.987654321)
        #expect(apsidesResult.perihelion[0] == 280.555555555)
        #expect(apsidesResult.aphelion[0] == 100.333333333)
    }
    
    @Test("ApsidesResult: array immutability")
    func testApsidesResultArrayImmutability() {
        var originalAscending = [120.0, 5.0, 1.0]
        var originalDescending = [300.0, -5.0, 1.0]
        var originalPerihelion = [280.0, 0.0, 0.98]
        var originalAphelion = [100.0, 0.0, 1.02]
        
        let apsidesResult = ApsidesResult(
            ascendingNode: originalAscending,
            descendingNode: originalDescending,
            perihelion: originalPerihelion,
            aphelion: originalAphelion
        )
        
        // Modify original arrays
        originalAscending[0] = 999.0
        originalDescending[0] = 999.0
        originalPerihelion[0] = 999.0
        originalAphelion[0] = 999.0
        
        // ApsidesResult arrays should remain unchanged
        #expect(apsidesResult.ascendingNode[0] == 120.0)
        #expect(apsidesResult.descendingNode[0] == 300.0)
        #expect(apsidesResult.perihelion[0] == 280.0)
        #expect(apsidesResult.aphelion[0] == 100.0)
        
        // Original arrays should be modified
        #expect(originalAscending[0] == 999.0)
        #expect(originalDescending[0] == 999.0)
    }
    
    @Test("ApsidesResult: typical astronomical values for Moon")
    func testApsidesResultTypicalMoonValues() {
        // Typical values for Moon's nodes and apsides
        // Ascending node around 120°, descending node around 300°
        // Perigee around 280°, apogee around 100°
        let ascendingNode = [120.5, 5.145396, 1.0]
        let descendingNode = [300.5, -5.145396, 1.0]
        let perihelion = [280.123, 0.0, 0.3633]  // Perigee distance in AU
        let aphelion = [100.456, 0.0, 0.4055]    // Apogee distance in AU
        
        let apsidesResult = ApsidesResult(
            ascendingNode: ascendingNode,
            descendingNode: descendingNode,
            perihelion: perihelion,
            aphelion: aphelion
        )
        
        #expect(apsidesResult.ascendingNode[0] == 120.5)
        #expect(apsidesResult.descendingNode[0] == 300.5)
        #expect(apsidesResult.perihelion[0] == 280.123)
        #expect(apsidesResult.aphelion[0] == 100.456)
        
        // Verify Moon's orbital inclination (about 5.145°)
        #expect(apsidesResult.ascendingNode[1] == 5.145396)
        #expect(apsidesResult.descendingNode[1] == -5.145396)
    }
    
    @Test("ApsidesResult: typical astronomical values for planet")
    func testApsidesResultTypicalPlanetValues() {
        // Typical values for a planet (e.g., Mars)
        // Nodes and apsides with typical orbital elements
        let ascendingNode = [49.578, 1.850, 1.0]
        let descendingNode = [229.578, -1.850, 1.0]
        let perihelion = [336.040, 0.0, 1.381]   // Perihelion distance in AU
        let aphelion = [156.040, 0.0, 1.666]    // Aphelion distance in AU
        
        let apsidesResult = ApsidesResult(
            ascendingNode: ascendingNode,
            descendingNode: descendingNode,
            perihelion: perihelion,
            aphelion: aphelion
        )
        
        #expect(apsidesResult.ascendingNode[0] == 49.578)
        #expect(apsidesResult.descendingNode[0] == 229.578)
        #expect(apsidesResult.perihelion[0] == 336.040)
        #expect(apsidesResult.aphelion[0] == 156.040)
        
        // Verify perihelion is closer than aphelion
        #expect(apsidesResult.perihelion[2] < apsidesResult.aphelion[2])
    }
    
    @Test("ApsidesResult: nodes are 180 degrees apart")
    func testApsidesResultNodes180DegreesApart() {
        let ascendingNode = [120.0, 5.0, 1.0]
        let descendingNode = [300.0, -5.0, 1.0]  // 120° + 180° = 300°
        let perihelion = [280.0, 0.0, 0.98]
        let aphelion = [100.0, 0.0, 1.02]
        
        let apsidesResult = ApsidesResult(
            ascendingNode: ascendingNode,
            descendingNode: descendingNode,
            perihelion: perihelion,
            aphelion: aphelion
        )
        
        // Verify nodes are 180° apart (accounting for 360° wrap)
        let nodeDifference = abs(apsidesResult.descendingNode[0] - apsidesResult.ascendingNode[0])
        let expectedDifference = 180.0
        let difference = abs(nodeDifference - expectedDifference)
        #expect(difference < 0.001 || abs(nodeDifference - 360.0 + expectedDifference) < 0.001)
    }
    
    @Test("ApsidesResult: distance values for perihelion and aphelion")
    func testApsidesResultDistanceValues() {
        // Perihelion should be closer (smaller distance) than aphelion
        let ascendingNode = [0.0, 0.0, 1.0]
        let descendingNode = [180.0, 0.0, 1.0]
        let perihelion = [0.0, 0.0, 0.98]  // Closer
        let aphelion = [180.0, 0.0, 1.02] // Farther
        
        let apsidesResult = ApsidesResult(
            ascendingNode: ascendingNode,
            descendingNode: descendingNode,
            perihelion: perihelion,
            aphelion: aphelion
        )
        
        #expect(apsidesResult.perihelion[2] < apsidesResult.aphelion[2])
        #expect(apsidesResult.perihelion[2] == 0.98)
        #expect(apsidesResult.aphelion[2] == 1.02)
    }
}

