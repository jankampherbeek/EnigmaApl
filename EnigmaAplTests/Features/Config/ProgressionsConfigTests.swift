//
//  ProgressionsConfigTests.swift
//  EnigmaAplTests
//
//  Created by Jan Kampherbeek on 21/03/2026.
//

import Testing
@testable import EnigmaApl

struct ProgressionsConfigTests {

    @Test("ProgressionsConfig: default initialization contains all sub-configs")
    func testDefaultInitialization() {
        let config = ProgressionsConfig()
        #expect(config.primaryDirections.method == .placidus)
        #expect(config.transits.orb == 1.0)
        #expect(config.secondaryDirections.orb == 1.0)
        #expect(config.symbolicDirections.timeKey == .oneDegree)
        #expect(config.solarReturn.method == .tropicalParallax)
    }

    @Test("ProgressionsConfig: custom sub-configs are stored correctly")
    func testCustomInit() {
        let config = ProgressionsConfig(
            primaryDirections: PrimaryDirectionsConfig(method: .regiomontanus),
            transits: TransitsConfig(orb: 2.0),
            secondaryDirections: SecondaryDirectionsConfig(orb: 0.5),
            symbolicDirections: SymbolicDirectionsConfig(timeKey: .trueSun),
            solarReturn: SolarReturnConfig(location: .relocateResidence)
        )
        #expect(config.primaryDirections.method == .regiomontanus)
        #expect(config.transits.orb == 2.0)
        #expect(config.secondaryDirections.orb == 0.5)
        #expect(config.symbolicDirections.timeKey == .trueSun)
        #expect(config.solarReturn.location == .relocateResidence)
    }

    @Test("ProgressionsConfig: encodes and decodes correctly")
    func testCodableRoundtrip() throws {
        let original = ProgressionsConfig()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ProgressionsConfig.self, from: data)
        #expect(decoded.primaryDirections.method == original.primaryDirections.method)
        #expect(decoded.transits.orb == original.transits.orb)
        #expect(decoded.secondaryDirections.orb == original.secondaryDirections.orb)
        #expect(decoded.symbolicDirections.timeKey == original.symbolicDirections.timeKey)
        #expect(decoded.solarReturn.method == original.solarReturn.method)
    }
}
