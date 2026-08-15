// CalculationConfigTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct CalculationConfigTests {

    // MARK: - Initialization

    @Test("CalculationConfig: initialization with all parameters")
    func testInitializationWithAllParameters() {
        let config = CalculationConfig(
            houseSystem: .regiomontanus,
            ayanamsha: .lahiri,
            observerPosition: .topoCentric,
            projectionType: .obliqueLongitude,
            lunarNodeType: .trueNode,
            lotsType: .noSect
        )
        #expect(config.houseSystem == .regiomontanus)
        #expect(config.ayanamsha == .lahiri)
        #expect(config.observerPosition == .topoCentric)
        #expect(config.projectionType == .obliqueLongitude)
        #expect(config.lunarNodeType == .trueNode)
        #expect(config.lotsType == .noSect)
    }

    @Test("CalculationConfig: default initialization")
    func testDefaultInitialization() {
        let config = CalculationConfig()
        #expect(config.houseSystem == .placidus)
        #expect(config.ayanamsha == .tropical)
        #expect(config.observerPosition == .geoCentric)
        #expect(config.projectionType == .twoDimensional)
        #expect(config.lunarNodeType == .meanNode)
        #expect(config.lotsType == .sect)
        #expect(config.stationaryPercentage == 10)
        #expect(config.slowPercentage == 20)
    }

    // MARK: - All enum cases

    @Test("CalculationConfig: all house systems are accepted")
    func testAllHouseSystems() {
        for houseSystem in HouseSystems.allCases {
            let config = CalculationConfig(houseSystem: houseSystem)
            #expect(config.houseSystem == houseSystem)
        }
    }

    @Test("CalculationConfig: all ayanamshas are accepted")
    func testAllAyanamshas() {
        for ayanamsha in Ayanamshas.allCases {
            let config = CalculationConfig(ayanamsha: ayanamsha)
            #expect(config.ayanamsha == ayanamsha)
        }
    }

    @Test("CalculationConfig: all observer positions are accepted")
    func testAllObserverPositions() {
        for observerPosition in ObserverPositions.allCases {
            let config = CalculationConfig(observerPosition: observerPosition)
            #expect(config.observerPosition == observerPosition)
        }
    }

    @Test("CalculationConfig: all projection types are accepted")
    func testAllProjectionTypes() {
        for projectionType in ProjectionTypes.allCases {
            let config = CalculationConfig(projectionType: projectionType)
            #expect(config.projectionType == projectionType)
        }
    }

    @Test("CalculationConfig: all lunar node types are accepted")
    func testAllLunarNodeTypes() {
        for lunarNodeType in LunarNodeTypes.allCases {
            let config = CalculationConfig(lunarNodeType: lunarNodeType)
            #expect(config.lunarNodeType == lunarNodeType)
        }
    }

    @Test("CalculationConfig: all lots types are accepted")
    func testAllLotsTypes() {
        for lotsType in LotsTypes.allCases {
            let config = CalculationConfig(lotsType: lotsType)
            #expect(config.lotsType == lotsType)
        }
    }

    // MARK: - Codable

    @Test("CalculationConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = CalculationConfig(
            houseSystem: .koch,
            ayanamsha: .fagan,
            observerPosition: .helioCentric,
            projectionType: .obliqueLongitude,
            lunarNodeType: .trueNode,
            lotsType: .noSect
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CalculationConfig.self, from: data)
        #expect(decoded.houseSystem == original.houseSystem)
        #expect(decoded.ayanamsha == original.ayanamsha)
        #expect(decoded.observerPosition == original.observerPosition)
        #expect(decoded.projectionType == original.projectionType)
        #expect(decoded.lunarNodeType == original.lunarNodeType)
        #expect(decoded.lotsType == original.lotsType)
        #expect(decoded.stationaryPercentage == original.stationaryPercentage)
        #expect(decoded.slowPercentage == original.slowPercentage)
    }

    // MARK: - Stationary and slow

    @Test("CalculationConfig: custom stationary and slow percentages")
    func testCustomStationaryAndSlow() {
        let config = CalculationConfig(stationaryPercentage: 5, slowPercentage: 25)
        #expect(config.stationaryPercentage == 5)
        #expect(config.slowPercentage == 25)
    }

    // MARK: - Common configurations

    @Test("CalculationConfig: western tropical configuration")
    func testWesternTropicalConfig() {
        let config = CalculationConfig(
            houseSystem: .placidus,
            ayanamsha: .tropical,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            lunarNodeType: .meanNode,
            lotsType: .sect
        )
        #expect(config.houseSystem == .placidus)
        #expect(config.ayanamsha == .tropical)
    }

    @Test("CalculationConfig: vedic sidereal configuration")
    func testVedicSiderealConfig() {
        let config = CalculationConfig(
            houseSystem: .wholeSign,
            ayanamsha: .lahiri,
            observerPosition: .geoCentric,
            projectionType: .twoDimensional,
            lunarNodeType: .trueNode,
            lotsType: .noSect
        )
        #expect(config.houseSystem == .wholeSign)
        #expect(config.ayanamsha == .lahiri)
    }
}
