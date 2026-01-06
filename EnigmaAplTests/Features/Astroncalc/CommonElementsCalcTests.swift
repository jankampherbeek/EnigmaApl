//
//  CommonElementsCalcTests.swift
//  EnigmaAplTests
//
//  Created on 03/01/2026.
//

import Testing
import Foundation
@testable import EnigmaApl

struct CommonElementsCalcTests {
    
    @Test("CommonElementsCalc: calculateCommonElementsFactors for January 1, 2020 0:00 UT")
    @MainActor
    func testCalculateCommonElementsFactors() {
        // Julian Day for January 1, 2010 0:00 UT
        let julianDay = 2455197.5
        // Test parameters
        let factorsToUse: [Factors] = [.persephoneRam, .hermesRam, .demeterRam]
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
            .persephoneRam: (
                longitude: 0.21855668263958744,
                latitude: 0.0,
                rightAscension: 0.20052279151835387,
                declination: 0.08693482883616671,
                azimuth: 103.83028080723625,
                altitude: -10.389847632471579
            ),
            .hermesRam: (
                longitude: 190.40065106386325,
                latitude: -0.0,
                rightAscension: 189.5589747249798,
                declination: -4.117914656816269,
                azimuth: 278.74888801075093,
                altitude: 1.5475484027881443
            ),
            .demeterRam: (
                longitude: 283.65004674832505,
                latitude: 1.9833260651055917,
                rightAscension: 284.6098392277247,
                declination: -20.76582493801715,
                azimuth: 185.06039757553333,
                altitude: -58.47127069734774
            )
        ]
        
        // Perform calculation
        let result = ElementsCalc.calculateElementsFactors(
            request: request
        )
        
        // Verify all factors are present in the result
        #expect(result.count == factorsToUse.count, "All factors should be calculated")
        
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
            // Handle -0.0 case by comparing absolute values
            let latDiff = abs(actualLatitude - expected.latitude)
            
            #expect(longDiff < 1e-6,
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
            
            #expect(raDiff < 1e-6,
                   "Factor \(factor) right ascension: expected \(expected.rightAscension), got \(actualRA), difference: \(raDiff)")
            #expect(declDiff < 1e-6,
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
            
            #expect(aziDiff < 1e-6,
                   "Factor \(factor) azimuth: expected \(expected.azimuth), got \(actualAzimuth), difference: \(aziDiff)")
            #expect(altDiff < 1e-6,
                   "Factor \(factor) altitude: expected \(expected.altitude), got \(actualAltitude), difference: \(altDiff)")
        }
    }
}

