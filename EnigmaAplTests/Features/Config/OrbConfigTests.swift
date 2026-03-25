// OrbConfigTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct OrbConfigTests {

    // MARK: - Default initialization

    @Test("OrbConfig: default orbSystem is procentual")
    func testDefaultOrbSystem() {
        let config = OrbConfig()
        #expect(config.orbSystem == .procentual)
    }

    @Test("OrbConfig: default aspectBaseOrb is 10.0 degrees")
    func testDefaultAspectBaseOrb() {
        let config = OrbConfig()
        #expect(config.aspectBaseOrb == 10.0)
    }

    @Test("OrbConfig: default midpointOrb is 1.6 degrees (1°36')")
    func testDefaultMidpointOrb() {
        let config = OrbConfig()
        #expect(config.midpointOrb == 1.6)
    }

    @Test("OrbConfig: default harmonicOrb is 2.0 degrees")
    func testDefaultHarmonicOrb() {
        let config = OrbConfig()
        #expect(config.harmonicOrb == 2.0)
    }

    @Test("OrbConfig: default parallelOrb is 1.0 degree")
    func testDefaultParallelOrb() {
        let config = OrbConfig()
        #expect(config.parallelOrb == 1.0)
    }

    // MARK: - OrbSystem

    @Test("OrbSystem: all cases are accepted")
    func testAllOrbSystems() {
        for orbSystem in OrbSystem.allCases {
            let config = OrbConfig(orbSystem: orbSystem)
            #expect(config.orbSystem == orbSystem)
        }
    }

    @Test("OrbSystem: raw values are correct")
    func testOrbSystemRawValues() {
        #expect(OrbSystem.procentual.rawValue == 0)
        #expect(OrbSystem.fixed.rawValue == 1)
        #expect(OrbSystem.harmonicBased.rawValue == 2)
    }

    // MARK: - Custom initialization

    @Test("OrbConfig: custom values are stored correctly")
    func testCustomInit() {
        let config = OrbConfig(orbSystem: .fixed, aspectBaseOrb: 8.0, midpointOrb: 1.0,
                               harmonicOrb: 1.5, parallelOrb: 0.5)
        #expect(config.orbSystem == .fixed)
        #expect(config.aspectBaseOrb == 8.0)
        #expect(config.midpointOrb == 1.0)
        #expect(config.harmonicOrb == 1.5)
        #expect(config.parallelOrb == 0.5)
    }

    // MARK: - Codable

    @Test("OrbConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = OrbConfig(orbSystem: .harmonicBased, aspectBaseOrb: 10.0,
                                 midpointOrb: 1.6, harmonicOrb: 2.0, parallelOrb: 1.0)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(OrbConfig.self, from: data)
        #expect(decoded.orbSystem == original.orbSystem)
        #expect(decoded.aspectBaseOrb == original.aspectBaseOrb)
        #expect(decoded.midpointOrb == original.midpointOrb)
        #expect(decoded.harmonicOrb == original.harmonicOrb)
        #expect(decoded.parallelOrb == original.parallelOrb)
    }
}
