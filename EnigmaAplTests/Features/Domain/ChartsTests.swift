//
//  ChartsTests.swift
//  EnigmaAplTests
//
//  Created on 24/12/2025.
//

import Testing
@testable import EnigmaApl

struct ChartsTests {
    
    // MARK: - Helper Functions
    
    /// Helper function to create FullCuspPosition for testing
    func createCuspPosition(longitude: Double, rightAscension: Double = 0.0, declination: Double = 0.0, azimuth: Double = 0.0, altitude: Double = 0.0) -> FullCuspPosition {
        return FullCuspPosition(
            longitude: longitude,
            rightAscension: rightAscension,
            declination: declination,
            horizontal: HorizontalPosition(azimuth: azimuth, altitude: altitude)
        )
    }
    
    /// Helper function to create HousePositions for testing
    func createHousePositions(ascendant: Double = 0.0, midheaven: Double = 0.0, eastpoint: Double = 0.0, vertex: Double = 0.0) -> HousePositions {
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
        return HousePositions(
            cusps: cusps,
            ascendant: createCuspPosition(longitude: ascendant),
            midheaven: createCuspPosition(longitude: midheaven),
            eastpoint: createCuspPosition(longitude: eastpoint),
            vertex: createCuspPosition(longitude: vertex)
        )
    }
    
    /// Helper function to create FullFactorPosition for testing
    func createFactorPosition(eclipticalLongitude: Double = 0.0, equatorialRA: Double = 0.0, azimuth: Double = 0.0, altitude: Double = 0.0) -> FullFactorPosition {
        let ecliptical = MainAstronomicalPosition(
            mainPos: eclipticalLongitude,
            deviation: 0.0,
            distance: 1.0
        )
        let equatorial = MainAstronomicalPosition(
            mainPos: equatorialRA,
            deviation: 0.0,
            distance: 1.0
        )
        let horizontal = HorizontalPosition(azimuth: azimuth, altitude: altitude)
        
        return FullFactorPosition(
            ecliptical: [ecliptical],
            equatorial: [equatorial],
            horizontal: [horizontal]
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test("FullChart: initialization with all parameters")
    func testFullChartInitialization() {
        let coordinates: [Factors: FullFactorPosition] = [
            .sun: createFactorPosition(eclipticalLongitude: 45.5),
            .moon: createFactorPosition(eclipticalLongitude: 120.25)
        ]
        let housePositions = createHousePositions(ascendant: 15.5, midheaven: 90.0)
        let siderealTime = 12.345678
        let julianDay = 2461034.1666666665
        let obliquity = 23.4375
        
        let chart = FullChart(
            Coordinates: coordinates,
            HousePositions: housePositions,
            SiderealTime: siderealTime,
            JulianDay: julianDay,
            Obliquity: obliquity
        )
        
        #expect(chart.Coordinates.count == 2)
        #expect(chart.HousePositions.ascendant.longitude == 15.5)
        #expect(chart.SiderealTime == siderealTime)
        #expect(chart.JulianDay == julianDay)
        #expect(chart.Obliquity == obliquity)
    }
    
    @Test("FullChart: initialization with empty coordinates")
    func testFullChartEmptyCoordinates() {
        let coordinates: [Factors: FullFactorPosition] = [:]
        let housePositions = createHousePositions()
        let chart = FullChart(
            Coordinates: coordinates,
            HousePositions: housePositions,
            SiderealTime: 0.0,
            JulianDay: 0.0,
            Obliquity: 0.0
        )
        
        #expect(chart.Coordinates.isEmpty)
        #expect(chart.HousePositions.cusps.count == 13)
    }
    
    @Test("FullChart: initialization with single factor")
    func testFullChartSingleFactor() {
        let coordinates: [Factors: FullFactorPosition] = [
            .sun: createFactorPosition(eclipticalLongitude: 180.0)
        ]
        let housePositions = createHousePositions()
        let chart = FullChart(
            Coordinates: coordinates,
            HousePositions: housePositions,
            SiderealTime: 6.0,
            JulianDay: 2451545.0,
            Obliquity: 23.44
        )
        
        #expect(chart.Coordinates.count == 1)
        #expect(chart.Coordinates[.sun]?.ecliptical[0].mainPos == 180.0)
    }
    
    @Test("FullChart: initialization with multiple factors")
    func testFullChartMultipleFactors() {
        let coordinates: [Factors: FullFactorPosition] = [
            .sun: createFactorPosition(eclipticalLongitude: 0.0),
            .moon: createFactorPosition(eclipticalLongitude: 30.0),
            .mercury: createFactorPosition(eclipticalLongitude: 60.0),
            .venus: createFactorPosition(eclipticalLongitude: 90.0),
            .mars: createFactorPosition(eclipticalLongitude: 120.0),
            .jupiter: createFactorPosition(eclipticalLongitude: 150.0),
            .saturn: createFactorPosition(eclipticalLongitude: 180.0)
        ]
        let housePositions = createHousePositions()
        let chart = FullChart(
            Coordinates: coordinates,
            HousePositions: housePositions,
            SiderealTime: 12.0,
            JulianDay: 2451545.5,
            Obliquity: 23.5
        )
        
        #expect(chart.Coordinates.count == 7)
        #expect(chart.Coordinates[.sun]?.ecliptical[0].mainPos == 0.0)
        #expect(chart.Coordinates[.moon]?.ecliptical[0].mainPos == 30.0)
        #expect(chart.Coordinates[.saturn]?.ecliptical[0].mainPos == 180.0)
    }
    
    // MARK: - Property Access Tests
    
    @Test("FullChart: Coordinates property access")
    func testFullChartCoordinatesAccess() {
        let sunPosition = createFactorPosition(eclipticalLongitude: 45.123, equatorialRA: 3.0, azimuth: 180.0, altitude: 30.0)
        let coordinates: [Factors: FullFactorPosition] = [.sun: sunPosition]
        let chart = FullChart(
            Coordinates: coordinates,
            HousePositions: createHousePositions(),
            SiderealTime: 0.0,
            JulianDay: 0.0,
            Obliquity: 0.0
        )
        
        let retrievedPosition = chart.Coordinates[.sun]
        #expect(retrievedPosition != nil)
        #expect(retrievedPosition?.ecliptical[0].mainPos == 45.123)
        #expect(retrievedPosition?.equatorial[0].mainPos == 3.0)
        #expect(retrievedPosition?.horizontal[0].azimuth == 180.0)
        #expect(retrievedPosition?.horizontal[0].altitude == 30.0)
    }
    
    @Test("FullChart: HousePositions property access")
    func testFullChartHousePositionsAccess() {
        let housePositions = createHousePositions(
            ascendant: 15.5,
            midheaven: 90.0,
            eastpoint: 105.0,
            vertex: 195.0
        )
        let chart = FullChart(
            Coordinates: [:],
            HousePositions: housePositions,
            SiderealTime: 0.0,
            JulianDay: 0.0,
            Obliquity: 0.0
        )
        
        #expect(chart.HousePositions.ascendant.longitude == 15.5)
        #expect(chart.HousePositions.midheaven.longitude == 90.0)
        #expect(chart.HousePositions.eastpoint.longitude == 105.0)
        #expect(chart.HousePositions.vertex.longitude == 195.0)
        #expect(chart.HousePositions.cusps.count == 13)
    }
    
    @Test("FullChart: SiderealTime property access")
    func testFullChartSiderealTimeAccess() {
        let siderealTime = 12.3456789
        let chart = FullChart(
            Coordinates: [:],
            HousePositions: createHousePositions(),
            SiderealTime: siderealTime,
            JulianDay: 0.0,
            Obliquity: 0.0
        )
        
        #expect(chart.SiderealTime == siderealTime)
    }
    
    @Test("FullChart: JulianDay property access")
    func testFullChartJulianDayAccess() {
        let julianDay = 2461034.1666666665
        let chart = FullChart(
            Coordinates: [:],
            HousePositions: createHousePositions(),
            SiderealTime: 0.0,
            JulianDay: julianDay,
            Obliquity: 0.0
        )
        
        #expect(chart.JulianDay == julianDay)
    }
    
    @Test("FullChart: Obliquity property access")
    func testFullChartObliquityAccess() {
        let obliquity = 23.4375
        let chart = FullChart(
            Coordinates: [:],
            HousePositions: createHousePositions(),
            SiderealTime: 0.0,
            JulianDay: 0.0,
            Obliquity: obliquity
        )
        
        #expect(chart.Obliquity == obliquity)
    }
    
    // MARK: - Edge Cases
    
    @Test("FullChart: zero values for all numeric properties")
    func testFullChartZeroValues() {
        let chart = FullChart(
            Coordinates: [:],
            HousePositions: createHousePositions(),
            SiderealTime: 0.0,
            JulianDay: 0.0,
            Obliquity: 0.0
        )
        
        #expect(chart.SiderealTime == 0.0)
        #expect(chart.JulianDay == 0.0)
        #expect(chart.Obliquity == 0.0)
    }
    
    @Test("FullChart: negative sidereal time")
    func testFullChartNegativeSiderealTime() {
        let chart = FullChart(
            Coordinates: [:],
            HousePositions: createHousePositions(),
            SiderealTime: -12.0,
            JulianDay: 2451545.0,
            Obliquity: 23.44
        )
        
        #expect(chart.SiderealTime == -12.0)
    }
    
    @Test("FullChart: very large Julian Day")
    func testFullChartLargeJulianDay() {
        let julianDay = 2500000.0
        let chart = FullChart(
            Coordinates: [:],
            HousePositions: createHousePositions(),
            SiderealTime: 0.0,
            JulianDay: julianDay,
            Obliquity: 23.44
        )
        
        #expect(chart.JulianDay == julianDay)
    }
    
    @Test("FullChart: negative obliquity")
    func testFullChartNegativeObliquity() {
        let chart = FullChart(
            Coordinates: [:],
            HousePositions: createHousePositions(),
            SiderealTime: 0.0,
            JulianDay: 2451545.0,
            Obliquity: -23.44
        )
        
        #expect(chart.Obliquity == -23.44)
    }
    
    @Test("FullChart: precise decimal values")
    func testFullChartPreciseDecimals() {
        let siderealTime = 12.345678901234567
        let julianDay = 2461034.166666666666666
        let obliquity = 23.437500000000001
        
        let chart = FullChart(
            Coordinates: [:],
            HousePositions: createHousePositions(),
            SiderealTime: siderealTime,
            JulianDay: julianDay,
            Obliquity: obliquity
        )
        
        #expect(chart.SiderealTime == siderealTime)
        #expect(chart.JulianDay == julianDay)
        #expect(chart.Obliquity == obliquity)
    }
    
    // MARK: - Typical Astrological Values
    
    @Test("FullChart: typical astrological chart values")
    func testFullChartTypicalAstrologicalValues() {
        // Typical values for a natal chart
        let coordinates: [Factors: FullFactorPosition] = [
            .sun: createFactorPosition(eclipticalLongitude: 15.5),      // Aries 15°30'
            .moon: createFactorPosition(eclipticalLongitude: 105.25),  // Cancer 15°15'
            .mercury: createFactorPosition(eclipticalLongitude: 30.75), // Taurus 0°45'
            .venus: createFactorPosition(eclipticalLongitude: 60.5),   // Gemini 0°30'
            .mars: createFactorPosition(eclipticalLongitude: 180.0),    // Libra 0°
            .jupiter: createFactorPosition(eclipticalLongitude: 240.0),  // Sagittarius 0°
            .saturn: createFactorPosition(eclipticalLongitude: 270.0)    // Capricorn 0°
        ]
        let housePositions = createHousePositions(
            ascendant: 15.5,   // Aries 15°30'
            midheaven: 105.0,  // Cancer 15°
            eastpoint: 105.0,
            vertex: 195.0      // Libra 15°
        )
        let siderealTime = 12.345678
        let julianDay = 2461034.1666666665  // 2025-01-01 16:00:00 UT
        let obliquity = 23.4375  // Approximate obliquity for 2025
        
        let chart = FullChart(
            Coordinates: coordinates,
            HousePositions: housePositions,
            SiderealTime: siderealTime,
            JulianDay: julianDay,
            Obliquity: obliquity
        )
        
        #expect(chart.Coordinates.count == 7)
        #expect(chart.Coordinates[.sun]?.ecliptical[0].mainPos == 15.5)
        #expect(chart.Coordinates[.moon]?.ecliptical[0].mainPos == 105.25)
        #expect(chart.HousePositions.ascendant.longitude == 15.5)
        #expect(chart.HousePositions.midheaven.longitude == 105.0)
        #expect(chart.SiderealTime == siderealTime)
        #expect(chart.JulianDay == julianDay)
        #expect(chart.Obliquity == obliquity)
    }
    
    // MARK: - Immutability Tests
    
    @Test("FullChart: Coordinates dictionary immutability")
    func testFullChartCoordinatesImmutability() {
        var originalCoordinates: [Factors: FullFactorPosition] = [
            .sun: createFactorPosition(eclipticalLongitude: 0.0)
        ]
        let chart = FullChart(
            Coordinates: originalCoordinates,
            HousePositions: createHousePositions(),
            SiderealTime: 0.0,
            JulianDay: 0.0,
            Obliquity: 0.0
        )
        
        // Modify original dictionary
        originalCoordinates[.moon] = createFactorPosition(eclipticalLongitude: 30.0)
        
        // Chart coordinates should remain unchanged
        #expect(chart.Coordinates.count == 1)
        #expect(originalCoordinates.count == 2)
        #expect(chart.Coordinates[.moon] == nil)
    }
    
    @Test("FullChart: all properties are immutable")
    func testFullChartImmutability() {
        let chart = FullChart(
            Coordinates: [.sun: createFactorPosition(eclipticalLongitude: 45.0)],
            HousePositions: createHousePositions(ascendant: 15.0),
            SiderealTime: 12.0,
            JulianDay: 2451545.0,
            Obliquity: 23.44
        )
        
        // All properties should be accessible but not modifiable
        let initialSiderealTime = chart.SiderealTime
        let initialJulianDay = chart.JulianDay
        let initialObliquity = chart.Obliquity
        
        #expect(initialSiderealTime == 12.0)
        #expect(initialJulianDay == 2451545.0)
        #expect(initialObliquity == 23.44)
        #expect(chart.Coordinates.count == 1)
        #expect(chart.HousePositions.ascendant.longitude == 15.0)
    }
    
    // MARK: - Complex Scenarios
    
    @Test("FullChart: all major planets included")
    func testFullChartAllMajorPlanets() {
        let coordinates: [Factors: FullFactorPosition] = [
            .sun: createFactorPosition(eclipticalLongitude: 0.0),
            .moon: createFactorPosition(eclipticalLongitude: 30.0),
            .mercury: createFactorPosition(eclipticalLongitude: 60.0),
            .venus: createFactorPosition(eclipticalLongitude: 90.0),
            .mars: createFactorPosition(eclipticalLongitude: 120.0),
            .jupiter: createFactorPosition(eclipticalLongitude: 150.0),
            .saturn: createFactorPosition(eclipticalLongitude: 180.0),
            .uranus: createFactorPosition(eclipticalLongitude: 210.0),
            .neptune: createFactorPosition(eclipticalLongitude: 240.0),
            .pluto: createFactorPosition(eclipticalLongitude: 270.0)
        ]
        let chart = FullChart(
            Coordinates: coordinates,
            HousePositions: createHousePositions(),
            SiderealTime: 0.0,
            JulianDay: 0.0,
            Obliquity: 0.0
        )
        
        #expect(chart.Coordinates.count == 10)
        #expect(chart.Coordinates[.sun] != nil)
        #expect(chart.Coordinates[.moon] != nil)
        #expect(chart.Coordinates[.mercury] != nil)
        #expect(chart.Coordinates[.venus] != nil)
        #expect(chart.Coordinates[.mars] != nil)
        #expect(chart.Coordinates[.jupiter] != nil)
        #expect(chart.Coordinates[.saturn] != nil)
        #expect(chart.Coordinates[.uranus] != nil)
        #expect(chart.Coordinates[.neptune] != nil)
        #expect(chart.Coordinates[.pluto] != nil)
    }
    
    @Test("FullChart: factors with different coordinate systems")
    func testFullChartDifferentCoordinateSystems() {
        let sunPosition = createFactorPosition(
            eclipticalLongitude: 45.0,
            equatorialRA: 3.0,
            azimuth: 180.0,
            altitude: 30.0
        )
        let moonPosition = createFactorPosition(
            eclipticalLongitude: 120.0,
            equatorialRA: 8.0,
            azimuth: 270.0,
            altitude: 45.0
        )
        let coordinates: [Factors: FullFactorPosition] = [
            .sun: sunPosition,
            .moon: moonPosition
        ]
        let chart = FullChart(
            Coordinates: coordinates,
            HousePositions: createHousePositions(),
            SiderealTime: 0.0,
            JulianDay: 0.0,
            Obliquity: 0.0
        )
        
        let sun = chart.Coordinates[.sun]
        let moon = chart.Coordinates[.moon]
        
        #expect(sun?.ecliptical[0].mainPos == 45.0)
        #expect(sun?.equatorial[0].mainPos == 3.0)
        #expect(sun?.horizontal[0].azimuth == 180.0)
        #expect(sun?.horizontal[0].altitude == 30.0)
        
        #expect(moon?.ecliptical[0].mainPos == 120.0)
        #expect(moon?.equatorial[0].mainPos == 8.0)
        #expect(moon?.horizontal[0].azimuth == 270.0)
        #expect(moon?.horizontal[0].altitude == 45.0)
    }
}

