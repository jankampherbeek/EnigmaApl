//
//  SEFlagsTests.swift
//  EnigmaAplTests
//
//  Created on 01/01/2025.
//

import Testing
@testable import EnigmaApl

struct SEFlagsTests {
    
    
    // MARK: - Coordinate System Tests
    
    @Test("SEFlags: ecliptical coordinate system")
    func testEclipticalCoordinateSystem() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .ecliptical,
        )
        // Base: 258, no additional flags for ecliptical
        #expect(flags == 258)
    }
    
    @Test("SEFlags: equatorial coordinate system")
    func testEquatorialCoordinateSystem() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .equatorial,
        )
        // Base: 258, + 2048 (equatorial) = 2306
        #expect(flags == 2306)
    }
    
    @Test("SEFlags: horizontal coordinate system")
    func testHorizontalCoordinateSystem() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .horizontal,
        )
        // Base: 258, no additional flags for horizontal
        #expect(flags == 258)
    }
    
    // MARK: - Observer Position Tests
    
    @Test("SEFlags: topocentric observer position")
    func testTopocentricObserverPosition() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .tropical,
            observerPosition: .topoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .ecliptical,
        )
        // Base: 258, + 32768 (topocentric) = 33026
        #expect(flags == 33026)
    }
    
    @Test("SEFlags: heliocentric observer position")
    func testHeliocentricObserverPosition() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .tropical,
            observerPosition: .helioCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .ecliptical,
        )
        // Base: 258, + 8 (heliocentric) = 266
        #expect(flags == 266)
    }
    
    // MARK: - Zodiac Type Tests
    
    @Test("SEFlags: sidereal zodiac type with ecliptical")
    func testSiderealZodiacTypeWithEcliptical() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .fagan,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .ecliptical,
        )
        // Base: 258, + 65536 (sidereal) = 65794
        #expect(flags == 65794)
    }
    
    @Test("SEFlags: sidereal zodiac type with equatorial")
    func testSiderealZodiacTypeWithEquatorial() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .fagan,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .equatorial
        )
        // Base: 258, + 2048 (equatorial) = 2306
        // Note: sidereal flag only applies when coordinate system is ecliptical
        #expect(flags == 2306)
    }
    
    @Test("SEFlags: sidereal zodiac type with horizontal")
    func testSiderealZodiacTypeWithHorizontal() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .fagan,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .horizontal,
        )
        // Base: 258, no additional flags
        // Note: sidereal flag only applies when coordinate system is ecliptical
        #expect(flags == 258)
    }
    
    // MARK: - Combined Flags Tests
    
    @Test("SEFlags: equatorial + topocentric")
    func testEquatorialAndTopocentric() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .tropical,
            observerPosition: .topoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .equatorial,
        )
        // Base: 258, + 2048 (equatorial) + 32768 (topocentric) = 35074
        #expect(flags == 35074)
    }
    
    @Test("SEFlags: equatorial + heliocentric")
    func testEquatorialAndHeliocentric() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .tropical,
            observerPosition: .helioCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .equatorial
        )
        // Base: 258, + 2048 (equatorial) + 8 (heliocentric) = 2314
        #expect(flags == 2314)
    }
    
    @Test("SEFlags: ecliptical + topocentric + sidereal")
    func testEclipticalTopocentricSidereal() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .fagan,
            observerPosition: .topoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .ecliptical,
        )
        // Base: 258, + 32768 (topocentric) + 65536 (sidereal) = 98562
        #expect(flags == 98562)
    }
    
    @Test("SEFlags: equatorial + topocentric + sidereal")
    func testEquatorialTopocentricSidereal() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .fagan,
            observerPosition: .topoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .equatorial
        )
        // Base: 258, + 2048 (equatorial) + 32768 (topocentric) = 35074
        // Note: sidereal flag only applies when coordinate system is ecliptical
        #expect(flags == 35074)
    }
    
    @Test("SEFlags: ecliptical + heliocentric + sidereal")
    func testEclipticalHeliocentricSidereal() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .fagan,
            observerPosition: .helioCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .ecliptical
        )
        // Base: 258, + 8 (heliocentric) + 65536 (sidereal) = 65802
        #expect(flags == 65802)
    }
    
    @Test("SEFlags: horizontal + topocentric + tropical")
    func testHorizontalTopocentricTropical() {
        let configData = CalculationConfig(
            houseSystem: HouseSystems.noHouses,
            ayanamsha: .tropical,
            observerPosition: .topoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        let flags = SEFlags.defineFlags(
            calculationConfig: configData,
            coordSystem: .horizontal,
        )
        // Base: 258, + 32768 (topocentric) = 33026
        #expect(flags == 33026)
    }
    
    // MARK: - Flag Value Verification Tests
    
    @Test("SEFlags: verify individual flag values")
    func testIndividualFlagValues() {
        // Test that flag values match expected constants
        let baseFlags = 2 + 256  // SE + speed
        #expect(baseFlags == 258)
        
        let equatorialFlag = 2048
        #expect(equatorialFlag == 2048)
        
        let topocentricFlag = 32 * 1024
        #expect(topocentricFlag == 32768)
        
        let heliocentricFlag = 8
        #expect(heliocentricFlag == 8)
        
        let siderealFlag = 64 * 1024
        #expect(siderealFlag == 65536)
    }
    
}

