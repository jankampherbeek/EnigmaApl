//
//  AspectConfigTests.swift
//  EnigmaAplTests
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Testing
@testable import EnigmaApl

struct AspectConfigTests {

    // MARK: - AspectSettings

    @Test("AspectSettings: stores all properties correctly")
    func testAspectSettingsInit() {
        let settings = AspectSettings(aspect: .conjunction, isUsed: true, isDrawn: true, orbPercentage: 100)
        #expect(settings.aspect == .conjunction)
        #expect(settings.isUsed == true)
        #expect(settings.isDrawn == true)
        #expect(settings.orbPercentage == 100)
    }

    @Test("AspectSettings: default orbPercentage is 100")
    func testAspectSettingsDefaultOrb() {
        let settings = AspectSettings(aspect: .trine, isUsed: true, isDrawn: true)
        #expect(settings.orbPercentage == 100)
    }

    @Test("AspectSettings: inactive aspect")
    func testAspectSettingsInactive() {
        let settings = AspectSettings(aspect: .vigintile, isUsed: false, isDrawn: false, orbPercentage: 15)
        #expect(settings.isUsed == false)
        #expect(settings.isDrawn == false)
    }

    // MARK: - AspectConfig initialization

    @Test("AspectConfig: default initialization contains all aspects")
    func testDefaultConfigContainsAllAspects() {
        let config = AspectConfig()
        #expect(config.aspectSettings.count == Aspects.allCases.count)
    }

    @Test("AspectConfig: each aspect appears exactly once in default config")
    func testDefaultConfigEachAspectOnce() {
        let config = AspectConfig()
        for aspect in Aspects.allCases {
            let count = config.aspectSettings.filter { $0.aspect == aspect }.count
            #expect(count == 1)
        }
    }

    @Test("AspectConfig: custom initialization")
    func testCustomInit() {
        let settings = [
            AspectSettings(aspect: .conjunction, isUsed: true, isDrawn: true, orbPercentage: 100),
            AspectSettings(aspect: .opposition, isUsed: true, isDrawn: false, orbPercentage: 80)
        ]
        let config = AspectConfig(aspectSettings: settings)
        #expect(config.aspectSettings.count == 2)
    }

    // MARK: - Default orb percentages

    @Test("AspectConfig: conjunction and opposition have orb 100% by default")
    func testMajorAspectsOrb100() {
        let config = AspectConfig()
        for aspect in [Aspects.conjunction, .opposition] {
            let settings = config.aspectSettings.first { $0.aspect == aspect }
            #expect(settings?.isUsed == true)
            #expect(settings?.isDrawn == true)
            #expect(settings?.orbPercentage == 100)
        }
    }

    @Test("AspectConfig: trine and square have orb 80% by default")
    func testTrineSquareOrb80() {
        let config = AspectConfig()
        for aspect in [Aspects.trine, .square] {
            let settings = config.aspectSettings.first { $0.aspect == aspect }
            #expect(settings?.isUsed == true)
            #expect(settings?.isDrawn == true)
            #expect(settings?.orbPercentage == 80)
        }
    }

    @Test("AspectConfig: sextile has orb 60% by default")
    func testSextileOrb60() {
        let config = AspectConfig()
        let settings = config.aspectSettings.first { $0.aspect == .sextile }
        #expect(settings?.isUsed == true)
        #expect(settings?.isDrawn == true)
        #expect(settings?.orbPercentage == 60)
    }

    @Test("AspectConfig: inconjunct has orb 30% by default")
    func testInconjunctOrb30() {
        let config = AspectConfig()
        let settings = config.aspectSettings.first { $0.aspect == .inconjunct }
        #expect(settings?.isUsed == true)
        #expect(settings?.isDrawn == true)
        #expect(settings?.orbPercentage == 30)
    }

    @Test("AspectConfig: minor aspects are inactive with orb 15% by default")
    func testMinorAspectsInactiveByDefault() {
        let config = AspectConfig()
        let minorAspects: [Aspects] = [.septile, .quintile, .semisextile, .semisquare,
                                        .novile, .undecile, .centile, .vigintile]
        for aspect in minorAspects {
            let settings = config.aspectSettings.first { $0.aspect == aspect }
            #expect(settings?.isUsed == false)
            #expect(settings?.isDrawn == false)
            #expect(settings?.orbPercentage == 15)
        }
    }

    // MARK: - Codable

    @Test("AspectConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = AspectConfig()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AspectConfig.self, from: data)
        #expect(decoded.aspectSettings.count == original.aspectSettings.count)
        for (orig, dec) in zip(original.aspectSettings, decoded.aspectSettings) {
            #expect(orig.aspect == dec.aspect)
            #expect(orig.isUsed == dec.isUsed)
            #expect(orig.isDrawn == dec.isDrawn)
            #expect(orig.orbPercentage == dec.orbPercentage)
        }
    }

    @Test("AspectSettings: encodes and decodes correctly")
    func testAspectSettingsCodableRoundtrip() throws {
        let original = AspectSettings(aspect: .trine, isUsed: true, isDrawn: false, orbPercentage: 80)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AspectSettings.self, from: data)
        #expect(decoded == original)
    }
}
