//
//  FormulaCalcTests.swift
//  EnigmaAplTests
//
//  Created on 04/01/2026.
//

import Testing
import Foundation
@testable import EnigmaApl

struct FormulaCalcTests {
    
    @Test("FormulaCalc: calculateFormulaFactors for apogeeCorrected, persephoneCarteret, vulcanusCarteret")
    @MainActor
    func testCalculateFormulaFactors() {
        // Test parameters
        let julianDay = 2455197.5
        let factorsToUse: [Factors] = [.apogeeCorrected, .persephoneCarteret, .vulcanusCarteret]
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
        
        // Calculate obliquity (as requested by user, though not directly used in FormulaCalc)
        let seWrapper = SEWrapper()
        let obliquityPosition = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            planet: -1,
            flags: 258
        )
        let obliquity = obliquityPosition?.mainPos ?? 0.0
        
        // Verify obliquity is calculated (should be a reasonable value between 23 and 24 degrees)
        #expect(obliquity > 23.0 && obliquity < 24.0, "Obliquity should be between 23 and 24 degrees, got \(obliquity)")
        
        // Expected values (converted from comma to period decimal separator)
        let expectedValues: [Factors: (longitude: Double, latitude: Double, rightAscension: Double, declination: Double, azimuth: Double, altitude: Double)] = [
            .apogeeCorrected: (
                longitude: 302.3546189049214,
                latitude: 0.0,
                rightAscension: 0.0,
                declination: 0.0,
                azimuth: 0.0,
                altitude: 0.0
            ),
            .persephoneCarteret: (
                longitude: 322.00098045039954,
                latitude: 0.0,
                rightAscension: 0.0,
                declination: 0.0,
                azimuth: 0.0,
                altitude: 0.0
            ),
            .vulcanusCarteret: (
                longitude: 76.20053924771973,
                latitude: 0.0,
                rightAscension: 0.0,
                declination: 0.0,
                azimuth: 0.0,
                altitude: 0.0
            )
        ]
        
        // Perform calculation
        let formulaCalc = FormulaCalc(seWrapper: seWrapper)
        let result = formulaCalc.calculateFormulaFactors(seRequest: request)
        
        // Verify all factors are present in the result
        #expect(result.count == factorsToUse.count, "All factors should be calculated, expected \(factorsToUse.count), got \(result.count)")
        
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
            
            // Verify equatorial position (right ascension and declination) - should be 0
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
            
            // Verify horizontal position (azimuth and altitude) - should be 0
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

