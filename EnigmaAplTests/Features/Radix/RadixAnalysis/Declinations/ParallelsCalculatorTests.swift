// ParallelsCalculatorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

/// Test data:
///   Sun    declination  +20.0° (north)
///   Moon   declination  +20.5° (north)  → parallel with Sun, orb 0.5°
///   Mars   declination  -20.0° (south)  → contra-parallel with Sun, orb 0.0°
///   Saturn declination  +10.0° (north)  → no parallel with any (nearest: Moon, 10.5°)
struct ParallelsCalculatorTests {

    private let delta = 1e-10

    // MARK: - Shared helpers

    /// Build a minimal `FullFactorPosition` with the supplied equatorial declination.
    private static func makePos(declination: Double) -> FullFactorPosition {
        FullFactorPosition(
            ecliptical: [MainAstronomicalPosition(mainPos: 0, deviation: 0, distance: 1)],
            equatorial: [MainAstronomicalPosition(mainPos: 0, deviation: declination, distance: 1)],
            horizontal: [HorizontalPosition(azimuth: 0, altitude: 0)]
        )
    }

    private static func makeChart(declinations: [(Factors, Double)]) -> FullChart {
        let coords = Dictionary(uniqueKeysWithValues: declinations.map { ($0.0, makePos(declination: $0.1)) })
        let cusp   = FullCuspPosition(longitude: 0, rightAscension: 0, declination: 0,
                                      horizontal: HorizontalPosition(azimuth: 0, altitude: 0))
        let houses = HousePositions(cusps: Array(repeating: cusp, count: 13),
                                    ascendant: cusp, midheaven: cusp,
                                    eastpoint: cusp, vertex: cusp)
        return FullChart(Coordinates: coords, HousePositions: houses,
                         SiderealTime: 0, JulianDay: 0, Obliquity: 23.45)
    }

    /// FactorConfig with exactly the supplied factors marked `isUsed = true`.
    private static func makeConfig(factors: [Factors]) -> FactorConfig {
        let settings = factors.map { FactorSettings(factor: $0, isUsed: true, isDrawn: true) }
        return FactorConfig(factorSettings: settings)
    }

    private static func makeOrb(_ orb: Double) -> OrbConfig {
        OrbConfig(parallelOrb: orb)
    }

    // MARK: - Happy flow: parallel found

    @Test("ParallelsCalculator: finds parallel between two north factors within orb")
    func testParallelNorthNorthWithinOrb() {
        // Sun +20.0°, Moon +20.5° → orb = 0.5°; maxOrb = 1.0°
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, 20.5)])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(1.0))
        #expect(result.count == 1)
        #expect(result[0].factor1 == .sun)
        #expect(result[0].factor2 == .moon)
        #expect(result[0].isContraParallel == false)
        #expect(abs(result[0].actualOrb - 0.5) < delta)
        #expect(abs(result[0].maxOrb - 1.0) < delta)
    }

    @Test("ParallelsCalculator: finds parallel between two south factors within orb")
    func testParallelSouthSouthWithinOrb() {
        // Sun −18.0°, Moon −18.3° → orb = 0.3°; both south → parallel, not contra
        let chart  = Self.makeChart(declinations: [(.sun, -18.0), (.moon, -18.3)])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(1.0))
        #expect(result.count == 1)
        #expect(result[0].isContraParallel == false)
        #expect(abs(result[0].actualOrb - 0.3) < delta)
    }

    // MARK: - Happy flow: contra-parallel found

    @Test("ParallelsCalculator: finds contra-parallel between north and south factors")
    func testContraParallelNorthSouth() {
        // Sun +20.0°, Mars −20.0° → orb = 0.0°; opposite sides → contra-parallel
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.mars, -20.0)])
        let config = Self.makeConfig(factors: [.sun, .mars])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(1.0))
        #expect(result.count == 1)
        #expect(result[0].isContraParallel == true)
        #expect(abs(result[0].actualOrb - 0.0) < delta)
    }

    @Test("ParallelsCalculator: finds contra-parallel within orb")
    func testContraParallelWithinOrb() {
        // Sun +20.0°, Mars −20.8° → |20.0 − 20.8| = 0.8°; maxOrb = 1.0°
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.mars, -20.8)])
        let config = Self.makeConfig(factors: [.sun, .mars])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(1.0))
        #expect(result.count == 1)
        #expect(result[0].isContraParallel == true)
        #expect(abs(result[0].actualOrb - 0.8) < delta)
    }

    // MARK: - Orb boundary

    @Test("ParallelsCalculator: exact orb boundary is included")
    func testExactOrbBoundaryIsIncluded() {
        // orb = |20.0 − 21.0| = 1.0°; maxOrb = 1.0° → included (≤)
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, 21.0)])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(1.0))
        #expect(result.count == 1)
        #expect(abs(result[0].actualOrb - 1.0) < delta)
    }

    @Test("ParallelsCalculator: pair just outside orb is excluded")
    func testJustOutsideOrbExcluded() {
        // orb = 1.01°; maxOrb = 1.0° → excluded
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, 21.01)])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(1.0))
        #expect(result.isEmpty)
    }

    // MARK: - Multiple results

    @Test("ParallelsCalculator: finds multiple parallels in one chart")
    func testMultipleParallels() {
        // Sun +20.0°, Moon +20.5° (parallel, orb 0.5°)
        // Mars −20.0° (contra-parallel with Sun, orb 0.0°; contra-parallel with Moon, orb 0.5°)
        // Saturn +10.0° — too far from all others (nearest diff = 10°)
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, 20.5),
                                                   (.mars, -20.0), (.saturn, 10.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars, .saturn])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(1.0))
        // Expected: Sun/Moon parallel, Sun/Mars contra, Moon/Mars contra = 3 results
        #expect(result.count == 3)
    }

    @Test("ParallelsCalculator: correct types for mixed parallel/contra-parallel set")
    func testMixedTypes() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, 20.5), (.mars, -20.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(1.0))
        let parallel      = result.filter { !$0.isContraParallel }
        let contraParallel = result.filter {  $0.isContraParallel }
        #expect(parallel.count == 1)
        #expect(contraParallel.count == 2)
    }

    // MARK: - FactorConfig filtering

    @Test("ParallelsCalculator: ignores factors not in config")
    func testIgnoresFactorsNotInConfig() {
        // Chart has Sun and Moon, but config only marks Sun as used → no pairs → empty
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, 20.5)])
        let config = Self.makeConfig(factors: [.sun])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(1.0))
        #expect(result.isEmpty)
    }

    @Test("ParallelsCalculator: ignores factors absent from chart coordinates")
    func testIgnoresFactorsAbsentFromChart() {
        // Config marks Sun and Jupiter as used, but chart only has Sun → no pair
        let chart  = Self.makeChart(declinations: [(.sun, 20.0)])
        let config = Self.makeConfig(factors: [.sun, .jupiter])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(1.0))
        #expect(result.isEmpty)
    }

    // MARK: - Edge cases

    @Test("ParallelsCalculator: empty chart returns empty list")
    func testEmptyChart() {
        let chart  = Self.makeChart(declinations: [])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(1.0))
        #expect(result.isEmpty)
    }

    @Test("ParallelsCalculator: single factor returns empty list")
    func testSingleFactor() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0)])
        let config = Self.makeConfig(factors: [.sun])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(1.0))
        #expect(result.isEmpty)
    }

    @Test("ParallelsCalculator: zero orb only finds exact matches")
    func testZeroOrbOnlyExact() {
        // Sun +20.0°, Moon +20.0001° → orb = 0.0001°; with maxOrb=0.0 → excluded
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, 20.0001)])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(0.0))
        #expect(result.isEmpty)
    }

    @Test("ParallelsCalculator: zero orb finds exact parallel")
    func testZeroOrbFindsExact() {
        // Sun +20.0°, Moon +20.0° → orb = 0.0°; maxOrb = 0.0° → included
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, 20.0)])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(0.0))
        #expect(result.count == 1)
        #expect(abs(result[0].actualOrb - 0.0) < delta)
    }

    @Test("ParallelsCalculator: each pair is counted once (no duplicates)")
    func testNoDuplicatePairs() {
        // Three factors: exactly n*(n-1)/2 = 3 pairs.
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, 20.3), (.mercury, 19.8)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mercury])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(5.0))
        // All three pairs are within orb; each appears once.
        let pairs = result.map { Set([$0.factor1, $0.factor2]) }
        let uniquePairs = Set(pairs.map { $0.sorted { $0.rawValue < $1.rawValue }.map(\.rawValue) })
        #expect(result.count == 3)
        #expect(uniquePairs.count == 3)
    }

    @Test("ParallelsCalculator: maxOrb in result equals configured parallelOrb")
    func testMaxOrbMatchesConfig() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, 20.4)])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = ParallelsCalculator.parallels(chart: chart, factorConfig: config,
                                                   orbConfig: Self.makeOrb(2.5))
        #expect(result.count == 1)
        #expect(abs(result[0].maxOrb - 2.5) < delta)
    }
}
