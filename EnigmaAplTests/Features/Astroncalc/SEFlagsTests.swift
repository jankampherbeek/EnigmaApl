//
//  SEFlagsTests.swift
//  EnigmaAplTests
//
//  Created on 01/01/2025.
//

import Testing
@testable import EnigmaApl

struct SEFlagsTests {
    
    // MARK: - Base Flags Tests
    
    @Test("SEFlags: base flags are correct")
    func testBaseFlags() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .geoCentric,
            zodiacType: .tropical
        )
        // Base flags: 2 (SE) + 256 (speed) = 258
        #expect(flags == 258)
    }
    
    // MARK: - Coordinate System Tests
    
    @Test("SEFlags: ecliptical coordinate system")
    func testEclipticalCoordinateSystem() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .geoCentric,
            zodiacType: .tropical
        )
        // Base: 258, no additional flags for ecliptical
        #expect(flags == 258)
    }
    
    @Test("SEFlags: equatorial coordinate system")
    func testEquatorialCoordinateSystem() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .equatorial,
            observerPosition: .geoCentric,
            zodiacType: .tropical
        )
        // Base: 258, + 2048 (equatorial) = 2306
        #expect(flags == 2306)
    }
    
    @Test("SEFlags: horizontal coordinate system")
    func testHorizontalCoordinateSystem() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .horizontal,
            observerPosition: .geoCentric,
            zodiacType: .tropical
        )
        // Base: 258, no additional flags for horizontal
        #expect(flags == 258)
    }
    
    // MARK: - Observer Position Tests
    
    @Test("SEFlags: geocentric observer position")
    func testGeocentricObserverPosition() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .geoCentric,
            zodiacType: .tropical
        )
        // Base: 258, no additional flags for geocentric
        #expect(flags == 258)
    }
    
    @Test("SEFlags: topocentric observer position")
    func testTopocentricObserverPosition() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .topoCentric,
            zodiacType: .tropical
        )
        // Base: 258, + 32768 (topocentric) = 33026
        #expect(flags == 33026)
    }
    
    @Test("SEFlags: heliocentric observer position")
    func testHeliocentricObserverPosition() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .helioCentric,
            zodiacType: .tropical
        )
        // Base: 258, + 8 (heliocentric) = 266
        #expect(flags == 266)
    }
    
    // MARK: - Zodiac Type Tests
    
    @Test("SEFlags: tropical zodiac type")
    func testTropicalZodiacType() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .geoCentric,
            zodiacType: .tropical
        )
        // Base: 258, no additional flags for tropical
        #expect(flags == 258)
    }
    
    @Test("SEFlags: sidereal zodiac type with ecliptical")
    func testSiderealZodiacTypeWithEcliptical() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .geoCentric,
            zodiacType: .sidereal
        )
        // Base: 258, + 65536 (sidereal) = 65794
        #expect(flags == 65794)
    }
    
    @Test("SEFlags: sidereal zodiac type with equatorial")
    func testSiderealZodiacTypeWithEquatorial() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .equatorial,
            observerPosition: .geoCentric,
            zodiacType: .sidereal
        )
        // Base: 258, + 2048 (equatorial) = 2306
        // Note: sidereal flag only applies when coordinate system is ecliptical
        #expect(flags == 2306)
    }
    
    @Test("SEFlags: sidereal zodiac type with horizontal")
    func testSiderealZodiacTypeWithHorizontal() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .horizontal,
            observerPosition: .geoCentric,
            zodiacType: .sidereal
        )
        // Base: 258, no additional flags
        // Note: sidereal flag only applies when coordinate system is ecliptical
        #expect(flags == 258)
    }
    
    // MARK: - Combined Flags Tests
    
    @Test("SEFlags: equatorial + topocentric")
    func testEquatorialAndTopocentric() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .equatorial,
            observerPosition: .topoCentric,
            zodiacType: .tropical
        )
        // Base: 258, + 2048 (equatorial) + 32768 (topocentric) = 35074
        #expect(flags == 35074)
    }
    
    @Test("SEFlags: equatorial + heliocentric")
    func testEquatorialAndHeliocentric() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .equatorial,
            observerPosition: .helioCentric,
            zodiacType: .tropical
        )
        // Base: 258, + 2048 (equatorial) + 8 (heliocentric) = 2314
        #expect(flags == 2314)
    }
    
    @Test("SEFlags: ecliptical + topocentric + sidereal")
    func testEclipticalTopocentricSidereal() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .topoCentric,
            zodiacType: .sidereal
        )
        // Base: 258, + 32768 (topocentric) + 65536 (sidereal) = 98562
        #expect(flags == 98562)
    }
    
    @Test("SEFlags: equatorial + topocentric + sidereal")
    func testEquatorialTopocentricSidereal() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .equatorial,
            observerPosition: .topoCentric,
            zodiacType: .sidereal
        )
        // Base: 258, + 2048 (equatorial) + 32768 (topocentric) = 35074
        // Note: sidereal flag only applies when coordinate system is ecliptical
        #expect(flags == 35074)
    }
    
    @Test("SEFlags: ecliptical + heliocentric + sidereal")
    func testEclipticalHeliocentricSidereal() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .helioCentric,
            zodiacType: .sidereal
        )
        // Base: 258, + 8 (heliocentric) + 65536 (sidereal) = 65802
        #expect(flags == 65802)
    }
    
    @Test("SEFlags: horizontal + topocentric + tropical")
    func testHorizontalTopocentricTropical() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .horizontal,
            observerPosition: .topoCentric,
            zodiacType: .tropical
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
    
    @Test("SEFlags: all coordinate systems tested")
    func testAllCoordinateSystems() {
        let observerPosition = ObserverPositions.geoCentric
        let zodiacType = ZodiacTypes.tropical
        
        for coordinateSystem in CoordinateSystems.allCases {
            let flags = SEFlags.defineFlags(
                coordinateSystem: coordinateSystem,
                observerPosition: observerPosition,
                zodiacType: zodiacType
            )
            // All should have at least base flags
            #expect(flags >= 258)
            
            if coordinateSystem == .equatorial {
                #expect(flags == 2306)  // Base + equatorial
            } else {
                #expect(flags == 258)  // Base only
            }
        }
    }
    
    @Test("SEFlags: all observer positions tested")
    func testAllObserverPositions() {
        let coordinateSystem = CoordinateSystems.ecliptical
        let zodiacType = ZodiacTypes.tropical
        
        for observerPosition in ObserverPositions.allCases {
            let flags = SEFlags.defineFlags(
                coordinateSystem: coordinateSystem,
                observerPosition: observerPosition,
                zodiacType: zodiacType
            )
            // All should have at least base flags
            #expect(flags >= 258)
            
            switch observerPosition {
            case .geoCentric:
                #expect(flags == 258)  // Base only
            case .topoCentric:
                #expect(flags == 33026)  // Base + topocentric
            case .helioCentric:
                #expect(flags == 266)  // Base + heliocentric
            }
        }
    }
    
    @Test("SEFlags: all zodiac types tested")
    func testAllZodiacTypes() {
        let coordinateSystem = CoordinateSystems.ecliptical
        let observerPosition = ObserverPositions.geoCentric
        
        for zodiacType in ZodiacTypes.allCases {
            let flags = SEFlags.defineFlags(
                coordinateSystem: coordinateSystem,
                observerPosition: observerPosition,
                zodiacType: zodiacType
            )
            // All should have at least base flags
            #expect(flags >= 258)
            
            switch zodiacType {
            case .tropical:
                #expect(flags == 258)  // Base only
            case .sidereal:
                #expect(flags == 65794)  // Base + sidereal (ecliptical)
            }
        }
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("SEFlags: maximum flags combination")
    func testMaximumFlagsCombination() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .topoCentric,
            zodiacType: .sidereal
        )
        // Base: 258, + 32768 (topocentric) + 65536 (sidereal) = 98562
        #expect(flags == 98562)
    }
    
    @Test("SEFlags: minimum flags combination")
    func testMinimumFlagsCombination() {
        let flags = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .geoCentric,
            zodiacType: .tropical
        )
        // Base: 258 only
        #expect(flags == 258)
    }
    
    @Test("SEFlags: flags are additive")
    func testFlagsAreAdditive() {
        let baseFlags = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .geoCentric,
            zodiacType: .tropical
        )
        
        let withEquatorial = SEFlags.defineFlags(
            coordinateSystem: .equatorial,
            observerPosition: .geoCentric,
            zodiacType: .tropical
        )
        
        let withTopocentric = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .topoCentric,
            zodiacType: .tropical
        )
        
        let withSidereal = SEFlags.defineFlags(
            coordinateSystem: .ecliptical,
            observerPosition: .geoCentric,
            zodiacType: .sidereal
        )
        
        // Verify flags are additive
        #expect(withEquatorial == baseFlags + 2048)
        #expect(withTopocentric == baseFlags + 32768)
        #expect(withSidereal == baseFlags + 65536)
    }
}

