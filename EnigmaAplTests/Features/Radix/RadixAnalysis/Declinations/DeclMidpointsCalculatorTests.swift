// DeclMidpointsCalculatorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

/// Test data:
///   Sun   declination  +20.0° (north)
///   Moon  declination  −10.0° (south)
///   Mars  declination   +5.0° (north)
///
/// Expected base midpoints:
///   Sun/Moon  = (20.0 + −10.0) / 2 =  +5.0°
///   Sun/Mars  = (20.0 +   5.0) / 2 = +12.5°
///   Moon/Mars = (−10.0 +  5.0) / 2 =  −2.5°
struct DeclMidpointsCalculatorTests {

    private let delta = 1e-10

    // MARK: - Shared helpers

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

    private static func makeConfig(factors: [Factors]) -> FactorConfig {
        let settings = factors.map { FactorSettings(factor: $0, isUsed: true, isDrawn: true) }
        return FactorConfig(factorSettings: settings)
    }

    // MARK: - baseMidpoints: positions

    @Test("DeclMidpointsCalculator.baseMidpoints: midpoint of two north declinations")
    func testMidpointTwoNorth() {
        // Sun +20°, Mars +5° → midpoint = +12.5°
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.mars, 5.0)])
        let config = Self.makeConfig(factors: [.sun, .mars])
        let result = DeclMidpointsCalculator.baseMidpoints(chart: chart, factorConfig: config)
        let mid = result.first { $0.factor1 == .sun && $0.factor2 == .mars }
        #expect(mid != nil)
        #expect(abs((mid?.position ?? 99) - 12.5) < delta)
    }

    @Test("DeclMidpointsCalculator.baseMidpoints: midpoint of north and south declination")
    func testMidpointNorthAndSouth() {
        // Sun +20°, Moon −10° → midpoint = +5.0°
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0)])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = DeclMidpointsCalculator.baseMidpoints(chart: chart, factorConfig: config)
        let mid = result.first { $0.factor1 == .sun && $0.factor2 == .moon }
        #expect(mid != nil)
        #expect(abs((mid?.position ?? 99) - 5.0) < delta)
    }

    @Test("DeclMidpointsCalculator.baseMidpoints: midpoint of two south declinations")
    func testMidpointTwoSouth() {
        // Moon −10°, Mars −4° → midpoint = −7.0°
        let chart  = Self.makeChart(declinations: [(.moon, -10.0), (.mars, -4.0)])
        let config = Self.makeConfig(factors: [.moon, .mars])
        let result = DeclMidpointsCalculator.baseMidpoints(chart: chart, factorConfig: config)
        let mid = result.first { $0.factor1 == .moon && $0.factor2 == .mars }
        #expect(mid != nil)
        #expect(abs((mid?.position ?? 99) - (-7.0)) < delta)
    }

    // MARK: - baseMidpoints: count

    @Test("DeclMidpointsCalculator.baseMidpoints: n factors produce n*(n-1)/2 midpoints")
    func testBaseMidpointCount() {
        // 4 factors → 4*3/2 = 6 base midpoints
        let chart  = Self.makeChart(declinations: [(.sun, 0.0), (.moon, 4.0),
                                                   (.mars, 8.0), (.jupiter, 12.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars, .jupiter])
        let result = DeclMidpointsCalculator.baseMidpoints(chart: chart, factorConfig: config)
        #expect(result.count == 6)
    }

    @Test("DeclMidpointsCalculator.baseMidpoints: 3 factors produce 3 midpoints")
    func testThreeFactorsProduceThreeMidpoints() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.mars, 5.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars])
        let result = DeclMidpointsCalculator.baseMidpoints(chart: chart, factorConfig: config)
        #expect(result.count == 3)
    }

    // MARK: - baseMidpoints: edge cases

    @Test("DeclMidpointsCalculator.baseMidpoints: empty chart returns empty list")
    func testEmptyChartReturnsEmpty() {
        let chart  = Self.makeChart(declinations: [])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = DeclMidpointsCalculator.baseMidpoints(chart: chart, factorConfig: config)
        #expect(result.isEmpty)
    }

    @Test("DeclMidpointsCalculator.baseMidpoints: single active factor returns empty list")
    func testSingleFactorReturnsEmpty() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0)])
        let config = Self.makeConfig(factors: [.sun])
        let result = DeclMidpointsCalculator.baseMidpoints(chart: chart, factorConfig: config)
        #expect(result.isEmpty)
    }

    // MARK: - baseMidpoints: FactorConfig filtering

    @Test("DeclMidpointsCalculator.baseMidpoints: ignores factors not marked isUsed")
    func testIgnoresInactiveFactors() {
        // Chart has Sun, Moon, Mars. Config marks only Sun and Moon as used.
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.mars, 5.0)])
        let config = Self.makeConfig(factors: [.sun, .moon])   // Mars excluded
        let result = DeclMidpointsCalculator.baseMidpoints(chart: chart, factorConfig: config)
        // Only Sun/Moon midpoint expected
        #expect(result.count == 1)
        let marsMid = result.first { $0.factor1 == .mars || $0.factor2 == .mars }
        #expect(marsMid == nil)
    }

    @Test("DeclMidpointsCalculator.baseMidpoints: ignores factors absent from chart")
    func testIgnoresFactorsAbsentFromChart() {
        // Config asks for Sun, Moon, Jupiter but chart has no Jupiter.
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .jupiter])
        let result = DeclMidpointsCalculator.baseMidpoints(chart: chart, factorConfig: config)
        // Only Sun/Moon midpoint; Jupiter absent from chart → skipped
        #expect(result.count == 1)
    }

    // MARK: - activePairs

    @Test("DeclMidpointsCalculator.activePairs: returns declination for each active factor in chart")
    func testActivePairsReturnsCorrectDeclinations() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.mars, 5.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars])
        let pairs  = DeclMidpointsCalculator.activePairs(chart: chart, factorConfig: config)
        #expect(pairs.count == 3)
        let sunDecl = pairs.first { $0.0 == .sun }?.1
        #expect(abs((sunDecl ?? 99) - 20.0) < delta)
        let moonDecl = pairs.first { $0.0 == .moon }?.1
        #expect(abs((moonDecl ?? 99) - (-10.0)) < delta)
    }

    @Test("DeclMidpointsCalculator.activePairs: excludes inactive factors")
    func testActivePairsExcludesInactive() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.mars, 5.0)])
        let config = Self.makeConfig(factors: [.sun, .moon])   // Mars inactive
        let pairs  = DeclMidpointsCalculator.activePairs(chart: chart, factorConfig: config)
        #expect(pairs.count == 2)
        #expect(pairs.first { $0.0 == .mars } == nil)
    }

    @Test("DeclMidpointsCalculator.activePairs: empty chart returns empty list")
    func testActivePairsEmptyChart() {
        let chart  = Self.makeChart(declinations: [])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let pairs  = DeclMidpointsCalculator.activePairs(chart: chart, factorConfig: config)
        #expect(pairs.isEmpty)
    }
}
