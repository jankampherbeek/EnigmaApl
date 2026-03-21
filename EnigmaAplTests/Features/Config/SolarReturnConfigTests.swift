//
//  SolarReturnConfigTests.swift
//  EnigmaAplTests
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Testing
import Foundation
@testable import EnigmaApl

struct SolarReturnConfigTests {

    @Test("SolarReturnConfig: default values are correct")
    func testDefaultValues() {
        let config = SolarReturnConfig()
        #expect(config.orb == 1.0)
        #expect(config.method == .tropicalParallax)
        #expect(config.location == .birth)
    }

    @Test("SolarMethod: all cases accepted")
    func testAllSolarMethods() {
        for method in SolarMethod.allCases {
            let config = SolarReturnConfig(method: method)
            #expect(config.method == method)
        }
    }

    @Test("SolarMethod: raw values are correct")
    func testSolarMethodRawValues() {
        #expect(SolarMethod.tropicalParallax.rawValue == 0)
        #expect(SolarMethod.tropicalNoParallax.rawValue == 1)
        #expect(SolarMethod.siderealParallax.rawValue == 2)
        #expect(SolarMethod.siderealNoParallax.rawValue == 3)
    }

    @Test("SolarLocation: all cases accepted")
    func testAllSolarLocations() {
        for location in SolarLocation.allCases {
            let config = SolarReturnConfig(location: location)
            #expect(config.location == location)
        }
    }

    @Test("SolarLocation: raw values are correct")
    func testSolarLocationRawValues() {
        #expect(SolarLocation.birth.rawValue == 0)
        #expect(SolarLocation.relocateBirthDay.rawValue == 1)
        #expect(SolarLocation.relocateResidence.rawValue == 2)
    }

    @Test("SolarReturnConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = SolarReturnConfig(orb: 2.0, method: .siderealParallax, location: .relocateResidence)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SolarReturnConfig.self, from: data)
        #expect(decoded.orb == original.orb)
        #expect(decoded.method == original.method)
        #expect(decoded.location == original.location)
    }
}
