// FormulaCalcTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct FormulaCalcTests {
    
    // MARK: - Test Functions (called by AstronCalcTestCoordinator)
    
    static func testCalculateFormulaFactors(seWrapper: SEWrapper) {
        // Test parameters
        let julianDay = 2455197.5
        let factorsToUse: [Factors] = [.apogeeDuval, .persephoneCarteret, .vulcanusCarteret]
        let houseSystem = 0
        let seFlags = 258
        let latitude = 52.2180555555556
        let longitude = 6.8955555555556
        
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
        
        // Use provided SEWrapper (from AstronCalcTestCoordinator)
        // Calculate obliquity (as requested by user, though not directly used in FormulaCalc)
        let obliquityPosition = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            factor: -1,
            flags: 258
        )
        let obliquity = obliquityPosition?.mainPos ?? 0.0
        
        // Verify obliquity is calculated (should be a reasonable value between 23 and 24 degrees)
        if !(obliquity > 23.0 && obliquity < 24.0) {
            Issue.record("Obliquity should be between 23 and 24 degrees, got \(obliquity)")
            return
        }
        
        // Expected values (converted from comma to period decimal separator)
        let expectedValues: [Factors: (longitude: Double, latitude: Double, rightAscension: Double, declination: Double, azimuth: Double, altitude: Double)] = [
            .apogeeDuval: (
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
        let formulaCalc = FormulaCalc()
        let result = formulaCalc.calculateFormulaFactors(seWrapper: seWrapper,  calcRequest: request, ayanamshaOffset: 0.0)
        
        // Verify all factors are present in the result
        if result.count != factorsToUse.count {
            Issue.record("All factors should be calculated, expected \(factorsToUse.count), got \(result.count)")
            return
        }
        
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
            
            if longDiff >= 1e-5 {
                Issue.record("Factor \(factor) longitude: expected \(expected.longitude), got \(actualLongitude), difference: \(longDiff)")
                continue
            }
            if latDiff >= 1e-6 {
                Issue.record("Factor \(factor) latitude: expected \(expected.latitude), got \(actualLatitude), difference: \(latDiff)")
                continue
            }
            
            // Verify equatorial position (right ascension and declination) - should be 0
            guard let equatorialPosition = factorPosition.equatorial.first else {
                Issue.record("Equatorial position not found for factor \(factor)")
                continue
            }
            
            let actualRA = equatorialPosition.mainPos
            let actualDecl = equatorialPosition.deviation
            
            let raDiff = abs(actualRA - expected.rightAscension)
            let declDiff = abs(actualDecl - expected.declination)
            
            if raDiff >= 1e-6 {
                Issue.record("Factor \(factor) right ascension: expected \(expected.rightAscension), got \(actualRA), difference: \(raDiff)")
                continue
            }
            if declDiff >= 1e-6 {
                Issue.record("Factor \(factor) declination: expected \(expected.declination), got \(actualDecl), difference: \(declDiff)")
                continue
            }
            
            // Verify horizontal position (azimuth and altitude) - should be 0
            guard let horizontalPosition = factorPosition.horizontal.first else {
                Issue.record("Horizontal position not found for factor \(factor)")
                continue
            }
            
            let actualAzimuth = horizontalPosition.azimuth
            let actualAltitude = horizontalPosition.altitude
            
            let aziDiff = abs(actualAzimuth - expected.azimuth)
            let altDiff = abs(actualAltitude - expected.altitude)
            
            if aziDiff >= 1e-6 {
                Issue.record("Factor \(factor) azimuth: expected \(expected.azimuth), got \(actualAzimuth), difference: \(aziDiff)")
                continue
            }
            if altDiff >= 1e-6 {
                Issue.record("Factor \(factor) altitude: expected \(expected.altitude), got \(actualAltitude), difference: \(altDiff)")
                continue
            }
        }
    }
}

