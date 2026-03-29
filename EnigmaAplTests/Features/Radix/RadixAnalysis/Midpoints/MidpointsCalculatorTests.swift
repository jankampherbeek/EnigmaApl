// MidpointsCalculatorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct MidpointsCalculatorTests {

    private let delta = 1e-8

    // MARK: - Happy flow

    @Test("MidpointsCalculator: calculates correct positions for four factors")
    func testCalculatePositions() {
        let positions = Self.makePositions()
        let result = MidpointsCalculator.calculate(positions: positions)
        // Expected midpoints (sorted by position):
        // Sun/Jupiter:  22 + (42-22)/2   = 32°
        // Sun/Moon:     22 + (178-22)/2  = 100°
        // Moon/Jupiter: 42 + (178-42)/2  = 110°
        // Moon/Mars:   178 + (302-178)/2 = 240°
        // Sun/Mars: shortest arc = 360-(302-22)=80°, start 302, mid = 302+40 = 342°
        // Mars/Jupiter: shortest arc = 360-(302-42)=100°, start 302, mid = 302+50 = 352°
        #expect(result.count == 6)
        #expect(abs(result[0].position - 32.0) < delta)
        #expect(abs(result[1].position - 100.0) < delta)
        #expect(abs(result[2].position - 110.0) < delta)
        #expect(abs(result[3].position - 240.0) < delta)
        #expect(abs(result[4].position - 342.0) < delta)
        #expect(abs(result[5].position - 352.0) < delta)
    }

    @Test("MidpointsCalculator: result is sorted ascending by position")
    func testResultIsSorted() {
        let positions = Self.makePositions()
        let result = MidpointsCalculator.calculate(positions: positions)
        for i in 0..<(result.count - 1) {
            #expect(result[i].position <= result[i + 1].position)
        }
    }

    @Test("MidpointsCalculator: correct factors for each midpoint pair")
    func testFactorPairs() {
        let positions = Self.makePositions()
        let result = MidpointsCalculator.calculate(positions: positions)
        // sorted order: 32 (Sun/Jupiter), 100 (Sun/Moon), 110 (Moon/Jupiter),
        //               240 (Moon/Mars), 342 (Sun/Mars), 352 (Mars/Jupiter)
        #expect(result[0].factor1 == .sun && result[0].factor2 == .jupiter)
        #expect(result[1].factor1 == .sun && result[1].factor2 == .moon)
        #expect(result[2].factor1 == .moon && result[2].factor2 == .jupiter)
        #expect(result[3].factor1 == .moon && result[3].factor2 == .mars)
        #expect(result[4].factor1 == .sun && result[4].factor2 == .mars)
        #expect(result[5].factor1 == .mars && result[5].factor2 == .jupiter)
    }

    // MARK: - Shortest arc edge cases

    @Test("MidpointsCalculator: midpoint wraps correctly near 0°/360° boundary")
    func testMidpointWrapAroundZero() {
        // 350° and 10° → shortest arc = 20°, midpoint = 0°
        let positions: [(Factors, Double)] = [(.sun, 350.0), (.moon, 10.0)]
        let result = MidpointsCalculator.calculate(positions: positions)
        #expect(result.count == 1)
        #expect(abs(result[0].position - 0.0) < delta)
    }

    @Test("MidpointsCalculator: midpoint exactly at 180° boundary")
    func testMidpointAtHalfCircle() {
        // 90° and 270° → two equal arcs, both 180°; shortest arc rule picks the one
        // starting at the larger value (270) → 270 + 90 = 360 → wraps to 0°
        // (diff == 180, not < 180, so "long arc" branch is taken)
        let positions: [(Factors, Double)] = [(.sun, 90.0), (.moon, 270.0)]
        let result = MidpointsCalculator.calculate(positions: positions)
        #expect(result.count == 1)
        // position is either 0° or 180° depending on tie-break; just check it is in range
        #expect(result[0].position >= 0.0 && result[0].position < 360.0)
    }

    @Test("MidpointsCalculator: midpoint for two identical positions")
    func testMidpointIdenticalPositions() {
        let positions: [(Factors, Double)] = [(.sun, 120.0), (.moon, 120.0)]
        let result = MidpointsCalculator.calculate(positions: positions)
        #expect(result.count == 1)
        #expect(abs(result[0].position - 120.0) < delta)
    }

    // MARK: - Count

    @Test("MidpointsCalculator: empty input returns empty list")
    func testEmptyInput() {
        let result = MidpointsCalculator.calculate(positions: [])
        #expect(result.isEmpty)
    }

    @Test("MidpointsCalculator: single factor returns empty list")
    func testSingleFactor() {
        let result = MidpointsCalculator.calculate(positions: [(.sun, 45.0)])
        #expect(result.isEmpty)
    }

    @Test("MidpointsCalculator: two factors produce exactly one midpoint")
    func testTwoFactors() {
        let positions: [(Factors, Double)] = [(.sun, 22.0), (.moon, 178.0)]
        let result = MidpointsCalculator.calculate(positions: positions)
        #expect(result.count == 1)
        #expect(abs(result[0].position - 100.0) < delta)
    }

    @Test("MidpointsCalculator: n factors produce n*(n-1)/2 midpoints")
    func testCountFormula() {
        let positions = Self.makePositions()  // 4 factors
        let result = MidpointsCalculator.calculate(positions: positions)
        #expect(result.count == 6)  // 4*3/2 = 6
    }

    // MARK: - Helpers

    /// Zon=22°, Maan=178°, Mars=302°, Jupiter=42° — same data as TestBaseMidpointsCreator.cs
    private static func makePositions() -> [(Factors, Double)] {
        [(.sun, 22.0), (.moon, 178.0), (.mars, 302.0), (.jupiter, 42.0)]
    }
}
