// AstronCalcOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation


@testable import EnigmaApl

@MainActor
struct AstronCalcOrchestratorTests {
    
    // MARK: - Shared test parameters

    private let julianDay    = 2455197.5
    private let geoLat       = 52.21805555555556
    private let geoLon       = 6.895555555555555
    private let houseSystemId = 82      // Regiomontanus

    private func makeConfig() -> CalculationConfig {
        CalculationConfig(
            houseSystem: HouseSystems(rawValue: houseSystemId) ?? .noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
    }

    private func makeRequest(_ factors: [Factors]) -> CalcRequest {
        CalcRequest(
            JulianDay: julianDay,
            FactorsToUse: factors,
            HouseSystem: houseSystemId,
            Latitude: geoLat,
            Longitude: geoLon,
            Height: 0.0,
            calculationConfig: makeConfig()
        )
    }

    // MARK: - PerformSingleCoordinateCalculation Tests

    @Test("PerformSingleCoordinateCalculation: CommonSe longitude matches known values for main planets")
    func testSingleCoord_commonSe_longitude() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let expectedLongitudes: [Factors: Double] = [
            .sun:     280.4511630990,
            .moon:    103.2443853269,
            .mercury: 288.9958888996,
            .venus:   277.8499668252,
            .mars:    138.8175005128,
            .jupiter: 326.3588628480,
            .saturn:  184.5065798899,
            .uranus:  353.0900907615,
            .neptune: 324.5820935220,
            .pluto:   273.3088210717
        ]
        for (factor, expected) in expectedLongitudes {
            let request = makeRequest([factor])
            let (jd, longitude) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
                request, coordinate: .longitude, seWrapper: seWrapper)
            #expect(jd == julianDay,
                    "Julian day must be preserved for \(factor)")
            #expect(abs(longitude - expected) < 1e-6,
                    "Longitude for \(factor): expected \(expected), got \(longitude)")
        }
    }

    @Test("PerformSingleCoordinateCalculation: CommonSe latitude consistent with PerformCalculation")
    func testSingleCoord_commonSe_latitude() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.sun])
        let (_, latitude) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .latitude, seWrapper: seWrapper)
        let full = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let expected = full.Coordinates[.sun]?.ecliptical.first?.deviation ?? 0.0
        #expect(abs(latitude - expected) < 1e-6,
                "Latitude for sun: expected \(expected), got \(latitude)")
    }

    @Test("PerformSingleCoordinateCalculation: CommonSe right ascension consistent with PerformCalculation")
    func testSingleCoord_commonSe_rightAscension() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.sun])
        let (_, ra) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .rightAscension, seWrapper: seWrapper)
        let full = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let expected = full.Coordinates[.sun]?.equatorial.first?.mainPos ?? 0.0
        #expect(abs(ra - expected) < 1e-6,
                "Right ascension for sun: expected \(expected), got \(ra)")
    }

    @Test("PerformSingleCoordinateCalculation: CommonSe declination consistent with PerformCalculation")
    func testSingleCoord_commonSe_declination() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.sun])
        let (_, decl) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .declination, seWrapper: seWrapper)
        let full = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let expected = full.Coordinates[.sun]?.equatorial.first?.deviation ?? 0.0
        #expect(abs(decl - expected) < 1e-6,
                "Declination for sun: expected \(expected), got \(decl)")
    }

    @Test("PerformSingleCoordinateCalculation: CommonSe distance consistent with PerformCalculation")
    func testSingleCoord_commonSe_distance() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.sun])
        let (_, distance) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .distance, seWrapper: seWrapper)
        let full = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let expected = full.Coordinates[.sun]?.ecliptical.first?.distance ?? 0.0
        #expect(abs(distance - expected) < 1e-9,
                "Distance for sun: expected \(expected), got \(distance)")
    }

    @Test("PerformSingleCoordinateCalculation: CommonElements longitude consistent with PerformCalculation")
    func testSingleCoord_commonElements_longitude() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.persephoneRam])
        let (_, longitude) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .longitude, seWrapper: seWrapper)
        let full = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let expected = full.Coordinates[.persephoneRam]?.ecliptical.first?.mainPos ?? 0.0
        #expect(abs(longitude - expected) < 1e-6,
                "Longitude for persephoneRam: expected \(expected), got \(longitude)")
    }

    @Test("PerformSingleCoordinateCalculation: CommonElements declination consistent with PerformCalculation")
    func testSingleCoord_commonElements_declination() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.persephoneRam])
        let (_, decl) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .declination, seWrapper: seWrapper)
        let full = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let expected = full.Coordinates[.persephoneRam]?.equatorial.first?.deviation ?? 0.0
        #expect(abs(decl - expected) < 1e-6,
                "Declination for persephoneRam: expected \(expected), got \(decl)")
    }

    @Test("PerformSingleCoordinateCalculation: CommonFormulaLongitude longitude consistent with PerformCalculation")
    func testSingleCoord_commonFormulaLongitude_longitude() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.persephoneCarteret])
        let (_, longitude) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .longitude, seWrapper: seWrapper)
        let full = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let expected = full.Coordinates[.persephoneCarteret]?.ecliptical.first?.mainPos ?? 0.0
        #expect(abs(longitude - expected) < 1e-6,
                "Longitude for persephoneCarteret: expected \(expected), got \(longitude)")
    }

    @Test("PerformSingleCoordinateCalculation: CommonFormulaFull longitude consistent with PerformCalculation")
    func testSingleCoord_commonFormulaFull_longitude() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.southNode])
        let (_, longitude) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .longitude, seWrapper: seWrapper)
        let full = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let expected = full.Coordinates[.southNode]?.ecliptical.first?.mainPos ?? 0.0
        #expect(abs(longitude - expected) < 1e-6,
                "Longitude for southNode: expected \(expected), got \(longitude)")
    }

    @Test("PerformSingleCoordinateCalculation: CommonFormulaFull right ascension consistent with PerformCalculation")
    func testSingleCoord_commonFormulaFull_rightAscension() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.southNode])
        let (_, ra) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .rightAscension, seWrapper: seWrapper)
        let full = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let expected = full.Coordinates[.southNode]?.equatorial.first?.mainPos ?? 0.0
        #expect(abs(ra - expected) < 1e-6,
                "Right ascension for southNode: expected \(expected), got \(ra)")
    }

    @Test("PerformSingleCoordinateCalculation: ZodiacFixed longitude is 0.0 for tropical zodiac")
    func testSingleCoord_zodiacFixed_longitude() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.zeroAries])
        let (_, longitude) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .longitude, seWrapper: seWrapper)
        #expect(longitude == 0.0,
                "Zero Aries longitude should be 0.0 for tropical zodiac, got \(longitude)")
    }

    @Test("PerformSingleCoordinateCalculation: Apsides longitude consistent with PerformCalculation")
    func testSingleCoord_apsides_longitude() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.blackSun])
        let (_, longitude) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .longitude, seWrapper: seWrapper)
        let full = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let expected = full.Coordinates[.blackSun]?.ecliptical.first?.mainPos ?? 0.0
        #expect(abs(longitude - expected) < 1e-6,
                "Longitude for blackSun: expected \(expected), got \(longitude)")
    }

    @Test("PerformSingleCoordinateCalculation: Lots factor returns (julianDay, 0.0)")
    func testSingleCoord_lots_returnsZero() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.parsfortuna])
        let (jd, position) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .longitude, seWrapper: seWrapper)
        #expect(jd == julianDay, "Julian day must be preserved")
        #expect(position == 0.0, "Lots factor should return 0.0, got \(position)")
    }

    @Test("PerformSingleCoordinateCalculation: Mundane factor returns (julianDay, 0.0)")
    func testSingleCoord_mundane_returnsZero() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([.ascendant])
        let (jd, position) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .longitude, seWrapper: seWrapper)
        #expect(jd == julianDay, "Julian day must be preserved")
        #expect(position == 0.0, "Mundane factor should return 0.0, got \(position)")
    }

    @Test("PerformSingleCoordinateCalculation: empty FactorsToUse returns (julianDay, 0.0)")
    func testSingleCoord_emptyFactors_returnsZero() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest([])
        let (jd, position) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            request, coordinate: .longitude, seWrapper: seWrapper)
        #expect(jd == julianDay, "Julian day must be preserved")
        #expect(position == 0.0, "Empty factors should return 0.0, got \(position)")
    }

    // MARK: - Individual Tests (commented out - use AstronCalcTestCoordinator instead)

    // @Test("PerformCalculation: verify factor longitudes with expected values")
    func testPerformCalculationFactorLongitudes() async throws {
        // Test data
        // Julian Day for 2025-12-24 at 16:00:00 UT
        //let julianDay = 2461034.16666666666666666667
        let julianDay = 2455197.5
        let latitude = 52.21805555555556
        let longitude = 6.895555555555555
        let houseSystem = 82  // ASCII for 'R' (Regiomontanus)
        let seFlags = 258
        
        // Expected longitudes (converted from comma to period decimal separator)
        let expectedLongitudes: [Factors: Double] = [
            .sun: 280.4511630990,
            .moon: 103.2443853269,
            .mercury: 288.9958888996,
            .venus: 277.8499668252,
            .mars: 138.8175005128,
            .jupiter: 326.3588628480,
            .saturn: 184.5065798899,
            .uranus: 353.0900907615,
            .neptune: 324.5820935220,
            .pluto: 273.3088210717
            // .sun: 273.09670268672403,
//            .moon: 325.1351416351275,
//            .mercury: 257.63446704280034,
//            .venus: 269.9773403950016,
//            .mars: 277.08655182416345,
//            .jupiter: 112.28458370995234,
//            .saturn: 355.7824245601181,
//            .uranus: 58.16797398938692,
//            .neptune: 359.4311236308796,
//            .pluto: 302.5029947885921,
//            .northNode: 342.55901588929106,
//            .chiron: 22.637018721021366
//            .cupidoUra: 279.16931746657514,
//            .hadesUra: 105.03630685625903,
//            .zeusUra: 206.19395363816994,
//            .kronosUra: 106.43010001811221,
//            .apollonUra: 217.41519295981897,
//            .admetosUra: 64.51922545789965,
//            .vulcanusUra: 124.83545541939436,
//            .poseidonUra: 227.0160303587219,
//            .eris: 24.653386054682002,
//            .pholus: 280.51185575910023,
//            .ceres: 5.629277810581217,
//            .pallas: 320.47480156123845,
//            .juno: 268.2194187132994,
//            .vesta: 290.42864510836546,
//            .isis: 154.91155816446593,
//            .nessus: 348.6926565951955,
//            .huya: 266.52375378056365,
//            .varuna: 130.84101001384326,
//            .ixion: 276.9970272825028,
//            .quaoar: 280.80057681343663,
//            .haumea: 213.96602373625444,
//            .orcus: 168.35264510436684,
//            .makemake: 192.66583682764255,
//            .sedna: 60.984909604571584,
//            .hygieia: 90.344318460008,
//            .astraea: 289.05672172256465
        ]
        
        // Create factors list from expected longitudes keys
        let factorsToUse = Array(expectedLongitudes.keys)
        
        // Create CalculationConfig with default values
        let configData = CalculationConfig(
            houseSystem: HouseSystems(rawValue: houseSystem) ?? .noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        // Create CalcRequest
        let request = CalcRequest(
            JulianDay: julianDay,
            FactorsToUse: factorsToUse,
            HouseSystem: houseSystem,
            Latitude: latitude,
            Longitude: longitude,
            Height: 0.0,
            calculationConfig: configData
        )
        
        // Perform calculation using shared SEWrapper instance for thread-safety
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let result = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        
        // Verify all factors are present in the result
        #expect(result.Coordinates.count == expectedLongitudes.count, "All factors should be calculated")
        
        // Verify each factor's longitude
        for (factor, expectedLongitude) in expectedLongitudes {
            guard let factorPosition = result.Coordinates[factor] else {
                Issue.record("Factor \(factor) not found in result")
                continue
            }
            
            guard let eclipticalPosition = factorPosition.ecliptical.first else {
                Issue.record("Ecliptical position not found for factor \(factor)")
                continue
            }
            
            let actualLongitude = eclipticalPosition.mainPos
            let difference = abs(actualLongitude - expectedLongitude)
            
            #expect(difference < 1e-6,
                   "Factor \(factor): expected longitude \(expectedLongitude), got \(actualLongitude), difference: \(difference)")
        }
    }
}

