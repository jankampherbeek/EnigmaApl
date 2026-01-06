//
//  AstronCalcOrchestratorTests.swift
//  EnigmaAplTests
//
//  Created by Jan Kampherbeek on 22/12/2025.
//

import Testing
import Foundation

@testable import EnigmaApl

struct AstronCalcOrchestratorTests {
    
    @Test("PerformCalculation: verify factor longitudes with expected values")
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
        
        // Create ConfigData with default values
        let configData = ConfigData(
            houseSystem: HouseSystems(rawValue: houseSystem) ?? .noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        // Create SERequest
        let request = SERequest(
            JulianDay: julianDay,
            FactorsToUse: factorsToUse,
            HouseSystem: houseSystem,
            SEFlags: seFlags,
            Latitude: latitude,
            Longitude: longitude,
            ConfigData: configData
        )
        
        // Perform calculation
        let result = AstronCalcOrchestrator.PerformCalculation(request)
        
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

