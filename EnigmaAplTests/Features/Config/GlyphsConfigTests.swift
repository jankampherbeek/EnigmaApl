//
//  GlyphsConfigTests.swift
//  EnigmaAplTests
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Testing
@testable import EnigmaApl

struct GlyphsConfigTests {

    // MARK: - Default initialization

    @Test("GlyphsConfig: default sign glyphs contain all signs")
    func testDefaultSignGlyphsContainsAllSigns() {
        let config = GlyphsConfig()
        #expect(config.signGlyphs.count == Signs.allCases.count)
    }

    @Test("GlyphsConfig: default factor glyphs contain all factors")
    func testDefaultFactorGlyphsContainsAllFactors() {
        let config = GlyphsConfig()
        #expect(config.factorGlyphs.count == Factors.allCases.count)
    }

    @Test("GlyphsConfig: default aspect glyphs contain all aspects")
    func testDefaultAspectGlyphsContainsAllAspects() {
        let config = GlyphsConfig()
        #expect(config.aspectGlyphs.count == Aspects.allCases.count)
    }

    @Test("GlyphsConfig: each sign appears exactly once in default config")
    func testDefaultSignGlyphsEachSignOnce() {
        let config = GlyphsConfig()
        for sign in Signs.allCases {
            let count = config.signGlyphs.filter { $0.sign == sign }.count
            #expect(count == 1)
        }
    }

    @Test("GlyphsConfig: each factor appears exactly once in default config")
    func testDefaultFactorGlyphsEachFactorOnce() {
        let config = GlyphsConfig()
        for factor in Factors.allCases {
            let count = config.factorGlyphs.filter { $0.factor == factor }.count
            #expect(count == 1)
        }
    }

    @Test("GlyphsConfig: each aspect appears exactly once in default config")
    func testDefaultAspectGlyphsEachAspectOnce() {
        let config = GlyphsConfig()
        for aspect in Aspects.allCases {
            let count = config.aspectGlyphs.filter { $0.aspect == aspect }.count
            #expect(count == 1)
        }
    }

    // MARK: - Setting structs

    @Test("SignGlyphSetting: stores sign and glyph correctly")
    func testSignGlyphSetting() {
        let setting = SignGlyphSetting(sign: .Leo, glyph: "L")
        #expect(setting.sign == .Leo)
        #expect(setting.glyph == "L")
    }

    @Test("FactorGlyphSetting: stores factor and glyph correctly")
    func testFactorGlyphSetting() {
        let setting = FactorGlyphSetting(factor: .mars, glyph: "M")
        #expect(setting.factor == .mars)
        #expect(setting.glyph == "M")
    }

    @Test("AspectGlyphSetting: stores aspect and glyph correctly")
    func testAspectGlyphSetting() {
        let setting = AspectGlyphSetting(aspect: .trine, glyph: "T")
        #expect(setting.aspect == .trine)
        #expect(setting.glyph == "T")
    }

    // MARK: - GlyphCandidates

    @Test("GlyphCandidates: returns candidates for every sign")
    func testCandidatesForAllSigns() {
        for sign in Signs.allCases {
            let candidates = GlyphCandidates.candidates(for: sign)
            #expect(!candidates.isEmpty)
        }
    }

    @Test("GlyphCandidates: returns candidates for every factor")
    func testCandidatesForAllFactors() {
        for factor in Factors.allCases {
            let candidates = GlyphCandidates.candidates(for: factor)
            #expect(!candidates.isEmpty)
        }
    }

    @Test("GlyphCandidates: returns candidates for every aspect")
    func testCandidatesForAllAspects() {
        for aspect in Aspects.allCases {
            let candidates = GlyphCandidates.candidates(for: aspect)
            #expect(!candidates.isEmpty)
        }
    }

    // MARK: - Codable

    @Test("GlyphsConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = GlyphsConfig()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GlyphsConfig.self, from: data)
        #expect(decoded.signGlyphs.count == original.signGlyphs.count)
        #expect(decoded.factorGlyphs.count == original.factorGlyphs.count)
        #expect(decoded.aspectGlyphs.count == original.aspectGlyphs.count)
    }

    @Test("SignGlyphSetting: encodes and decodes correctly")
    func testSignGlyphSettingCodableRoundtrip() throws {
        let original = SignGlyphSetting(sign: .Scorpio, glyph: "S")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SignGlyphSetting.self, from: data)
        #expect(decoded == original)
    }

    @Test("FactorGlyphSetting: encodes and decodes correctly")
    func testFactorGlyphSettingCodableRoundtrip() throws {
        let original = FactorGlyphSetting(factor: .jupiter, glyph: "J")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FactorGlyphSetting.self, from: data)
        #expect(decoded == original)
    }

    @Test("AspectGlyphSetting: encodes and decodes correctly")
    func testAspectGlyphSettingCodableRoundtrip() throws {
        let original = AspectGlyphSetting(aspect: .sextile, glyph: "X")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AspectGlyphSetting.self, from: data)
        #expect(decoded == original)
    }
}
