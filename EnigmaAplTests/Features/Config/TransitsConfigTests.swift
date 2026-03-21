//
//  TransitsConfigTests.swift
//  EnigmaAplTests
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Testing
@testable import EnigmaApl

struct TransitsConfigTests {

    @Test("TransitsConfig: default orb is 1.0")
    func testDefaultOrb() {
        #expect(TransitsConfig().orb == 1.0)
    }

    @Test("TransitsConfig: default factors are correct")
    func testDefaultFactors() {
        let config = TransitsConfig()
        let expected: [Factors] = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn,
                                    .uranus, .neptune, .pluto, .chiron, .northNode]
        #expect(config.factors == expected)
    }

    @Test("TransitsConfig: custom values are stored correctly")
    func testCustomInit() {
        let config = TransitsConfig(factors: [.sun, .moon], orb: 2.0)
        #expect(config.factors == [.sun, .moon])
        #expect(config.orb == 2.0)
    }

    @Test("TransitsConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = TransitsConfig(factors: [.mars, .jupiter], orb: 1.5)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TransitsConfig.self, from: data)
        #expect(decoded.factors == original.factors)
        #expect(decoded.orb == original.orb)
    }
}
