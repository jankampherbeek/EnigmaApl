// HarmonicsMatchFinderTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct HarmonicsMatchFinderTests {

    private let delta = 1e-8
    private let orb = 2.0

    // MARK: - Happy flow

    @Test("HarmonicsMatchFinder: finds exact match")
    func testExactMatch() {
        // Harmonic Sun at 100°, radix Moon at 100° → separation 0°
        let harmonics = [HarmonicPosition(factor: .sun, longitude: 100.0)]
        let radix: [(Factors, Double)] = [(.moon, 100.0)]
        let result = HarmonicsMatchFinder.find(harmonics: harmonics, radixPositions: radix, orb: orb)
        #expect(result.count == 1)
        #expect(result[0].harmonicFactor == .sun)
        #expect(result[0].radixFactor == .moon)
        #expect(abs(result[0].actualOrb - 0.0) < delta)
        #expect(abs(result[0].maxOrb - orb) < delta)
    }

    @Test("HarmonicsMatchFinder: finds match within orb")
    func testMatchWithinOrb() {
        // Harmonic Sun at 100°, radix Moon at 101.5° → separation 1.5° < 2°
        let harmonics = [HarmonicPosition(factor: .sun, longitude: 100.0)]
        let radix: [(Factors, Double)] = [(.moon, 101.5)]
        let result = HarmonicsMatchFinder.find(harmonics: harmonics, radixPositions: radix, orb: orb)
        #expect(result.count == 1)
        #expect(abs(result[0].actualOrb - 1.5) < delta)
    }

    @Test("HarmonicsMatchFinder: no match outside orb")
    func testNoMatchOutsideOrb() {
        // Harmonic Sun at 100°, radix Moon at 102.1° → separation 2.1° > 2°
        let harmonics = [HarmonicPosition(factor: .sun, longitude: 100.0)]
        let radix: [(Factors, Double)] = [(.moon, 102.1)]
        let result = HarmonicsMatchFinder.find(harmonics: harmonics, radixPositions: radix, orb: orb)
        #expect(result.isEmpty)
    }

    @Test("HarmonicsMatchFinder: match exactly at orb boundary is included")
    func testMatchAtExactBoundary() {
        // Separation == orb exactly → included
        let harmonics = [HarmonicPosition(factor: .sun, longitude: 100.0)]
        let radix: [(Factors, Double)] = [(.moon, 102.0)]
        let result = HarmonicsMatchFinder.find(harmonics: harmonics, radixPositions: radix, orb: orb)
        #expect(result.count == 1)
        #expect(abs(result[0].actualOrb - 2.0) < delta)
    }

    @Test("HarmonicsMatchFinder: multiple matches returned and sorted by orb")
    func testMultipleMatchesSortedByOrb() {
        // Harmonic Sun at 50°
        // radix Mars at 51° (sep 1°), radix Jupiter at 49.5° (sep 0.5°), radix Saturn at 53° (sep 3°, out)
        let harmonics = [HarmonicPosition(factor: .sun, longitude: 50.0)]
        let radix: [(Factors, Double)] = [(.mars, 51.0), (.jupiter, 49.5), (.saturn, 53.0)]
        let result = HarmonicsMatchFinder.find(harmonics: harmonics, radixPositions: radix, orb: orb)
        #expect(result.count == 2)
        // sorted: Jupiter (0.5°), Mars (1°)
        #expect(result[0].radixFactor == .jupiter)
        #expect(abs(result[0].actualOrb - 0.5) < delta)
        #expect(result[1].radixFactor == .mars)
        #expect(abs(result[1].actualOrb - 1.0) < delta)
    }

    @Test("HarmonicsMatchFinder: multiple harmonic factors matched against one radix position")
    func testMultipleHarmonicFactors() {
        // Harmonic Sun at 80°, harmonic Moon at 81° — both near radix Mars at 80°
        let harmonics = [
            HarmonicPosition(factor: .sun, longitude: 80.0),
            HarmonicPosition(factor: .moon, longitude: 81.0)
        ]
        let radix: [(Factors, Double)] = [(.mars, 80.0)]
        let result = HarmonicsMatchFinder.find(harmonics: harmonics, radixPositions: radix, orb: orb)
        #expect(result.count == 2)
        #expect(result[0].harmonicFactor == .sun)
        #expect(abs(result[0].actualOrb - 0.0) < delta)
        #expect(result[1].harmonicFactor == .moon)
        #expect(abs(result[1].actualOrb - 1.0) < delta)
    }

    // MARK: - Wrap-around (0°/360° boundary)

    @Test("HarmonicsMatchFinder: match across 0°/360° boundary — harmonic near 359°, radix near 1°")
    func testWrapAroundHarmonicNear360() {
        // Harmonic Sun at 359°, radix Moon at 1° → shortest separation = 2° (within orb)
        let harmonics = [HarmonicPosition(factor: .sun, longitude: 359.0)]
        let radix: [(Factors, Double)] = [(.moon, 1.0)]
        let result = HarmonicsMatchFinder.find(harmonics: harmonics, radixPositions: radix, orb: orb)
        #expect(result.count == 1)
        #expect(abs(result[0].actualOrb - 2.0) < delta)
    }

    @Test("HarmonicsMatchFinder: match across 0°/360° boundary — harmonic near 1°, radix near 359°")
    func testWrapAroundRadixNear360() {
        // Harmonic Sun at 1°, radix Moon at 359° → shortest separation = 2° (within orb)
        let harmonics = [HarmonicPosition(factor: .sun, longitude: 1.0)]
        let radix: [(Factors, Double)] = [(.moon, 359.0)]
        let result = HarmonicsMatchFinder.find(harmonics: harmonics, radixPositions: radix, orb: orb)
        #expect(result.count == 1)
        #expect(abs(result[0].actualOrb - 2.0) < delta)
    }

    @Test("HarmonicsMatchFinder: no match across boundary when separation exceeds orb")
    func testWrapAroundOutsideOrb() {
        // Harmonic Sun at 357°, radix Moon at 1° → shortest separation = 4° > 2°
        let harmonics = [HarmonicPosition(factor: .sun, longitude: 357.0)]
        let radix: [(Factors, Double)] = [(.moon, 1.0)]
        let result = HarmonicsMatchFinder.find(harmonics: harmonics, radixPositions: radix, orb: orb)
        #expect(result.isEmpty)
    }

    // MARK: - Edge cases

    @Test("HarmonicsMatchFinder: empty harmonics returns empty list")
    func testEmptyHarmonics() {
        let radix: [(Factors, Double)] = [(.sun, 45.0)]
        let result = HarmonicsMatchFinder.find(harmonics: [], radixPositions: radix, orb: orb)
        #expect(result.isEmpty)
    }

    @Test("HarmonicsMatchFinder: empty radix positions returns empty list")
    func testEmptyRadix() {
        let harmonics = [HarmonicPosition(factor: .sun, longitude: 45.0)]
        let result = HarmonicsMatchFinder.find(harmonics: harmonics, radixPositions: [], orb: orb)
        #expect(result.isEmpty)
    }

    @Test("HarmonicsMatchFinder: both inputs empty returns empty list")
    func testBothEmpty() {
        let result = HarmonicsMatchFinder.find(harmonics: [], radixPositions: [], orb: orb)
        #expect(result.isEmpty)
    }

    @Test("HarmonicsMatchFinder: maxOrb stored correctly on each match")
    func testMaxOrbStoredCorrectly() {
        let customOrb = 3.5
        let harmonics = [HarmonicPosition(factor: .sun, longitude: 100.0)]
        let radix: [(Factors, Double)] = [(.moon, 101.0)]
        let result = HarmonicsMatchFinder.find(harmonics: harmonics, radixPositions: radix, orb: customOrb)
        #expect(result.count == 1)
        #expect(abs(result[0].maxOrb - customOrb) < delta)
    }
}
