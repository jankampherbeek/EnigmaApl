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
/// Base midpoints:
///   Sun/Moon  = (20.0 + −10.0) / 2 =  +5.0°   → Mars (+5.0°) occupies exactly (orb 0.0°)
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

    private static func makeOrb(_ orb: Double) -> OrbConfig {
        OrbConfig(midpoint360DialOrb: orb)
    }

    // MARK: - Base midpoint positions

    @Test("DeclMidpointsCalculator: midpoint of two north declinations")
    func testMidpointTwoNorth() {
        // Sun +20°, Mars +5° → midpoint = +12.5°
        // Saturn at +12.5° → exact occupation
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.mars, 5.0), (.saturn, 12.5)])
        let config = Self.makeConfig(factors: [.sun, .mars, .saturn])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        let match = result.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .mars
            && $0.occupyingFactor == .saturn
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.0) < delta)
        #expect(abs((match?.midpoint.position ?? 99) - 12.5) < delta)
    }

    @Test("DeclMidpointsCalculator: midpoint of north and south declination")
    func testMidpointNorthAndSouth() {
        // Sun +20°, Moon −10° → midpoint = +5.0°
        // Mars at +5.0° → exact occupation
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.mars, 5.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        let match = result.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .mars
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.0) < delta)
        #expect(abs((match?.midpoint.position ?? 99) - 5.0) < delta)
    }

    @Test("DeclMidpointsCalculator: midpoint of two south declinations")
    func testMidpointTwoSouth() {
        // Moon −10°, Mars −4° → midpoint = −7.0°
        // Saturn at −7.0° → exact occupation
        let chart  = Self.makeChart(declinations: [(.moon, -10.0), (.mars, -4.0), (.saturn, -7.0)])
        let config = Self.makeConfig(factors: [.moon, .mars, .saturn])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        let match = result.first {
            $0.midpoint.factor1 == .moon && $0.midpoint.factor2 == .mars
            && $0.occupyingFactor == .saturn
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.0) < delta)
        #expect(abs((match?.midpoint.position ?? 99) - (-7.0)) < delta)
    }

    // MARK: - Orb handling

    @Test("DeclMidpointsCalculator: occupation within orb is found")
    func testOccupationWithinOrb() {
        // Sun/Moon midpoint = +5.0°; Saturn at +5.8° → deviation 0.8° ≤ 1.0°
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.saturn, 5.8)])
        let config = Self.makeConfig(factors: [.sun, .moon, .saturn])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        let match = result.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .saturn
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.8) < delta)
    }

    @Test("DeclMidpointsCalculator: exact orb boundary is included")
    func testExactOrbBoundaryIncluded() {
        // Sun/Moon midpoint = +5.0°; Saturn at +6.0° → deviation 1.0° = orb → included
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.saturn, 6.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .saturn])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        let match = result.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .saturn
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 1.0) < delta)
    }

    @Test("DeclMidpointsCalculator: occupation just outside orb is excluded")
    func testJustOutsideOrbExcluded() {
        // Sun/Moon midpoint = +5.0°; Saturn at +6.01° → deviation 1.01° > 1.0° → excluded
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.saturn, 6.01)])
        let config = Self.makeConfig(factors: [.sun, .moon, .saturn])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        let match = result.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .saturn
        }
        #expect(match == nil)
    }

    // MARK: - Exactness

    @Test("DeclMidpointsCalculator: exactness is 100 for exact occupation")
    func testExactnessHundredForExact() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.mars, 5.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        let match = result.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .mars
        }
        #expect(abs((match?.exactness ?? -1) - 100.0) < delta)
    }

    @Test("DeclMidpointsCalculator: exactness is 0 at orb boundary")
    func testExactnessZeroAtBoundary() {
        // deviation = orb → exactness = 100 − (orb/orb × 100) = 0
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.saturn, 6.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .saturn])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        let match = result.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .saturn
        }
        #expect(abs((match?.exactness ?? -1) - 0.0) < delta)
    }

    @Test("DeclMidpointsCalculator: exactness is 50 at half orb")
    func testExactnessAtHalfOrb() {
        // deviation = 0.5°, orb = 1.0° → exactness = 100 − 50 = 50
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.saturn, 5.5)])
        let config = Self.makeConfig(factors: [.sun, .moon, .saturn])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        let match = result.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .saturn
        }
        #expect(abs((match?.exactness ?? -1) - 50.0) < delta)
    }

    // MARK: - Sorting

    @Test("DeclMidpointsCalculator: results are sorted by actualOrb ascending")
    func testResultsSortedByOrb() {
        // Sun/Moon midpoint = +5.0°
        // Saturn at +5.3° (orb 0.3°), Jupiter at +5.7° (orb 0.7°) → Saturn first
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0),
                                                   (.saturn, 5.3), (.jupiter, 5.7)])
        let config = Self.makeConfig(factors: [.sun, .moon, .saturn, .jupiter])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        for i in 0 ..< (result.count - 1) {
            #expect(result[i].actualOrb <= result[i + 1].actualOrb)
        }
    }

    // MARK: - FactorConfig filtering

    @Test("DeclMidpointsCalculator: ignores factors not marked isUsed")
    func testIgnoresInactiveFactors() {
        // Chart has Sun, Moon, Mars. Config marks only Sun and Moon as used.
        // Sun/Moon midpoint = +5.0°; Mars at +5.0° but inactive → no occupation by Mars.
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.mars, 5.0)])
        let config = Self.makeConfig(factors: [.sun, .moon])   // Mars excluded
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        let marsMatch = result.first { $0.occupyingFactor == .mars }
        #expect(marsMatch == nil)
    }

    @Test("DeclMidpointsCalculator: ignores factors absent from chart")
    func testIgnoresFactorsAbsentFromChart() {
        // Config asks for Sun, Moon, Jupiter but chart has no Jupiter.
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .jupiter])
        // Should not crash and should still return Sun/Moon midpoints.
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        let jupiterMatch = result.first { $0.occupyingFactor == .jupiter }
        #expect(jupiterMatch == nil)
    }

    // MARK: - Edge cases

    @Test("DeclMidpointsCalculator: empty chart returns empty list")
    func testEmptyChartReturnsEmpty() {
        let chart  = Self.makeChart(declinations: [])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        #expect(result.isEmpty)
    }

    @Test("DeclMidpointsCalculator: single active factor returns empty list")
    func testSingleFactorReturnsEmpty() {
        let chart  = Self.makeChart(declinations: [(.sun, 20.0)])
        let config = Self.makeConfig(factors: [.sun])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        #expect(result.isEmpty)
    }

    @Test("DeclMidpointsCalculator: two active factors with no occupying third returns empty")
    func testTwoFactorsNoOccupation() {
        // Sun +20°, Moon −10° → midpoint +5°. No third factor.
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0)])
        let config = Self.makeConfig(factors: [.sun, .moon])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        // Sun and Moon are each other's only candidates; neither sits on the other's midpoint
        // (Sun at +20° vs midpoint +5°: deviation 15°; Moon at −10° vs midpoint +5°: deviation 15°)
        #expect(result.isEmpty)
    }

    @Test("DeclMidpointsCalculator: zero orb only finds exact matches")
    func testZeroOrbOnlyExact() {
        // Sun/Moon midpoint = +5.0°; Mars at +5.0001° → not exact with orb = 0
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.mars, 5.0001)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(0.0))
        let match = result.first { $0.occupyingFactor == .mars }
        #expect(match == nil)
    }

    @Test("DeclMidpointsCalculator: n factors produce n*(n-1)/2 base midpoints")
    func testBaseMidpointCount() {
        // 4 factors → 6 base midpoints; each tested against 4 factors → up to 24 entries.
        // With wide orb all self-occupations and near-occupations will be found.
        // We only check that the count is > 0 and ≤ 6*4 = 24.
        let chart  = Self.makeChart(declinations: [(.sun, 0.0), (.moon, 4.0),
                                                   (.mars, 8.0), (.jupiter, 12.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars, .jupiter])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(10.0))
        #expect(!result.isEmpty)
        #expect(result.count <= 24)
    }

    @Test("DeclMidpointsCalculator: occupyingPosition matches chart declination")
    func testOccupyingPositionIsChartDeclination() {
        // Mars at +5.0° occupies Sun/Moon midpoint (+5.0°); occupyingPosition must be +5.0°.
        let chart  = Self.makeChart(declinations: [(.sun, 20.0), (.moon, -10.0), (.mars, 5.0)])
        let config = Self.makeConfig(factors: [.sun, .moon, .mars])
        let result = DeclMidpointsCalculator.occupiedMidpoints(chart: chart,
                                                               factorConfig: config,
                                                               orbConfig: Self.makeOrb(1.0))
        let match = result.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .mars
        }
        #expect(abs((match?.occupyingPosition ?? 99) - 5.0) < delta)
    }
}
