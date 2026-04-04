// DeclinationsOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

/// Test data (shared between parallel and midpoint tests):
///   Sun    declination  +20.0° (north)
///   Moon   declination  +20.5° (north)  → parallel with Sun, orb 0.5°
///   Mars   declination  -20.0° (south)  → contra-parallel with Sun, orb 0.0°
///   Saturn declination  +10.0° (north)  → no parallel/contra-parallel within 1° orb
///
/// Midpoints (Sun/Moon/Mars active):
///   Sun/Moon  = (20.0 + 20.5) / 2 = +20.25°
///   Sun/Mars  = (20.0 + −20.0) / 2 =  0.0°
///   Moon/Mars = (20.5 + −20.0) / 2 = +0.25°
///
/// Longitude equivalents (obliquity = 23.4367°):
///   Sun:  decl=0°,          long=5°   → equivalent ≈ 0°,   isOutOfBounds=false
///   Moon: decl=obliquity,   long=91°  → equivalent ≈ 90°,  isOutOfBounds=false
///   Mars: decl=30° (OOB),   long=60°  → isOutOfBounds=true
struct DeclinationsOrchestratorTests {

    private let delta      = 1e-10
    private let deltaCoord = 1e-3        // looser tolerance for trig-based equivalents
    private let obliquity  = 23.4367

    // MARK: - Shared helpers

    private static func makePos(declination: Double) -> FullFactorPosition {
        FullFactorPosition(
            ecliptical: [MainAstronomicalPosition(mainPos: 0, deviation: 0, distance: 1)],
            equatorial: [MainAstronomicalPosition(mainPos: 0, deviation: declination, distance: 1)],
            horizontal: [HorizontalPosition(azimuth: 0, altitude: 0)]
        )
    }

    /// Build a position with both ecliptic longitude and equatorial declination.
    private static func makePosLongDecl(longitude: Double, declination: Double) -> FullFactorPosition {
        FullFactorPosition(
            ecliptical: [MainAstronomicalPosition(mainPos: longitude, deviation: 0, distance: 1)],
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

    private static func makeChartLongDecl(factors: [(Factors, Double, Double)],
                                          obliquity: Double) -> FullChart {
        let coords = Dictionary(uniqueKeysWithValues: factors.map {
            ($0.0, makePosLongDecl(longitude: $0.1, declination: $0.2))
        })
        let cusp   = FullCuspPosition(longitude: 0, rightAscension: 0, declination: 0,
                                      horizontal: HorizontalPosition(azimuth: 0, altitude: 0))
        let houses = HousePositions(cusps: Array(repeating: cusp, count: 13),
                                    ascendant: cusp, midheaven: cusp,
                                    eastpoint: cusp, vertex: cusp)
        return FullChart(Coordinates: coords, HousePositions: houses,
                         SiderealTime: 0, JulianDay: 0, Obliquity: obliquity)
    }

    private static func makeConfig(factors: [Factors]) -> FactorConfig {
        let settings = factors.map { FactorSettings(factor: $0, isUsed: true, isDrawn: true) }
        return FactorConfig(factorSettings: settings)
    }

    private static func makeOrbParallel(_ orb: Double) -> OrbConfig {
        OrbConfig(parallelOrb: orb)
    }

    private static func makeOrbMidpoint(_ orb: Double) -> OrbConfig {
        OrbConfig(declinationMidpointOrb: orb)
    }

    // MARK: - parallels: delegation and basic results

    @Test("DeclinationsOrchestrator.parallels: returns same results as ParallelsCalculator")
    func testParallelsDelegatesCorrectly() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, 20.5), (.mars, -20.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars])
        let orbConfig = Self.makeOrbParallel(1.0)

        let direct = ParallelsCalculator.parallels(chart: chart, factorConfig: config, orbConfig: orbConfig)
        let via    = DeclinationsOrchestrator.parallels(chart: chart, factorConfig: config, orbConfig: orbConfig)

        #expect(via.count == direct.count)
        for (a, b) in zip(via.sorted { $0.actualOrb < $1.actualOrb },
                          direct.sorted { $0.actualOrb < $1.actualOrb }) {
            #expect(a.factor1 == b.factor1)
            #expect(a.factor2 == b.factor2)
            #expect(a.isContraParallel == b.isContraParallel)
            #expect(abs(a.actualOrb - b.actualOrb) < delta)
            #expect(abs(a.maxOrb - b.maxOrb) < delta)
        }
    }

    @Test("DeclinationsOrchestrator.parallels: finds parallel between two north factors")
    func testParallelsFindsParallel() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, 20.5)])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = DeclinationsOrchestrator.parallels(chart: chart,
                                                        factorConfig: config,
                                                        orbConfig: Self.makeOrbParallel(1.0))
        #expect(result.count == 1)
        #expect(result[0].isContraParallel == false)
        #expect(abs(result[0].actualOrb - 0.5) < delta)
    }

    @Test("DeclinationsOrchestrator.parallels: finds contra-parallel between north and south")
    func testParallelsFindsContraParallel() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.mars, -20.0)])
        let config = Self.makeConfig(factors: [.sun, .mars])
        let result = DeclinationsOrchestrator.parallels(chart: chart,
                                                        factorConfig: config,
                                                        orbConfig: Self.makeOrbParallel(1.0))
        #expect(result.count == 1)
        #expect(result[0].isContraParallel == true)
        #expect(abs(result[0].actualOrb - 0.0) < delta)
    }

    @Test("DeclinationsOrchestrator.parallels: excludes pairs outside orb")
    func testParallelsExcludesOutsideOrb() {
        // Saturn +10.0° is more than 1° from Sun +20.0° → no parallel
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.saturn, 10.0)])
        let config = Self.makeConfig(factors: [.sun, .saturn])
        let result = DeclinationsOrchestrator.parallels(chart: chart,
                                                        factorConfig: config,
                                                        orbConfig: Self.makeOrbParallel(1.0))
        #expect(result.isEmpty)
    }

    @Test("DeclinationsOrchestrator.parallels: empty chart returns empty list")
    func testParallelsEmptyChart() {
        let chart  = Self.makeChart(declinations: [])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = DeclinationsOrchestrator.parallels(chart: chart,
                                                        factorConfig: config,
                                                        orbConfig: Self.makeOrbParallel(1.0))
        #expect(result.isEmpty)
    }

    @Test("DeclinationsOrchestrator.parallels: single factor returns empty list")
    func testParallelsSingleFactor() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0)])
        let config = Self.makeConfig(factors: [.sun])
        let result = DeclinationsOrchestrator.parallels(chart: chart,
                                                        factorConfig: config,
                                                        orbConfig: Self.makeOrbParallel(1.0))
        #expect(result.isEmpty)
    }

    // MARK: - occupiedMidpoints: delegation and basic results

    @Test("DeclinationsOrchestrator.occupiedMidpoints: returns same results as DeclinationMidpointsMatchFinder")
    func testMidpointsDelegatesCorrectly() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.mars, 5.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars])
        let orbConfig = Self.makeOrbMidpoint(1.0)

        let baseMidpoints = DeclMidpointsCalculator.baseMidpoints(chart: chart, factorConfig: config)
        let positions     = DeclMidpointsCalculator.activePairs(chart: chart, factorConfig: config)
        let direct = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: baseMidpoints,
            positions: positions,
            orb: orbConfig.declinationMidpointOrb)
        let via = DeclinationsOrchestrator.occupiedMidpoints(chart: chart, factorConfig: config, orbConfig: orbConfig)

        #expect(via.count == direct.count)
        for (a, b) in zip(via, direct) {
            #expect(a.midpoint.factor1 == b.midpoint.factor1)
            #expect(a.midpoint.factor2 == b.midpoint.factor2)
            #expect(a.occupyingFactor == b.occupyingFactor)
            #expect(abs(a.actualOrb - b.actualOrb) < delta)
            #expect(abs(a.exactness - b.exactness) < delta)
        }
    }

    @Test("DeclinationsOrchestrator.occupiedMidpoints: finds exact occupation")
    func testMidpointsFindsExactOccupation() {
        // Sun +20°, Moon −10° → midpoint +5.0°; Mars at +5.0° → exact
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.mars, 5.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars])
        let result = DeclinationsOrchestrator.occupiedMidpoints(chart: chart,
                                                                factorConfig: config,
                                                                orbConfig: Self.makeOrbMidpoint(1.0))
        let match = result.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .mars
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.0) < delta)
        #expect(abs((match?.exactness ?? -1) - 100.0) < delta)
    }

    @Test("DeclinationsOrchestrator.occupiedMidpoints: excludes occupation outside orb")
    func testMidpointsExcludesOutsideOrb() {
        // Sun/Moon midpoint = +5.0°; Saturn at +6.5° → deviation 1.5° > 1.0° → excluded
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.saturn, 6.5)])
        let config = Self.makeConfig(factors: [.sun, .moon, .saturn])
        let result = DeclinationsOrchestrator.occupiedMidpoints(chart: chart,
                                                                factorConfig: config,
                                                                orbConfig: Self.makeOrbMidpoint(1.0))
        let match = result.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .saturn
        }
        #expect(match == nil)
    }

    @Test("DeclinationsOrchestrator.occupiedMidpoints: results are sorted by actualOrb ascending")
    func testMidpointsResultsSorted() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0),
                                                   (.saturn, 5.3), (.jupiter, 5.7)])
        let config = Self.makeConfig(factors: [.sun, .moon, .saturn, .jupiter])
        let result = DeclinationsOrchestrator.occupiedMidpoints(chart: chart,
                                                                factorConfig: config,
                                                                orbConfig: Self.makeOrbMidpoint(1.0))
        for i in 0 ..< (result.count - 1) {
            #expect(result[i].actualOrb <= result[i + 1].actualOrb)
        }
    }

    @Test("DeclinationsOrchestrator.occupiedMidpoints: empty chart returns empty list")
    func testMidpointsEmptyChart() {
        let chart  = Self.makeChart(declinations: [])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = DeclinationsOrchestrator.occupiedMidpoints(chart: chart,
                                                                factorConfig: config,
                                                                orbConfig: Self.makeOrbMidpoint(1.0))
        #expect(result.isEmpty)
    }

    @Test("DeclinationsOrchestrator.occupiedMidpoints: single factor returns empty list")
    func testMidpointsSingleFactor() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0)])
        let config = Self.makeConfig(factors: [.sun])
        let result = DeclinationsOrchestrator.occupiedMidpoints(chart: chart,
                                                                factorConfig: config,
                                                                orbConfig: Self.makeOrbMidpoint(1.0))
        #expect(result.isEmpty)
    }

    // MARK: - longitudeEquivalents: delegation and basic results

    @Test("DeclinationsOrchestrator.longitudeEquivalents: returns same results as LongEquivalentsCalculator")
    func testEquivalentsDelegatesCorrectly() {
        let chart  = Self.makeChartLongDecl(factors: [(.sun, 5.0, 0.0),
                                                      (.moon, 91.0, obliquity)],
                                            obliquity: obliquity)
        let config = Self.makeConfig(factors: [.sun, .moon])

        let direct = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        let via    = DeclinationsOrchestrator.longitudeEquivalents(chart: chart, factorConfig: config)

        #expect(via.count == direct.count)
        for (a, b) in zip(via.sorted { $0.factor.rawValue < $1.factor.rawValue },
                          direct.sorted { $0.factor.rawValue < $1.factor.rawValue }) {
            #expect(a.factor == b.factor)
            #expect(abs(a.longitudeEquivalent - b.longitudeEquivalent) < deltaCoord)
            #expect(a.isOutOfBounds == b.isOutOfBounds)
        }
    }

    @Test("DeclinationsOrchestrator.longitudeEquivalents: zero declination gives equivalent near 0°")
    func testEquivalentsZeroDecl() {
        // Sun: decl=0°, long=5° → candidate1=0°, is closest
        let chart  = Self.makeChartLongDecl(factors: [(.sun, 5.0, 0.0)], obliquity: obliquity)
        let config = Self.makeConfig(factors: [.sun])
        let result = DeclinationsOrchestrator.longitudeEquivalents(chart: chart, factorConfig: config)
        #expect(result.count == 1)
        #expect(abs(result[0].longitudeEquivalent - 0.0) < deltaCoord)
        #expect(result[0].isOutOfBounds == false)
    }

    @Test("DeclinationsOrchestrator.longitudeEquivalents: declination equal to obliquity gives ~90°")
    func testEquivalentsDeclEqualsObliquity() {
        // Moon: decl=obliquity, long=91° → equivalent ≈ 90°
        let chart  = Self.makeChartLongDecl(factors: [(.moon, 91.0, obliquity)], obliquity: obliquity)
        let config = Self.makeConfig(factors: [.moon])
        let result = DeclinationsOrchestrator.longitudeEquivalents(chart: chart, factorConfig: config)
        #expect(result.count == 1)
        #expect(abs(result[0].longitudeEquivalent - 90.0) < deltaCoord)
        #expect(result[0].isOutOfBounds == false)
    }

    @Test("DeclinationsOrchestrator.longitudeEquivalents: OOB declination sets isOutOfBounds")
    func testEquivalentsOobFlag() {
        // Mars: decl=30° > obliquity(23.4367°) → OOB
        let chart  = Self.makeChartLongDecl(factors: [(.mars, 60.0, 30.0)], obliquity: obliquity)
        let config = Self.makeConfig(factors: [.mars])
        let result = DeclinationsOrchestrator.longitudeEquivalents(chart: chart, factorConfig: config)
        #expect(result.count == 1)
        #expect(result[0].isOutOfBounds == true)
    }

    @Test("DeclinationsOrchestrator.longitudeEquivalents: inactive factor is excluded")
    func testEquivalentsInactiveExcluded() {
        let chart  = Self.makeChartLongDecl(factors: [(.sun, 5.0, 0.0), (.moon, 91.0, obliquity)],
                                            obliquity: obliquity)
        let config = Self.makeConfig(factors: [.sun])   // Moon excluded
        let result = DeclinationsOrchestrator.longitudeEquivalents(chart: chart, factorConfig: config)
        #expect(result.count == 1)
        #expect(result[0].factor == .sun)
    }

    @Test("DeclinationsOrchestrator.longitudeEquivalents: empty chart returns empty list")
    func testEquivalentsEmptyChart() {
        let chart  = Self.makeChartLongDecl(factors: [], obliquity: obliquity)
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = DeclinationsOrchestrator.longitudeEquivalents(chart: chart, factorConfig: config)
        #expect(result.isEmpty)
    }
}
