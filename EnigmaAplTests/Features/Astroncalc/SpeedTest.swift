//
//  SpeedTest.swift
//  EnigmaAplTests
//
//  Created on 10/01/2026.
//
//  NOTE: This test is managed by AstronCalcTestCoordinator to ensure
//  thread-safety. The test function below should not be run directly.
//  Use AstronCalcTestCoordinator instead.
//

import Testing
import Foundation
@testable import EnigmaApl

struct SpeedTest {
    
    // MARK: - Test Functions (called by AstronCalcTestCoordinator)
    
    static func testSpeed(seWrapper: SEWrapper) {
        // Test parameters
        let julianDay = 2461050.5
        let factorsToUse: [Factors] = [
            .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto,
            .northNode, .chiron, .persephoneRam, .hermesRam, .demeterRam, .apogeeMean,
            .persephoneCarteret, .vulcanusCarteret, .priapus, .dragon, .beast
        ]
        let houseSystem = 0
        let seFlags = 258
        let latitude = 52.2180555555556
        let longitude = 6.8955555555556
        
        // Create ConfigData
        let configData = ConfigData(
            houseSystem: .noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .noSect
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
        
        // Perform calculation using provided SEWrapper (for thread-safety)
        let result = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        
        // Expected speed values (converted from comma to period decimal separator)
        let expectedSpeeds: [Factors: (longSpeed: Double, latSpeed: Double, raSpeed: Double, declSpeed: Double, aziSpeed: Double, altSpeed: Double, radvSpeed: Double)] = [
            .sun: (
                longSpeed: 1.0189170614108543,
                latSpeed: -2.8465494193764805e-05,
                raSpeed: 1.0872464165518654,
                declSpeed: 0.14758230539000045,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 3.800458770879465e-05
            ),
            .moon: (
                longSpeed: 12.278268756201902,
                latSpeed: -0.9324771965737636,
                raSpeed: 11.01037952708725,
                declSpeed: -5.662852922681928,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 3.068392432509249e-05
            ),
            .mercury: (
                longSpeed: 1.5820458095614813,
                latSpeed: -0.08023591772439259,
                raSpeed: 1.735338678585604,
                declSpeed: 0.07097861668181296,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.0027094154146301494
            ),
            .venus: (
                longSpeed: 1.2578838073442495,
                latSpeed: -0.032847563861842906,
                raSpeed: 1.3529079808989393,
                declSpeed: 0.1576804141480254,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: -6.373121914541628e-05
            ),
            .mars: (
                longSpeed: 0.7721463325962986,
                latSpeed: -0.005503852365018517,
                raSpeed: 0.8303482478324938,
                declSpeed: 0.10647707279665018,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: -0.0009321725995704952
            ),
            .jupiter: (
                longSpeed: -0.134988697593868,
                latSpeed: 0.00227850807894283,
                raSpeed: -0.14380722811924992,
                declSpeed: 0.022234237115924038,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.00020341231741273125
            ),
            .saturn: (
                longSpeed: 0.07158654480177559,
                latSpeed: 0.0030064917339755657,
                raSpeed: 0.06454254288557172,
                declSpeed: 0.031213639643396112,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.015270809967994445
            ),
            .uranus: (
                longSpeed: -0.021106766756470958,
                latSpeed: 0.0002896564591075436,
                raSpeed: -0.021879809243480753,
                declSpeed: -0.004471795090697657,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.013409522768430795
            ),
            .neptune: (
                longSpeed: 0.017251219749852807,
                latSpeed: 0.000596859240176737,
                raSpeed: 0.015589715002287296,
                declSpeed: 0.007409385797753456,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.016326683043598814
            ),
            .pluto: (
                longSpeed: 0.031318522694949884,
                latSpeed: -0.0009146819683285273,
                raSpeed: 0.03326776885474911,
                declSpeed: 0.006473685603325738,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.004770700373919391
            ),
            .northNode: (
                longSpeed: -0.05296883878554981,
                latSpeed: 0.0,
                raSpeed: -0.04936931426027883,
                declSpeed: -0.020159610699288726,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.0
            ),
            .chiron: (
                longSpeed: 0.0068817388303921275,
                latSpeed: -0.0016653482021946823,
                raSpeed: 0.007099534088280174,
                declSpeed: 0.0010140239079215268,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.016744773780949122
            ),
            .persephoneRam: (
                longSpeed: 0.003912645663614711,
                latSpeed: 0.0,
                raSpeed: 0.0036064512851723407,
                declSpeed: 0.0015369825112223623,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.017232661308838715
            ),
            .hermesRam: (
                longSpeed: 0.0012106644113885068,
                latSpeed: 0.0,
                raSpeed: 0.0011285865505215043,
                declSpeed: -0.0004605496584240143,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: -0.01746587969634561
            ),
            .demeterRam: (
                longSpeed: 0.01171971787118764,
                latSpeed: -0.0001045779096979782,
                raSpeed: 0.012394910026159778,
                declSpeed: 0.0016041527241874576,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.00028227416967752106
            ),
            .apogeeMean: (
                longSpeed: 0.1120177663867687,
                latSpeed: -0.0024122917388121876,
                raSpeed: 0.12052620651690671,
                declSpeed: -0.025262148525997726,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.0
            ),
            .persephoneCarteret: (
                longSpeed: 0.0,
                latSpeed: 0.0,
                raSpeed: 0.0,
                declSpeed: 0.0,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.0
            ),
            .vulcanusCarteret: (
                longSpeed: 0.0,
                latSpeed: 0.0,
                raSpeed: 0.0,
                declSpeed: 0.0,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.0
            ),
            .priapus: (
                longSpeed: 0.1120177663867687,
                latSpeed: -0.0024122917388121876,
                raSpeed: 0.12052620651690671,
                declSpeed: -0.025262148525997726,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.0
            ),
            .dragon: (
                longSpeed: 0.0,
                latSpeed: 0.0,
                raSpeed: 0.0,
                declSpeed: 0.0,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.0
            ),
            .beast: (
                longSpeed: 0.0,
                latSpeed: 0.0,
                raSpeed: 0.0,
                declSpeed: 0.0,
                aziSpeed: 0.0,
                altSpeed: 0.0,
                radvSpeed: 0.0
            )
        ]
        
        // Verify all factors are present in the result
        if result.Coordinates.count != factorsToUse.count {
            Issue.record("All factors should be calculated, expected \(factorsToUse.count), got \(result.Coordinates.count)")
            return
        }
        
        // Verify each factor's speeds
        for (factor, expected) in expectedSpeeds {
            guard let factorPosition = result.Coordinates[factor] else {
                Issue.record("Factor \(factor) not found in result")
                continue
            }
            
            // Verify ecliptical speeds (longitude and latitude)
            guard let eclipticalPosition = factorPosition.ecliptical.first else {
                Issue.record("Ecliptical position not found for factor \(factor)")
                continue
            }
            
            let actualLongSpeed = eclipticalPosition.mainPosSpeed
            let actualLatSpeed = eclipticalPosition.deviationSpeed
            let actualRadvSpeed = eclipticalPosition.distanceSpeed
            
            let longSpeedDiff = abs(actualLongSpeed - expected.longSpeed)
            let latSpeedDiff = abs(actualLatSpeed - expected.latSpeed)
            let radvSpeedDiff = abs(actualRadvSpeed - expected.radvSpeed)
            
            if longSpeedDiff >= 1e-6 {
                Issue.record("Factor \(factor) longitude speed: expected \(expected.longSpeed), got \(actualLongSpeed), difference: \(longSpeedDiff)")
                continue
            }
            if latSpeedDiff >= 1e-6 {
                Issue.record("Factor \(factor) latitude speed: expected \(expected.latSpeed), got \(actualLatSpeed), difference: \(latSpeedDiff)")
                continue
            }
            if radvSpeedDiff >= 1e-6 {
                Issue.record("Factor \(factor) radius vector speed: expected \(expected.radvSpeed), got \(actualRadvSpeed), difference: \(radvSpeedDiff)")
                continue
            }
            
            // Verify equatorial speeds (right ascension and declination)
            guard let equatorialPosition = factorPosition.equatorial.first else {
                Issue.record("Equatorial position not found for factor \(factor)")
                continue
            }
            
            let actualRASpeed = equatorialPosition.mainPosSpeed
            let actualDeclSpeed = equatorialPosition.deviationSpeed
            
            let raSpeedDiff = abs(actualRASpeed - expected.raSpeed)
            let declSpeedDiff = abs(actualDeclSpeed - expected.declSpeed)
            
            if raSpeedDiff >= 1e-6 {
                Issue.record("Factor \(factor) right ascension speed: expected \(expected.raSpeed), got \(actualRASpeed), difference: \(raSpeedDiff)")
                continue
            }
            if declSpeedDiff >= 1e-6 {
                Issue.record("Factor \(factor) declination speed: expected \(expected.declSpeed), got \(actualDeclSpeed), difference: \(declSpeedDiff)")
                continue
            }
            
            // Verify horizontal speeds (azimuth and altitude)
            // Note: Horizontal positions typically don't have speeds, so these should be 0
            guard let horizontalPosition = factorPosition.horizontal.first else {
                Issue.record("Horizontal position not found for factor \(factor)")
                continue
            }
            
            // HorizontalPosition doesn't have speed properties, so we can't verify them
            // The expected values are all 0.0, which is correct since horizontal coordinates
            // are calculated from equatorial coordinates and don't have inherent speeds
        }
    }
}
