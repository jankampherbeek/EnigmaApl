//
//  PrimaryDirectionsConfigTests.swift
//  EnigmaAplTests
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Testing
@testable import EnigmaApl

struct PrimaryDirectionsConfigTests {

    // MARK: - Default initialization

    @Test("PrimaryDirectionsConfig: default values are correct")
    func testDefaultValues() {
        let config = PrimaryDirectionsConfig()
        #expect(config.method == .placidus)
        #expect(config.approach == .mundane)
        #expect(config.timeKey == .naibod)
        #expect(config.orb == 1.0)
    }

    @Test("PrimaryDirectionsConfig: default promissors are correct")
    func testDefaultPromissors() {
        let config = PrimaryDirectionsConfig()
        let expected: [Factors] = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn]
        #expect(config.promissors == expected)
    }

    @Test("PrimaryDirectionsConfig: default significators are correct")
    func testDefaultSignificators() {
        let config = PrimaryDirectionsConfig()
        let expected: [Factors] = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .mc, .ascendant]
        #expect(config.significators == expected)
    }

    // MARK: - Enums

    @Test("PrimaryMethod: all cases accepted")
    func testAllPrimaryMethods() {
        for method in PrimaryMethod.allCases {
            let config = PrimaryDirectionsConfig(method: method)
            #expect(config.method == method)
        }
    }

    @Test("PrimaryApproach: all cases accepted")
    func testAllPrimaryApproaches() {
        for approach in PrimaryApproach.allCases {
            let config = PrimaryDirectionsConfig(approach: approach)
            #expect(config.approach == approach)
        }
    }

    @Test("PrimaryTimeKey: all cases accepted")
    func testAllPrimaryTimeKeys() {
        for timeKey in PrimaryTimeKey.allCases {
            let config = PrimaryDirectionsConfig(timeKey: timeKey)
            #expect(config.timeKey == timeKey)
        }
    }

    @Test("PrimaryTimeKey: raw values are correct")
    func testPrimaryTimeKeyRawValues() {
        #expect(PrimaryTimeKey.placidus.rawValue == 0)
        #expect(PrimaryTimeKey.naibod.rawValue == 1)
        #expect(PrimaryTimeKey.brahe.rawValue == 2)
        #expect(PrimaryTimeKey.ptolemy.rawValue == 3)
        #expect(PrimaryTimeKey.vanDam.rawValue == 4)
    }

    // MARK: - Codable

    @Test("PrimaryDirectionsConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = PrimaryDirectionsConfig(
            promissors: [.sun, .moon],
            significators: [.ascendant, .mc],
            orb: 2.0,
            method: .regiomontanus,
            approach: .ecliptical,
            timeKey: .brahe
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PrimaryDirectionsConfig.self, from: data)
        #expect(decoded.promissors == original.promissors)
        #expect(decoded.significators == original.significators)
        #expect(decoded.orb == original.orb)
        #expect(decoded.method == original.method)
        #expect(decoded.approach == original.approach)
        #expect(decoded.timeKey == original.timeKey)
    }
}
