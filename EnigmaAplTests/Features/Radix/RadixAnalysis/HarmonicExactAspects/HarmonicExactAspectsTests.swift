// HarmonicExactAspectsTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct HarmonicExactAspectsTests {

    private let delta = 1e-8

    // MARK: - Finder

    @Test("HarmonicExactAspectsFinder: aspect with the smallest orb is returned")
    func testFinderSmallestOrb() {
        // Sun–Moon 92° (square, orb 2°), Moon–Mars 108° (trine, orb 12°), Sun–Mars 160° (opposition, orb 20°)
        let positions = [HarmonicPosition(factor: .sun, longitude: 0.0),
                         HarmonicPosition(factor: .moon, longitude: 92.0),
                         HarmonicPosition(factor: .mars, longitude: 200.0)]
        let result = HarmonicExactAspectsFinder.find(positions: positions,
                                                     aspects: [.square, .trine, .opposition], harmonic: 3)
        #expect(result.count == 1)
        #expect(result[0].factor1 == .sun)
        #expect(result[0].factor2 == .moon)
        #expect(result[0].aspect == .square)
        #expect(result[0].harmonic == 3)
        #expect(abs(result[0].orb - 2.0) < delta)
    }

    @Test("HarmonicExactAspectsFinder: all aspects with the same smallest orb are returned")
    func testFinderTies() {
        let positions = [HarmonicPosition(factor: .sun, longitude: 0.0),
                         HarmonicPosition(factor: .moon, longitude: 90.0),
                         HarmonicPosition(factor: .mars, longitude: 180.0)]
        let result = HarmonicExactAspectsFinder.find(positions: positions,
                                                     aspects: [.square, .opposition], harmonic: 2)
        #expect(result.count == 3)
        for item in result {
            #expect(abs(item.orb) < delta)
        }
    }

    @Test("HarmonicExactAspectsFinder: pairs with a fixed distance are skipped")
    func testFinderSkipsImplicitPairs() {
        // North and South Node are always in exact opposition; that pair must not be returned.
        let positions = [HarmonicPosition(factor: .northNode, longitude: 0.0),
                         HarmonicPosition(factor: .southNode, longitude: 180.0),
                         HarmonicPosition(factor: .sun, longitude: 95.0)]
        let result = HarmonicExactAspectsFinder.find(positions: positions,
                                                     aspects: [.opposition, .square], harmonic: 2)
        #expect(!result.isEmpty)
        for item in result {
            #expect(item.factor1 == .sun || item.factor2 == .sun)
            #expect(abs(item.orb - 5.0) < delta)
        }
    }

    @Test("HarmonicExactAspectsFinder: fewer than two positions gives no result")
    func testFinderSinglePosition() {
        let result = HarmonicExactAspectsFinder.find(positions: [HarmonicPosition(factor: .sun, longitude: 0.0)],
                                                     aspects: [.conjunction], harmonic: 2)
        #expect(result.isEmpty)
    }

    // MARK: - Orchestrator

    @Test("HarmonicExactAspectsOrchestrator: harmonics 2 up to and including the maximum are examined")
    func testOrchestratorHarmonicRange() {
        let chart = Self.makeChart([(.sun, 10.0), (.moon, 77.0), (.mars, 203.0)])
        let result = HarmonicExactAspectsOrchestrator.exactAspects(
            chart: chart, factorConfig: Self.factorConfig([.sun, .moon, .mars]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            includeAscendant: false, includeMc: false,
            aspectSelection: .major, maxHarmonic: 12
        )
        #expect(Set(result.map(\.harmonic)) == Set(2...12))
    }

    @Test("HarmonicExactAspectsOrchestrator: major aspects ignore the configured aspects")
    func testOrchestratorMajorAspects() {
        let chart = Self.makeChart([(.sun, 10.0), (.moon, 77.0), (.mars, 203.0)])
        let result = HarmonicExactAspectsOrchestrator.exactAspects(
            chart: chart, factorConfig: Self.factorConfig([.sun, .moon, .mars]),
            aspectConfig: Self.aspectConfig([.quintile]),
            includeAscendant: false, includeMc: false,
            aspectSelection: .major, maxHarmonic: 20
        )
        #expect(!result.isEmpty)
        for item in result {
            #expect(HarmonicAspectSelection.majorAspects.contains(item.aspect))
        }
    }

    @Test("HarmonicExactAspectsOrchestrator: configured selection only uses aspects that are in use")
    func testOrchestratorConfiguredAspects() {
        let chart = Self.makeChart([(.sun, 10.0), (.moon, 77.0), (.mars, 203.0)])
        let result = HarmonicExactAspectsOrchestrator.exactAspects(
            chart: chart, factorConfig: Self.factorConfig([.sun, .moon, .mars]),
            aspectConfig: Self.aspectConfig([.quintile]),
            includeAscendant: false, includeMc: false,
            aspectSelection: .configured, maxHarmonic: 6
        )
        #expect(!result.isEmpty)
        for item in result {
            #expect(item.aspect == .quintile)
        }
    }

    @Test("HarmonicExactAspectsOrchestrator: Ascendant is included or excluded by its flag")
    func testOrchestratorAscendantFlag() {
        let chart = Self.makeChart([(.sun, 10.0)], ascendant: 100.0)
        let with = HarmonicExactAspectsOrchestrator.exactAspects(
            chart: chart, factorConfig: Self.factorConfig([.sun]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            includeAscendant: true, includeMc: false,
            aspectSelection: .major, maxHarmonic: 4
        )
        #expect(with.count == 3)
        for item in with {
            #expect(item.factor1 == .ascendant || item.factor2 == .ascendant)
        }
        let without = HarmonicExactAspectsOrchestrator.exactAspects(
            chart: chart, factorConfig: Self.factorConfig([.sun, .ascendant]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            includeAscendant: false, includeMc: false,
            aspectSelection: .major, maxHarmonic: 4
        )
        #expect(without.isEmpty)
    }

    @Test("HarmonicExactAspectsOrchestrator: maximum below 2 gives no result")
    func testOrchestratorMaxBelowMin() {
        let chart = Self.makeChart([(.sun, 10.0), (.moon, 77.0)])
        let result = HarmonicExactAspectsOrchestrator.exactAspects(
            chart: chart, factorConfig: Self.factorConfig([.sun, .moon]),
            aspectConfig: Self.aspectConfig([.conjunction]),
            includeAscendant: false, includeMc: false,
            aspectSelection: .major, maxHarmonic: 1
        )
        #expect(result.isEmpty)
    }

    // MARK: - Helpers

    private static func makeChart(_ pairs: [(Factors, Double)], ascendant: Double = 0) -> FullChart {
        let dummyCusp = FullCuspPosition(
            longitude: 0, rightAscension: 0, declination: 0,
            horizontal: HorizontalPosition(azimuth: 0, altitude: 0)
        )
        let ascCusp = FullCuspPosition(
            longitude: ascendant, rightAscension: 0, declination: 0,
            horizontal: HorizontalPosition(azimuth: 0, altitude: 0)
        )
        let houses = HousePositions(
            cusps: [], ascendant: ascCusp, midheaven: dummyCusp,
            eastpoint: dummyCusp, vertex: dummyCusp
        )
        var coords: [Factors: FullFactorPosition] = [:]
        for (factor, lon) in pairs {
            coords[factor] = FullFactorPosition(
                ecliptical: [MainAstronomicalPosition(mainPos: lon, deviation: 0, distance: 1)],
                equatorial: [],
                horizontal: []
            )
        }
        return FullChart(Coordinates: coords, HousePositions: houses,
                         SiderealTime: 0, JulianDay: 0, Obliquity: 23.5)
    }

    private static func factorConfig(_ factors: [Factors]) -> FactorConfig {
        FactorConfig(factorSettings: factors.map {
            FactorSettings(factor: $0, isUsed: true, isDrawn: false, orbPercentage: 100)
        })
    }

    private static func aspectConfig(_ aspects: [Aspects]) -> AspectConfig {
        AspectConfig(aspectSettings: aspects.map {
            AspectSettings(aspect: $0, isUsed: true, isDrawn: false, orbPercentage: 100)
        })
    }
}
