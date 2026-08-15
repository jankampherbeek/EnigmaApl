// ProgressiveCalculatorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

// Julian Day for 2009-12-31 12:00 UT — same reference date used across AstronCalc tests.
private let refJulianDay = 2455197.5

@MainActor
struct ProgressiveCalculatorTests {

    private func geocentricConfig() -> CalculationConfig {
        CalculationConfig(
            houseSystem: .noHouses,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
    }

    // MARK: - Longitude

    @Test("ProgressiveCalculator: Sun longitude matches known ephemeris value")
    func testSunLongitudeKnownValue() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let result = ProgressiveCalculator.performCalculation(
            ProgressiveCalcRequest(julianDay: refJulianDay),
            calculationConfig: geocentricConfig(),
            factors: [.sun],
            seWrapper: seWrapper
        )
        let longitude = result[.sun]?.longitude ?? -1.0
        #expect(abs(longitude - 280.4511630990) < 1e-6,
                "Sun longitude: expected 280.4511630990, got \(longitude)")
    }

    @Test("ProgressiveCalculator: Moon longitude matches known ephemeris value")
    func testMoonLongitudeKnownValue() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let result = ProgressiveCalculator.performCalculation(
            ProgressiveCalcRequest(julianDay: refJulianDay),
            calculationConfig: geocentricConfig(),
            factors: [.moon],
            seWrapper: seWrapper
        )
        let longitude = result[.moon]?.longitude ?? -1.0
        #expect(abs(longitude - 103.2443853269) < 1e-6,
                "Moon longitude: expected 103.2443853269, got \(longitude)")
    }

    @Test("ProgressiveCalculator: all main planet longitudes match known ephemeris values")
    func testMainPlanetLongitudes() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let expected: [Factors: Double] = [
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
        let result = ProgressiveCalculator.performCalculation(
            ProgressiveCalcRequest(julianDay: refJulianDay),
            calculationConfig: geocentricConfig(),
            factors: Array(expected.keys),
            seWrapper: seWrapper
        )
        for (factor, expectedLon) in expected {
            let actual = result[factor]?.longitude ?? -1.0
            #expect(abs(actual - expectedLon) < 1e-6,
                    "Longitude for \(factor): expected \(expectedLon), got \(actual)")
        }
    }

    // MARK: - Declination

    @Test("ProgressiveCalculator: Sun declination is south in late December (~-23°)")
    func testSunDeclinationSouthInDecember() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let result = ProgressiveCalculator.performCalculation(
            ProgressiveCalcRequest(julianDay: refJulianDay),
            calculationConfig: geocentricConfig(),
            factors: [.sun],
            seWrapper: seWrapper
        )
        let declination = result[.sun]?.declination ?? 0.0
        #expect(declination < -22.0 && declination > -24.0,
                "Sun declination on Dec 31 should be ~-23°, got \(declination)")
    }

    @Test("ProgressiveCalculator: declination matches AstronCalcOrchestrator for inner planets")
    func testDeclinationMatchesOrchestrator() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let factors: [Factors] = [.sun, .moon, .mercury, .venus, .mars]
        let config = geocentricConfig()

        let result = ProgressiveCalculator.performCalculation(
            ProgressiveCalcRequest(julianDay: refJulianDay),
            calculationConfig: config,
            factors: factors,
            seWrapper: seWrapper
        )

        let referenceRequest = CalcRequest(
            JulianDay: refJulianDay,
            FactorsToUse: factors,
            HouseSystem: HouseSystems.noHouses.rawValue,
            Latitude: 0.0,
            Longitude: 0.0,
            Height: 0.0,
            calculationConfig: config
        )
        let fullChart = AstronCalcOrchestrator.PerformCalculation(referenceRequest, seWrapper: seWrapper)

        for factor in factors {
            let expected = fullChart.Coordinates[factor]?.equatorial.first?.deviation ?? 0.0
            let actual = result[factor]?.declination ?? -999.0
            #expect(abs(actual - expected) < 1e-6,
                    "Declination for \(factor): expected \(expected), got \(actual)")
        }
    }

    // MARK: - Topocentric override

    @Test("ProgressiveCalculator: topocentric config produces identical result to geocentric")
    func testTopocentricOverriddenToGeocentric() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let factors: [Factors] = [.sun, .moon]
        let request = ProgressiveCalcRequest(julianDay: refJulianDay)

        let topoConfig = CalculationConfig(observerPosition: .topoCentric)
        let geoResult = ProgressiveCalculator.performCalculation(
            request, calculationConfig: geocentricConfig(), factors: factors, seWrapper: seWrapper)
        let topoResult = ProgressiveCalculator.performCalculation(
            request, calculationConfig: topoConfig, factors: factors, seWrapper: seWrapper)

        for factor in factors {
            let geoLon  = geoResult[factor]?.longitude    ?? -1.0
            let topoLon = topoResult[factor]?.longitude   ?? -2.0
            let geoDecl  = geoResult[factor]?.declination ?? -1.0
            let topoDecl = topoResult[factor]?.declination ?? -2.0
            #expect(geoLon == topoLon,
                    "Topo override: longitude for \(factor) must equal geocentric")
            #expect(geoDecl == topoDecl,
                    "Topo override: declination for \(factor) must equal geocentric")
        }
    }

    // MARK: - Factor filtering

    @Test("ProgressiveCalculator: only requested factors appear in result")
    func testOnlyRequestedFactorsReturned() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let result = ProgressiveCalculator.performCalculation(
            ProgressiveCalcRequest(julianDay: refJulianDay),
            calculationConfig: geocentricConfig(),
            factors: [.sun, .mars],
            seWrapper: seWrapper
        )
        #expect(result.keys.contains(.sun),     "Result should contain sun")
        #expect(result.keys.contains(.mars),    "Result should contain mars")
        #expect(!result.keys.contains(.moon),   "Result should not contain moon")
        #expect(!result.keys.contains(.jupiter),"Result should not contain jupiter")
    }

    @Test("ProgressiveCalculator: empty factor list returns empty result")
    func testEmptyFactorsReturnsEmptyResult() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let result = ProgressiveCalculator.performCalculation(
            ProgressiveCalcRequest(julianDay: refJulianDay),
            calculationConfig: geocentricConfig(),
            factors: [],
            seWrapper: seWrapper
        )
        #expect(result.isEmpty, "Empty factor list should produce empty result")
    }

    // MARK: - Value range

    @Test("ProgressiveCalculator: all longitudes are within 0–360°")
    func testLongitudeRange() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let factors: [Factors] = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn]
        let result = ProgressiveCalculator.performCalculation(
            ProgressiveCalcRequest(julianDay: refJulianDay),
            calculationConfig: geocentricConfig(),
            factors: factors,
            seWrapper: seWrapper
        )
        for (factor, position) in result {
            #expect(position.longitude >= 0.0 && position.longitude < 360.0,
                    "Longitude for \(factor) must be in [0, 360), got \(position.longitude)")
        }
    }

    @Test("ProgressiveCalculator: all declinations are within ±90°")
    func testDeclinationRange() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let factors: [Factors] = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn]
        let result = ProgressiveCalculator.performCalculation(
            ProgressiveCalcRequest(julianDay: refJulianDay),
            calculationConfig: geocentricConfig(),
            factors: factors,
            seWrapper: seWrapper
        )
        for (factor, position) in result {
            #expect(position.declination >= -90.0 && position.declination <= 90.0,
                    "Declination for \(factor) must be in [-90, 90], got \(position.declination)")
        }
    }
}
