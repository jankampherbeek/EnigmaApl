//
//  SymbolicDirectionsConfigTests.swift
//  EnigmaAplTests
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Testing
@testable import EnigmaApl

struct SymbolicDirectionsConfigTests {

    @Test("SymbolicDirectionsConfig: default values are correct")
    func testDefaultValues() {
        let config = SymbolicDirectionsConfig()
        #expect(config.orb == 1.0)
        #expect(config.timeKey == .oneDegree)
    }

    @Test("SymbolicDirectionsConfig: default factors are correct")
    func testDefaultFactors() {
        let config = SymbolicDirectionsConfig()
        let expected: [Factors] = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn,
                                    .uranus, .neptune, .pluto, .chiron, .northNode, .mc, .ascendant]
        #expect(config.factors == expected)
    }

    @Test("SymbolicTimeKey: all cases accepted")
    func testAllSymbolicTimeKeys() {
        for timeKey in SymbolicTimeKey.allCases {
            let config = SymbolicDirectionsConfig(timeKey: timeKey)
            #expect(config.timeKey == timeKey)
        }
    }

    @Test("SymbolicTimeKey: raw values are correct")
    func testSymbolicTimeKeyRawValues() {
        #expect(SymbolicTimeKey.oneDegree.rawValue == 0)
        #expect(SymbolicTimeKey.trueSun.rawValue == 1)
        #expect(SymbolicTimeKey.meanSun.rawValue == 2)
    }

    @Test("SymbolicDirectionsConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = SymbolicDirectionsConfig(factors: [.sun, .mc], orb: 2.0, timeKey: .trueSun)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SymbolicDirectionsConfig.self, from: data)
        #expect(decoded.factors == original.factors)
        #expect(decoded.orb == original.orb)
        #expect(decoded.timeKey == original.timeKey)
    }
}
