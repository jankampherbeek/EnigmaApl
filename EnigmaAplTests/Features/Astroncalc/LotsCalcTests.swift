//
//  LotsCalcTests.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 10/01/2026.
//
//  NOTE: These tests are now managed by AstronCalcTestCoordinator to ensure
//  thread-safety. The test functions below are kept for reference but should
//  not be run directly. Use AstronCalcTestCoordinator instead.
//

import Testing
import Foundation
@testable import EnigmaApl

struct LotsCalcTests {
    
    // MARK: - Test Functions (called by AstronCalcTestCoordinator)
    
    static func testCalculateLotsFactorsSect(seWrapper: SEWrapper) {
        // Test parameters
        let julianDay = 2461050.5
        let factorsToUse: [Factors] = [.parsfortuna]
        let houseSystem = 0
        let seFlags = 258
        let latitude = 52.2180555555556
        let longitude = 6.8955555555556
        
        // ConfigData values
        let configData = ConfigData(
            houseSystem: .noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        
        // Create CalcRequest
        let calcRequest = CalcRequest(
            JulianDay: julianDay,
            FactorsToUse: factorsToUse,
            HouseSystem: houseSystem,
            Latitude: latitude,
            Longitude: longitude,
            Height: 0.0,
            ConfigData: configData
        )
        
        // Additional parameters
        let obliquity = 23.43820723656883
        let ascendantLongitude = 198.44179488842633
        let sunLongitude = 289.73837750962514
        let moonLongitude = 192.37808120651354
        let isDayChart = false
        // Expected values (converted from comma to period decimal separator)
        let expectedLongitude = 101.08149858531476
        let expectedLatitude = 0.0
        let expectedRightAscension = 102.05008714763132
        let expectedDeclination = 22.975873465253876
        let expectedAzimuth = 26.147717238396183
        let expectedAltitude = 58.748020154744104
        let expectedLongitudeSpeed = 0.0
        
        
        // NOTE: This test should be run via AstronCalcTestCoordinator
        // Create SEWrapper instance (only for direct test execution, not recommended)
        let seWrapper = SEWrapper()
        
        // Create LotsCalc instance
        let lotsCalc = LotsCalc()
        
        // Perform calculation and store result to ensure it's fully evaluated
        let result = lotsCalc.calculateLotsFactors(
            seWrapper: seWrapper,
            calcRequest: calcRequest,
            obliquity: obliquity,
            ascendantLongitude: ascendantLongitude,
            sunLongitude: sunLongitude,
            moonLongitude: moonLongitude,
            isDayChart: isDayChart,
            ayanamshaOffset: 0.0
        )
        
        // Keep reference alive to prevent premature deallocation
        _ = lotsCalc
        
        // Verify result contains parsfortuna
        guard let factorPosition = result[Factors.parsfortuna] else {
            Issue.record("Pars Fortuna not found in result")
            return
        }
        
        // Verify ecliptical position (longitude and latitude)
        guard let eclipticalPosition = factorPosition.ecliptical.first else {
            Issue.record("Ecliptical position not found")
            return
        }
        
        let actualLongitude = eclipticalPosition.mainPos
        let actualLatitude = eclipticalPosition.deviation
        let actualLongitudeSpeed = eclipticalPosition.mainPosSpeed
        
        let longDiff = abs(actualLongitude - expectedLongitude)
        let latDiff = abs(actualLatitude - expectedLatitude)
        let lsDiff = abs(actualLongitudeSpeed - expectedLongitudeSpeed)
        
       
        
        if longDiff >= 1e-6 {
            Issue.record("Longitude: expected \(expectedLongitude), got \(actualLongitude), difference: \(longDiff)")
            return
        }
        if latDiff >= 1e-6 {
            Issue.record("Latitude: expected \(expectedLatitude), got \(actualLatitude), difference: \(latDiff)")
            return
        }
        if lsDiff >= 1e-6 {
            Issue.record("Longitude speed: expected \(expectedLongitudeSpeed), got \(actualLongitudeSpeed), difference: \(lsDiff)")
            return
        }
        
        // Verify equatorial position (right ascension and declination)
        guard let equatorialPosition = factorPosition.equatorial.first else {
            Issue.record("Equatorial position not found")
            return
        }
        
        let actualRA = equatorialPosition.mainPos
        let actualDecl = equatorialPosition.deviation
        
        let raDiff = abs(actualRA - expectedRightAscension)
        let declDiff = abs(actualDecl - expectedDeclination)
        
        if raDiff >= 1e-6 {
            Issue.record("Right ascension: expected \(expectedRightAscension), got \(actualRA), difference: \(raDiff)")
            return
        }
        if declDiff >= 1e-6 {
            Issue.record("Declination: expected \(expectedDeclination), got \(actualDecl), difference: \(declDiff)")
            return
        }
        
        // Verify horizontal position (azimuth and altitude)
        guard let horizontalPosition = factorPosition.horizontal.first else {
            Issue.record("Horizontal position not found")
            return
        }
        
        let actualAzimuth = horizontalPosition.azimuth
        let actualAltitude = horizontalPosition.altitude
        
        let aziDiff = abs(actualAzimuth - expectedAzimuth)
        let altDiff = abs(actualAltitude - expectedAltitude)
        
        if aziDiff >= 1e-6 {
            Issue.record("Azimuth: expected \(expectedAzimuth), got \(actualAzimuth), difference: \(aziDiff)")
            return
        }
        if altDiff >= 1e-6 {
            Issue.record("Altitude: expected \(expectedAltitude), got \(actualAltitude), difference: \(altDiff)")
            return
        }
    }
    
    static func testCalculateLotsFactorsNoSect(seWrapper: SEWrapper) {
        // Test parameters
        let julianDay = 2461050.5
        let factorsToUse: [Factors] = [.parsfortuna]
        let houseSystem = 0
        let seFlags = 258
        let latitude = 52.2180555555556
        let longitude = 6.8955555555556
        let isDayChart = false
        
        // ConfigData values - same as test 1 except lotsType
        let configData = ConfigData(
            houseSystem: .noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: .duval,
            lunarNodeType: .meanNode,
            lotsType: .noSect
        )
        
        // Create CalcRequest
        let calcRequest = CalcRequest(
            JulianDay: julianDay,
            FactorsToUse: factorsToUse,
            HouseSystem: houseSystem,
            Latitude: latitude,
            Longitude: longitude,
            Height: 0.0,
            ConfigData: configData
        )
        
        // Additional parameters
        let obliquity = 23.43820723656883
        let ascendantLongitude = 198.44179488842633
        let sunLongitude = 289.73837750962514
        let moonLongitude = 192.37808120651354
        
        
        // Expected values (converted from comma to period decimal separator)
        let expectedLongitude = 295.8020911915379
        let expectedLatitude = 0.0
        let expectedRightAscension = 297.7866354563441
        let expectedDeclination = -20.98381987512831
        let expectedAzimuth = 177.55578671647282
        let expectedAltitude = -58.74802015474409
        let expectedLongitudeSpeed = 0.0
        
        // NOTE: This test should be run via AstronCalcTestCoordinator
        // Create SEWrapper instance (only for direct test execution, not recommended)
        let seWrapper = SEWrapper()
        
        // Create LotsCalc instance
        let lotsCalc = LotsCalc()
        
        // Perform calculation and store result to ensure it's fully evaluated
        let result = lotsCalc.calculateLotsFactors(

            seWrapper: seWrapper,
            calcRequest: calcRequest,
            obliquity: obliquity,
            ascendantLongitude: ascendantLongitude,
            sunLongitude: sunLongitude,
            moonLongitude: moonLongitude,
            isDayChart: isDayChart,
            ayanamshaOffset: 0.0
        )
        
        // Keep reference alive to prevent premature deallocation
        _ = lotsCalc
        
        // Verify result contains parsfortuna
        guard let factorPosition = result[.parsfortuna] else {
            Issue.record("Pars Fortuna not found in result")
            return
        }
        
        // Verify ecliptical position (longitude and latitude)
        guard let eclipticalPosition = factorPosition.ecliptical.first else {
            Issue.record("Ecliptical position not found")
            return
        }
        
        let actualLongitude = eclipticalPosition.mainPos
        let actualLatitude = eclipticalPosition.deviation
        let actualLongitudeSpeed = eclipticalPosition.mainPosSpeed
        
        let longDiff = abs(actualLongitude - expectedLongitude)
        let latDiff = abs(actualLatitude - expectedLatitude)
        let lsDiff = abs(actualLongitudeSpeed - expectedLongitudeSpeed)
        
        if longDiff >= 1e-6 {
            Issue.record("Longitude: expected \(expectedLongitude), got \(actualLongitude), difference: \(longDiff)")
            return
        }
        if latDiff >= 1e-6 {
            Issue.record("Latitude: expected \(expectedLatitude), got \(actualLatitude), difference: \(latDiff)")
            return
        }
        if lsDiff >= 1e-6 {
            Issue.record("Longitude speed: expected \(expectedLongitudeSpeed), got \(actualLongitudeSpeed), difference: \(lsDiff)")
            return
        }
        
        // Verify equatorial position (right ascension and declination)
        guard let equatorialPosition = factorPosition.equatorial.first else {
            Issue.record("Equatorial position not found")
            return
        }
        
        let actualRA = equatorialPosition.mainPos
        let actualDecl = equatorialPosition.deviation
        
        let raDiff = abs(actualRA - expectedRightAscension)
        let declDiff = abs(actualDecl - expectedDeclination)
        
        if raDiff >= 1e-6 {
            Issue.record("Right ascension: expected \(expectedRightAscension), got \(actualRA), difference: \(raDiff)")
            return
        }
        if declDiff >= 1e-6 {
            Issue.record("Declination: expected \(expectedDeclination), got \(actualDecl), difference: \(declDiff)")
            return
        }
        
        // Verify horizontal position (azimuth and altitude)
        guard let horizontalPosition = factorPosition.horizontal.first else {
            Issue.record("Horizontal position not found")
            return
        }
        
        let actualAzimuth = horizontalPosition.azimuth
        let actualAltitude = horizontalPosition.altitude
        
        let aziDiff = abs(actualAzimuth - expectedAzimuth)
        let altDiff = abs(actualAltitude - expectedAltitude)
        
        if aziDiff >= 1e-6 {
            Issue.record("Azimuth: expected \(expectedAzimuth), got \(actualAzimuth), difference: \(aziDiff)")
            return
        }
        if altDiff >= 1e-6 {
            Issue.record("Altitude: expected \(expectedAltitude), got \(actualAltitude), difference: \(altDiff)")
            return
        }
    }
}
