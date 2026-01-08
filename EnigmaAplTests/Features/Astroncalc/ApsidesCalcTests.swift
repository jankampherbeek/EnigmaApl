//
//  ApsidesCalcTests.swift
//  EnigmaAplTests
//
//  Created on 07/01/2026.
//

import Testing
import Foundation
@testable import EnigmaApl

struct ApsidesCalcTests {
    
    @Test("ApsidesCalc: calculateApsidesFactors for blackSun and diamond")
    @MainActor
    func testCalculateApsidesFactors() {
        // Test parameters
        let julianDay = 2455197.5
        let factorsToUse: [Factors] = [.blackSun, .diamond]
        let houseSystem = 0
        let seFlags = 258
        let latitude = 52.2180555555556
        let longitude = 6.8955555555556
        
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
        
        // Expected values (converted from comma to period decimal separator)
        let expectedValues: [Factors: (longitude: Double, latitude: Double, rightAscension: Double, declination: Double, azimuth: Double, altitude: Double)] = [
            .blackSun: (
                longitude: 103.11387708892822,
                latitude: 4.5412937317164526e-08,
                rightAscension: 104.24712122674991,
                declination: 22.792524309310956,
                azimuth: 5.975464373976138,
                altitude: 60.47254644878145
            ),
            .diamond: (
                longitude: 283.11387414776146,
                latitude: 2.308377834957614e-08,
                rightAscension: 284.2471180445154,
                declination: -22.792524529061964,
                azimuth: 185.97547034328883,
                altitude: -60.47254646504524
            )
        ]
        
        // Perform calculation
        let seWrapper = SEWrapper()
        let apsidesCalc = ApsidesCalc(seWrapper: seWrapper)
        let result = apsidesCalc.calculateApsidesFactors(seRequest: request)
        
        // Verify all factors are present in the result
        let expectedCount = factorsToUse.count
        let actualCount = result.count
        #expect(actualCount == expectedCount, "All factors should be calculated, expected \(expectedCount), got \(actualCount)")
        
        // Verify each factor's values
        for (factor, expected) in expectedValues {
            guard let factorPosition = result[factor] else {
                Issue.record("Factor \(factor) not found in result")
                continue
            }
            
            // Verify ecliptical position (longitude and latitude)
            guard let eclipticalPosition = factorPosition.ecliptical.first else {
                Issue.record("Ecliptical position not found for factor \(factor)")
                continue
            }
            
            let actualLongitude = eclipticalPosition.mainPos
            let actualLatitude = eclipticalPosition.deviation
            
            let longDiff = abs(actualLongitude - expected.longitude)
            let latDiff = abs(actualLatitude - expected.latitude)
            
            #expect(longDiff < 1e-5,
                   "Factor \(factor) longitude: expected \(expected.longitude), got \(actualLongitude), difference: \(longDiff)")
            #expect(latDiff < 1e-6,
                   "Factor \(factor) latitude: expected \(expected.latitude), got \(actualLatitude), difference: \(latDiff)")
            
            // Verify equatorial position (right ascension and declination)
            guard let equatorialPosition = factorPosition.equatorial.first else {
                Issue.record("Equatorial position not found for factor \(factor)")
                continue
            }
            
            let actualRA = equatorialPosition.mainPos
            let actualDecl = equatorialPosition.deviation
            
            let raDiff = abs(actualRA - expected.rightAscension)
            let declDiff = abs(actualDecl - expected.declination)
            
            #expect(raDiff < 1e-5,
                   "Factor \(factor) right ascension: expected \(expected.rightAscension), got \(actualRA), difference: \(raDiff)")
            #expect(declDiff < 1e-5,
                   "Factor \(factor) declination: expected \(expected.declination), got \(actualDecl), difference: \(declDiff)")
            
            // Verify horizontal position (azimuth and altitude)
            guard let horizontalPosition = factorPosition.horizontal.first else {
                Issue.record("Horizontal position not found for factor \(factor)")
                continue
            }
            
            let actualAzimuth = horizontalPosition.azimuth
            let actualAltitude = horizontalPosition.altitude
            
            let aziDiff = abs(actualAzimuth - expected.azimuth)
            let altDiff = abs(actualAltitude - expected.altitude)
            
            #expect(aziDiff < 1e-5,
                   "Factor \(factor) azimuth: expected \(expected.azimuth), got \(actualAzimuth), difference: \(aziDiff)")
            #expect(altDiff < 1e-5,
                   "Factor \(factor) altitude: expected \(expected.altitude), got \(actualAltitude), difference: \(altDiff)")
        }
    }
}

