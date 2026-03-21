//
//  FactorConfigTests.swift
//  EnigmaAplTests
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Testing
@testable import EnigmaApl

struct FactorConfigTests {

    // MARK: - FactorSettings

    @Test("FactorSettings: stores all properties correctly")
    func testFactorSettingsInit() {
        let settings = FactorSettings(factor: .sun, isUsed: true, isDrawn: true, orbPercentage: 100)
        #expect(settings.factor == .sun)
        #expect(settings.isUsed == true)
        #expect(settings.isDrawn == true)
        #expect(settings.orbPercentage == 100)
    }

    @Test("FactorSettings: default orbPercentage is 100")
    func testFactorSettingsDefaultOrb() {
        let settings = FactorSettings(factor: .moon, isUsed: true, isDrawn: true)
        #expect(settings.orbPercentage == 100)
    }

    @Test("FactorSettings: inactive factor")
    func testFactorSettingsInactive() {
        let settings = FactorSettings(factor: .sedna, isUsed: false, isDrawn: false, orbPercentage: 100)
        #expect(settings.isUsed == false)
        #expect(settings.isDrawn == false)
    }

    // MARK: - FactorConfig initialization

    @Test("FactorConfig: default initialization contains all factors")
    func testDefaultConfigContainsAllFactors() {
        let config = FactorConfig()
        #expect(config.factorSettings.count == Factors.allCases.count)
    }

    @Test("FactorConfig: each factor appears exactly once in default config")
    func testDefaultConfigEachFactorOnce() {
        let config = FactorConfig()
        for factor in Factors.allCases {
            let count = config.factorSettings.filter { $0.factor == factor }.count
            #expect(count == 1)
        }
    }

    @Test("FactorConfig: custom initialization")
    func testCustomInit() {
        let settings = [
            FactorSettings(factor: .sun, isUsed: true, isDrawn: true, orbPercentage: 100),
            FactorSettings(factor: .moon, isUsed: true, isDrawn: false, orbPercentage: 80)
        ]
        let config = FactorConfig(factorSettings: settings)
        #expect(config.factorSettings.count == 2)
    }

    // MARK: - Default settings

    @Test("FactorConfig: sun, moon, ascendant and mc have orb 100% by default")
    func testPrimaryFactorsOrb100() {
        let config = FactorConfig()
        for factor in [Factors.sun, .moon, .ascendant, .mc] {
            let settings = config.factorSettings.first { $0.factor == factor }
            #expect(settings?.isUsed == true)
            #expect(settings?.isDrawn == true)
            #expect(settings?.orbPercentage == 100)
        }
    }

    @Test("FactorConfig: mercury, venus, mars and jupiter have orb 85% by default")
    func testInnerPlanetsOrb85() {
        let config = FactorConfig()
        for factor in [Factors.mercury, .venus, .mars, .jupiter] {
            let settings = config.factorSettings.first { $0.factor == factor }
            #expect(settings?.isUsed == true)
            #expect(settings?.isDrawn == true)
            #expect(settings?.orbPercentage == 85)
        }
    }

    @Test("FactorConfig: saturn through chiron have orb 75% by default")
    func testOuterPlanetsOrb75() {
        let config = FactorConfig()
        for factor in [Factors.saturn, .uranus, .neptune, .pluto, .northNode, .chiron] {
            let settings = config.factorSettings.first { $0.factor == factor }
            #expect(settings?.isUsed == true)
            #expect(settings?.isDrawn == true)
            #expect(settings?.orbPercentage == 75)
        }
    }

    @Test("FactorConfig: minor factors are inactive with orb 50% by default")
    func testMinorFactorsInactiveByDefault() {
        let config = FactorConfig()
        let minorFactors: [Factors] = [.sedna, .makemake, .eris, .cupidoUra, .persephoneRam]
        for factor in minorFactors {
            let settings = config.factorSettings.first { $0.factor == factor }
            #expect(settings?.isUsed == false)
            #expect(settings?.isDrawn == false)
            #expect(settings?.orbPercentage == 50)
        }
    }

    // MARK: - Codable

    @Test("FactorConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = FactorConfig()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FactorConfig.self, from: data)
        #expect(decoded.factorSettings.count == original.factorSettings.count)
        for (orig, dec) in zip(original.factorSettings, decoded.factorSettings) {
            #expect(orig.factor == dec.factor)
            #expect(orig.isUsed == dec.isUsed)
            #expect(orig.isDrawn == dec.isDrawn)
            #expect(orig.orbPercentage == dec.orbPercentage)
        }
    }

    @Test("FactorSettings: encodes and decodes correctly")
    func testFactorSettingsCodableRoundtrip() throws {
        let original = FactorSettings(factor: .mars, isUsed: true, isDrawn: false, orbPercentage: 80)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FactorSettings.self, from: data)
        #expect(decoded == original)
    }
}
