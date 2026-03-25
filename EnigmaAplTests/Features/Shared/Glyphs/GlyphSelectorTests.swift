// GlyphSelectorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct GlyphSelectorTests {

    // MARK: - Factor glyph tests

    @Test("GlyphSelector: getGlyphForFactor returns a glyph for all factors")
    func testGetGlyphForFactorAllCases() {
        for factor in Factors.allCases {
            let glyph = GlyphSelector.getGlyphForFactor(factor)
            #expect(!glyph.isEmpty, "Expected non-empty glyph for factor \(factor)")
        }
    }

    @Test("GlyphSelector: getGlyphForFactor returns correct glyph for major planets")
    func testGetGlyphForFactorMajorPlanets() {
        #expect(GlyphSelector.getGlyphForFactor(.sun)     == "\u{E200}")
        #expect(GlyphSelector.getGlyphForFactor(.moon)    == "\u{E201}")
        #expect(GlyphSelector.getGlyphForFactor(.mercury) == "\u{E202}")
        #expect(GlyphSelector.getGlyphForFactor(.venus)   == "\u{E203}")
        #expect(GlyphSelector.getGlyphForFactor(.mars)    == "\u{E205}")
        #expect(GlyphSelector.getGlyphForFactor(.jupiter) == "\u{E206}")
        #expect(GlyphSelector.getGlyphForFactor(.saturn)  == "\u{E207}")
        #expect(GlyphSelector.getGlyphForFactor(.uranus)  == "\u{E208}")
        #expect(GlyphSelector.getGlyphForFactor(.neptune) == "\u{E209}")
        #expect(GlyphSelector.getGlyphForFactor(.pluto)   == "\u{E210}")
    }

    @Test("GlyphSelector: getGlyphForFactor returns correct glyph for nodes")
    func testGetGlyphForFactorNodes() {
        #expect(GlyphSelector.getGlyphForFactor(.northNode) == "\u{E520}")
        #expect(GlyphSelector.getGlyphForFactor(.southNode) == "\u{E521}")
    }

    @Test("GlyphSelector: getGlyphForFactor returns correct glyph for mundane points")
    func testGetGlyphForFactorMundane() {
        #expect(GlyphSelector.getGlyphForFactor(.ascendant) == "\u{E500}")
        #expect(GlyphSelector.getGlyphForFactor(.mc)        == "\u{E501}")
        #expect(GlyphSelector.getGlyphForFactor(.vertex)    == "\u{E502}")
        #expect(GlyphSelector.getGlyphForFactor(.eastPoint) == "\u{E503}")
    }

    @Test("GlyphSelector: getGlyphForFactor returns correct glyph for Uranian planets")
    func testGetGlyphForFactorUranian() {
        #expect(GlyphSelector.getGlyphForFactor(.cupidoUra)   == "\u{E600}")
        #expect(GlyphSelector.getGlyphForFactor(.hadesUra)    == "\u{E601}")
        #expect(GlyphSelector.getGlyphForFactor(.zeusUra)     == "\u{E602}")
        #expect(GlyphSelector.getGlyphForFactor(.kronosUra)   == "\u{E603}")
        #expect(GlyphSelector.getGlyphForFactor(.apollonUra)  == "\u{E604}")
        #expect(GlyphSelector.getGlyphForFactor(.admetosUra)  == "\u{E605}")
        #expect(GlyphSelector.getGlyphForFactor(.vulcanusUra) == "\u{E606}")
        #expect(GlyphSelector.getGlyphForFactor(.poseidonUra) == "\u{E607}")
    }

    @Test("GlyphSelector: configure updates glyph for factor")
    func testConfigureUpdatesFactorGlyph() {
        let customGlyphs = GlyphsConfig.defaultFactorGlyphs.map { setting in
            setting.factor == .sun
                ? FactorGlyphSetting(factor: .sun, glyph: "\u{E299}")
                : setting
        }
        GlyphSelector.configure(with: GlyphsConfig(factorGlyphs: customGlyphs))
        #expect(GlyphSelector.getGlyphForFactor(.sun) == "\u{E299}")
        // Restore defaults
        GlyphSelector.configure(with: GlyphsConfig())
    }

    // MARK: - Sign glyph tests

    @Test("GlyphSelector: getGlyphForSign returns a glyph for all signs")
    func testGetGlyphForSignAllCases() {
        for sign in Signs.allCases {
            let glyph = GlyphSelector.getGlyphForSign(sign)
            #expect(!glyph.isEmpty, "Expected non-empty glyph for sign \(sign)")
        }
    }

    @Test("GlyphSelector: getGlyphForSign returns correct glyph for all signs")
    func testGetGlyphForSignValues() {
        #expect(GlyphSelector.getGlyphForSign(.Aries)       == "\u{E000}")
        #expect(GlyphSelector.getGlyphForSign(.Taurus)      == "\u{E001}")
        #expect(GlyphSelector.getGlyphForSign(.Gemini)      == "\u{E002}")
        #expect(GlyphSelector.getGlyphForSign(.Cancer)      == "\u{E003}")
        #expect(GlyphSelector.getGlyphForSign(.Leo)         == "\u{E004}")
        #expect(GlyphSelector.getGlyphForSign(.Virgo)       == "\u{E005}")
        #expect(GlyphSelector.getGlyphForSign(.Libra)       == "\u{E006}")
        #expect(GlyphSelector.getGlyphForSign(.Scorpio)     == "\u{E007}")
        #expect(GlyphSelector.getGlyphForSign(.Sagittarius) == "\u{E008}")
        #expect(GlyphSelector.getGlyphForSign(.Capricorn)   == "\u{E009}")
        #expect(GlyphSelector.getGlyphForSign(.Aquarius)    == "\u{E010}")
        #expect(GlyphSelector.getGlyphForSign(.Pisces)      == "\u{E011}")
    }

    // MARK: - Aspect glyph tests

    @Test("GlyphSelector: getGlyphForAspect returns a glyph for all aspects")
    func testGetGlyphForAspectAllCases() {
        for aspect in Aspects.allCases {
            let glyph = GlyphSelector.getGlyphForAspect(aspect)
            #expect(!glyph.isEmpty, "Expected non-empty glyph for aspect \(aspect)")
        }
    }

    @Test("GlyphSelector: getGlyphForAspect returns correct glyph for classical aspects")
    func testGetGlyphForAspectClassical() {
        #expect(GlyphSelector.getGlyphForAspect(.conjunction) == "\u{E700}")
        #expect(GlyphSelector.getGlyphForAspect(.opposition)  == "\u{E710}")
        #expect(GlyphSelector.getGlyphForAspect(.square)      == "\u{E730}")
        #expect(GlyphSelector.getGlyphForAspect(.sextile)     == "\u{E740}")
        #expect(GlyphSelector.getGlyphForAspect(.inconjunct)  == "\u{E760}")
    }

    @Test("GlyphSelector: getGlyphForAspect returns correct glyph for minor aspects")
    func testGetGlyphForAspectMinor() {
        #expect(GlyphSelector.getGlyphForAspect(.semisextile)    == "\u{E750}")
        #expect(GlyphSelector.getGlyphForAspect(.semisquare)     == "\u{E770}")
        #expect(GlyphSelector.getGlyphForAspect(.sesquiquadrate) == "\u{E780}")
        #expect(GlyphSelector.getGlyphForAspect(.quintile)       == "\u{E790}")
        #expect(GlyphSelector.getGlyphForAspect(.biquintile)     == "\u{E800}")
        #expect(GlyphSelector.getGlyphForAspect(.septile)        == "\u{E810}")
        #expect(GlyphSelector.getGlyphForAspect(.semiquintile)   == "\u{E830}")
        #expect(GlyphSelector.getGlyphForAspect(.tridecile)      == "\u{E840}")
        #expect(GlyphSelector.getGlyphForAspect(.biseptile)      == "\u{E850}")
        #expect(GlyphSelector.getGlyphForAspect(.triseptile)     == "\u{E860}")
        #expect(GlyphSelector.getGlyphForAspect(.novile)         == "\u{E870}")
        #expect(GlyphSelector.getGlyphForAspect(.binovile)       == "\u{E880}")
        #expect(GlyphSelector.getGlyphForAspect(.quadranovile)   == "\u{E890}")
        #expect(GlyphSelector.getGlyphForAspect(.vigintile)      == "\u{E820}")
        #expect(GlyphSelector.getGlyphForAspect(.undecile)       == "\u{E900}")
        #expect(GlyphSelector.getGlyphForAspect(.centile)        == "\u{E910}")
    }
}
