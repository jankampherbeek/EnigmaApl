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

    @Test("OrbConfig: default midpoint360DialOrb is 1.5 degrees (1°30')")
    func testDefaultMidpoint360DialOrb() {
        let config = OrbConfig()
        #expect(config.midpoint360DialOrb == 1.5)
    }

    @Test("OrbConfig: default midpoint90DialOrb is 1.0 degree (1°00')")
    func testDefaultMidpoint90DialOrb() {
        let config = OrbConfig()
        #expect(config.midpoint90DialOrb == 1.0)
    }

    @Test("OrbConfig: default midpoint45DialOrb is 0.5 degrees (0°30')")
    func testDefaultMidpoint45DialOrb() {
        let config = OrbConfig()
        #expect(config.midpoint45DialOrb == 0.5)
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
        let config = OrbConfig(orbSystem: .fixed, aspectBaseOrb: 8.0,
                               midpoint360DialOrb: 1.5, midpoint90DialOrb: 1.0,
                               midpoint45DialOrb: 0.5, harmonicOrb: 1.5, parallelOrb: 0.5)
        #expect(config.orbSystem == .fixed)
        #expect(config.aspectBaseOrb == 8.0)
        #expect(config.midpoint360DialOrb == 1.5)
        #expect(config.midpoint90DialOrb == 1.0)
        #expect(config.midpoint45DialOrb == 0.5)
        #expect(config.harmonicOrb == 1.5)
        #expect(config.parallelOrb == 0.5)
    }

    // MARK: - Codable

    @Test("OrbConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = OrbConfig(orbSystem: .harmonicBased, aspectBaseOrb: 10.0,
                                 midpoint360DialOrb: 1.5, midpoint90DialOrb: 1.0,
                                 midpoint45DialOrb: 0.5, harmonicOrb: 2.0, parallelOrb: 1.0)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(OrbConfig.self, from: data)
        #expect(decoded.orbSystem == original.orbSystem)
        #expect(decoded.aspectBaseOrb == original.aspectBaseOrb)
        #expect(decoded.midpoint360DialOrb == original.midpoint360DialOrb)
        #expect(decoded.midpoint90DialOrb == original.midpoint90DialOrb)
        #expect(decoded.midpoint45DialOrb == original.midpoint45DialOrb)
        #expect(decoded.harmonicOrb == original.harmonicOrb)
        #expect(decoded.parallelOrb == original.parallelOrb)
    }
}
