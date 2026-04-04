// DeclinationMidpointsMatchFinderTests.swift
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
///   Sun/Moon  = (20.0 + −10.0) / 2 =  +5.0°  → Mars (+5.0°) sits exactly on this midpoint
///   Sun/Mars  = (20.0 +   5.0) / 2 = +12.5°
///   Moon/Mars = (−10.0 +  5.0) / 2 =  −2.5°
struct DeclinationMidpointsMatchFinderTests {

    private let delta = 1e-10
    private let orb   = 1.0

    // MARK: - Shared helpers

    private static let basePositions: [(Factors, Double)] = [
        (.sun, 20.0), (.moon, -10.0), (.mars, 5.0)
    ]

    private static let baseMidpoints: [DeclBaseMidpoint] = [
        DeclBaseMidpoint(factor1: .sun,  factor2: .moon, position:  5.0),   // Sun/Moon
        DeclBaseMidpoint(factor1: .sun,  factor2: .mars, position: 12.5),   // Sun/Mars
        DeclBaseMidpoint(factor1: .moon, factor2: .mars, position: -2.5)    // Moon/Mars
    ]

    // MARK: - Exact occupation

    @Test("DeclinationMidpointsMatchFinder: exact occupation at orb 0")
    func testExactOccupation() {
        // Mars (+5.0°) sits exactly on midpoint Sun/Moon (+5.0°)
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: Self.baseMidpoints,
            positions: Self.basePositions,
            orb: orb)
        let match = results.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .mars
        }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.0) < delta)
        #expect(abs((match?.exactness ?? -1) - 100.0) < delta)
    }

    @Test("DeclinationMidpointsMatchFinder: occupyingPosition matches the input declination")
    func testOccupyingPositionIsInputDeclination() {
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: Self.baseMidpoints,
            positions: Self.basePositions,
            orb: orb)
        let match = results.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .mars
        }
        #expect(abs((match?.occupyingPosition ?? 99) - 5.0) < delta)
    }

    // MARK: - Orb handling

    @Test("DeclinationMidpointsMatchFinder: occupation within orb is found")
    func testOccupationWithinOrb() {
        // Saturn at +5.8°: deviation from midpoint +5.0° is 0.8° ≤ 1.0°
        let positions: [(Factors, Double)] = [(.sun, 20.0), (.moon, -10.0), (.saturn, 5.8)]
        let mids = [DeclBaseMidpoint(factor1: .sun, factor2: .moon, position: 5.0)]
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: mids, positions: positions, orb: orb)
        let match = results.first { $0.occupyingFactor == .saturn }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.8) < delta)
    }

    @Test("DeclinationMidpointsMatchFinder: occupation at exact orb boundary is included")
    func testExactOrbBoundaryIncluded() {
        // Saturn at +6.0°: deviation = 1.0° = orb → included
        let positions: [(Factors, Double)] = [(.sun, 20.0), (.moon, -10.0), (.saturn, 6.0)]
        let mids = [DeclBaseMidpoint(factor1: .sun, factor2: .moon, position: 5.0)]
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: mids, positions: positions, orb: orb)
        let match = results.first { $0.occupyingFactor == .saturn }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 1.0) < delta)
    }

    @Test("DeclinationMidpointsMatchFinder: occupation just outside orb is excluded")
    func testJustOutsideOrbExcluded() {
        // Saturn at +6.01°: deviation = 1.01° > 1.0° → excluded
        let positions: [(Factors, Double)] = [(.sun, 20.0), (.moon, -10.0), (.saturn, 6.01)]
        let mids = [DeclBaseMidpoint(factor1: .sun, factor2: .moon, position: 5.0)]
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: mids, positions: positions, orb: orb)
        let match = results.first { $0.occupyingFactor == .saturn }
        #expect(match == nil)
    }

    @Test("DeclinationMidpointsMatchFinder: zero orb only finds exact matches")
    func testZeroOrbOnlyExact() {
        // Saturn at +5.0001°: not considered exact with orb = 0
        let positions: [(Factors, Double)] = [(.sun, 20.0), (.moon, -10.0), (.saturn, 5.0001)]
        let mids = [DeclBaseMidpoint(factor1: .sun, factor2: .moon, position: 5.0)]
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: mids, positions: positions, orb: 0.0)
        let match = results.first { $0.occupyingFactor == .saturn }
        #expect(match == nil)
    }

    // MARK: - Exactness

    @Test("DeclinationMidpointsMatchFinder: exactness is 100 for exact occupation")
    func testExactnessHundredForExact() {
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: Self.baseMidpoints,
            positions: Self.basePositions,
            orb: orb)
        let match = results.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .mars
        }
        #expect(abs((match?.exactness ?? -1) - 100.0) < delta)
    }

    @Test("DeclinationMidpointsMatchFinder: exactness is 0 at orb boundary")
    func testExactnessZeroAtBoundary() {
        // deviation = orb → exactness = 100 − (orb/orb × 100) = 0
        let positions: [(Factors, Double)] = [(.sun, 20.0), (.moon, -10.0), (.saturn, 6.0)]
        let mids = [DeclBaseMidpoint(factor1: .sun, factor2: .moon, position: 5.0)]
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: mids, positions: positions, orb: orb)
        let match = results.first { $0.occupyingFactor == .saturn }
        #expect(abs((match?.exactness ?? -1) - 0.0) < delta)
    }

    @Test("DeclinationMidpointsMatchFinder: exactness is 50 at half orb")
    func testExactnessAtHalfOrb() {
        // deviation = 0.5°, orb = 1.0° → exactness = 100 − 50 = 50
        let positions: [(Factors, Double)] = [(.sun, 20.0), (.moon, -10.0), (.saturn, 5.5)]
        let mids = [DeclBaseMidpoint(factor1: .sun, factor2: .moon, position: 5.0)]
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: mids, positions: positions, orb: orb)
        let match = results.first { $0.occupyingFactor == .saturn }
        #expect(abs((match?.exactness ?? -1) - 50.0) < delta)
    }

    // MARK: - South declination midpoints

    @Test("DeclinationMidpointsMatchFinder: midpoint of two south declinations")
    func testSouthDeclination() {
        // Moon −10°, Mars −4° → midpoint −7.0°; Saturn at −7.0° → exact occupation
        let positions: [(Factors, Double)] = [(.moon, -10.0), (.mars, -4.0), (.saturn, -7.0)]
        let mids = [DeclBaseMidpoint(factor1: .moon, factor2: .mars, position: -7.0)]
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: mids, positions: positions, orb: orb)
        let match = results.first { $0.occupyingFactor == .saturn }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.0) < delta)
        #expect(abs((match?.midpoint.position ?? 99) - (-7.0)) < delta)
    }

    @Test("DeclinationMidpointsMatchFinder: midpoint crossing zero (north/south)")
    func testMidpointCrossingZero() {
        // Sun +20°, Moon −10° → midpoint +5.0°; checked above; test negative side too.
        // Moon −10°, Saturn +0° → midpoint −5.0°; Jupiter at −5.5° → deviation 0.5°
        let positions: [(Factors, Double)] = [(.moon, -10.0), (.saturn, 0.0), (.jupiter, -5.5)]
        let mids = [DeclBaseMidpoint(factor1: .moon, factor2: .saturn, position: -5.0)]
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: mids, positions: positions, orb: orb)
        let match = results.first { $0.occupyingFactor == .jupiter }
        #expect(match != nil)
        #expect(abs((match?.actualOrb ?? 99) - 0.5) < delta)
    }

    // MARK: - Sorting

    @Test("DeclinationMidpointsMatchFinder: results are sorted by actualOrb ascending")
    func testResultsSortedByOrb() {
        // Saturn at +5.3° (orb 0.3°), Jupiter at +5.7° (orb 0.7°) on midpoint +5.0°
        let positions: [(Factors, Double)] = [(.sun, 20.0), (.moon, -10.0),
                                              (.saturn, 5.3), (.jupiter, 5.7)]
        let mids = [DeclBaseMidpoint(factor1: .sun, factor2: .moon, position: 5.0)]
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: mids, positions: positions, orb: orb)
        #expect(results.count >= 2)
        for i in 0 ..< (results.count - 1) {
            #expect(results[i].actualOrb <= results[i + 1].actualOrb)
        }
    }

    // MARK: - Edge cases

    @Test("DeclinationMidpointsMatchFinder: empty baseMidpoints returns empty list")
    func testEmptyBaseMidpoints() {
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: [], positions: Self.basePositions, orb: orb)
        #expect(results.isEmpty)
    }

    @Test("DeclinationMidpointsMatchFinder: empty positions returns empty list")
    func testEmptyPositions() {
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: Self.baseMidpoints, positions: [], orb: orb)
        #expect(results.isEmpty)
    }

    @Test("DeclinationMidpointsMatchFinder: multiple midpoints all checked")
    func testMultipleMidpointsAllChecked() {
        // Saturn at +12.5° occupies midpoint Sun/Mars (+12.5°) exactly
        let positions: [(Factors, Double)] = [(.sun, 20.0), (.moon, -10.0),
                                              (.mars, 5.0), (.saturn, 12.5)]
        let results = DeclinationMidpointsMatchFinder.find(
            baseMidpoints: Self.baseMidpoints, positions: positions, orb: orb)
        let matchOnSunMoon = results.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .moon
            && $0.occupyingFactor == .mars
        }
        let matchOnSunMars = results.first {
            $0.midpoint.factor1 == .sun && $0.midpoint.factor2 == .mars
            && $0.occupyingFactor == .saturn
        }
        #expect(matchOnSunMoon != nil)
        #expect(matchOnSunMars != nil)
    }
}
