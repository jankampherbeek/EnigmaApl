// SecondaryDirectionsConfigTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct SecondaryDirectionsConfigTests {

    @Test("SecondaryDirectionsConfig: default orb is 1.0")
    func testDefaultOrb() {
        #expect(SecondaryDirectionsConfig().orb == 1.0)
    }

    @Test("SecondaryDirectionsConfig: default factors are correct")
    func testDefaultFactors() {
        let config = SecondaryDirectionsConfig()
        let expected: [Factors] = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .northNode]
        #expect(config.factors == expected)
    }

    @Test("SecondaryDirectionsConfig: custom values are stored correctly")
    func testCustomInit() {
        let config = SecondaryDirectionsConfig(factors: [.sun, .moon], orb: 2.0)
        #expect(config.factors == [.sun, .moon])
        #expect(config.orb == 2.0)
    }

    @Test("SecondaryDirectionsConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = SecondaryDirectionsConfig(factors: [.saturn, .northNode], orb: 0.5)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SecondaryDirectionsConfig.self, from: data)
        #expect(decoded.factors == original.factors)
        #expect(decoded.orb == original.orb)
    }
}
