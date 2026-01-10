//
//  SECalculationTests.swift
//  EnigmaAplTests
//
//  Created on 03/01/2026.
//

import Testing
import Foundation
@testable import EnigmaApl

struct SECalculationTests {
    
    @Test("SECalculation: CalculateFactors for multiple planets")
    @MainActor
    func testCalculateFactors() {
        // Test parameters
        let julianDay = 2455197.5
        let factorsToUse: [Factors] = [
            .sun, .moon, .mercury, .venus, .mars,
            .jupiter, .saturn, .uranus, .neptune, .pluto, .chiron
        ]
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
            .sun: (
                longitude: 280.4511630989501,
                latitude: 6.421319500009122e-06,
                rightAscension: 281.36758889805407,
                declination: -23.027292543865247,
                azimuth: 191.37666042273162,
                altitude: -60.44002178482999
            ),
            .moon: (
                longitude: 103.24438532686366,
                latitude: 0.7232056028044642,
                rightAscension: 104.46593468073955,
                declination: 23.49933189269182,
                azimuth: 5.661534209030776,
                altitude: 61.19133136191404
            ),
            .mercury: (
                longitude: 288.99588889960705,
                latitude: 1.6352411248024754,
                rightAscension: 290.3225862463011,
                declination: -20.473370869843002,
                azimuth: 174.86934362461636,
                altitude: -58.17617247965966
            ),
            .venus: (
                longitude: 277.8499668251785,
                latitude: -0.43658525705507123,
                rightAscension: 278.5741220590759,
                declination: -23.64201187601717,
                azimuth: 196.726220282878,
                altitude: -60.63123035159064
            ),
            .mars: (
                longitude: 138.81750051282245,
                latitude: 3.757478836447926,
                rightAscension: 142.4759827016483,
                declination: 18.752303959095585,
                azimuth: 307.40998271980834,
                altitude: 46.808883519287555
            ),
            .jupiter: (
                longitude: 326.3588628479526,
                latitude: -0.9346106850260953,
                rightAscension: 328.9212989407965,
                declination: -13.609055620924892,
                azimuth: 123.81897436082852,
                altitude: -39.201313639773225
            ),
            .saturn: (
                longitude: 184.50657988994416,
                latitude: 2.2878293497696482,
                rightAscension: 185.04353770673217,
                declination: 0.3091932697911077,
                azimuth: 279.664473955995,
                altitude: 7.802456453961314
            ),
            .uranus: (
                longitude: 353.090090761465,
                latitude: -0.7461682826584854,
                rightAscension: 353.9509075831898,
                declination: -3.4282798856911176,
                azimuth: 106.87852168993871,
                altitude: -16.917187662795126
            ),
            .neptune: (
                longitude: 324.5820935220113,
                latitude: -0.4182702208240066,
                rightAscension: 327.0207996819579,
                declination: -13.722099053863916,
                azimuth: 125.7973463986184,
                altitude: -40.254044055107244
            ),
            .pluto: (
                longitude: 273.30882107169646,
                latitude: 5.09910864121545,
                rightAscension: 273.4714750360126,
                declination: -18.299791029972063,
                azimuth: 203.15323163806454,
                altitude: -54.35466539358144
            ),
            .chiron: (
                longitude: 323.1153218114565,
                latitude: 5.970938940213878,
                rightAscension: 323.4801166430204,
                declination: -8.164029082282365,
                azimuth: 133.1291182606087,
                altitude: -37.05611517731522
            )
        ]
        
        // Create SEWrapper instance for the test
        let seWrapper = SEWrapper()
        
        // Perform calculation
        let result = SECalculation.CalculateFactors(request, seWrapper: seWrapper)
        
        // Calculate obliquity separately for verification (using id -1)
        let obliquityPosition = seWrapper.calculateFactorPosition(
            julianDay: julianDay,
            planet: -1,
            flags: 258
        )
        let obliquity = obliquityPosition?.mainPos ?? 0.0
        
        // Verify obliquity is calculated (should be a reasonable value between 23 and 24 degrees)
        #expect(obliquity > 23.0 && obliquity < 24.0, "Obliquity should be between 23 and 24 degrees, got \(obliquity)")
        
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

