// HarmonicsCalculatorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

struct HarmonicsCalculatorTests {

    private let delta = 1e-8

    // MARK: - Happy flow

    @Test("HarmonicsCalculator: correct harmonic positions for H2")
    func testH2Positions() {
        // Sun=30°, Moon=100°, Mars=200°
        // H2: 60°, 200°, 400° → 40°
        let positions: [(Factors, Double)] = [(.sun, 30.0), (.moon, 100.0), (.mars, 200.0)]
        let result = HarmonicsCalculator.calculate(positions: positions, harmonic: 2.0)
        #expect(result.count == 3)
        // sorted: 40° (Mars), 60° (Sun), 200° (Moon)
        #expect(abs(result[0].longitude - 40.0) < delta)
        #expect(abs(result[1].longitude - 60.0) < delta)
        #expect(abs(result[2].longitude - 200.0) < delta)
    }

    @Test("HarmonicsCalculator: correct factors after sorting")
    func testH2Factors() {
        let positions: [(Factors, Double)] = [(.sun, 30.0), (.moon, 100.0), (.mars, 200.0)]
        let result = HarmonicsCalculator.calculate(positions: positions, harmonic: 2.0)
        // sorted: Mars(40°), Sun(60°), Moon(200°)
        #expect(result[0].factor == .mars)
        #expect(result[1].factor == .sun)
        #expect(result[2].factor == .moon)
    }

    @Test("HarmonicsCalculator: correct harmonic positions for H3")
    func testH3Positions() {
        // Sun=10°, Moon=130°
        // H3: 30°, 390° → 30°
        let positions: [(Factors, Double)] = [(.sun, 10.0), (.moon, 130.0)]
        let result = HarmonicsCalculator.calculate(positions: positions, harmonic: 3.0)
        #expect(result.count == 2)
        #expect(abs(result[0].longitude - 30.0) < delta)
        #expect(abs(result[1].longitude - 30.0) < delta)
    }

    @Test("HarmonicsCalculator: correct harmonic positions for H5")
    func testH5Positions() {
        // Sun=72°: H5 = 360° → 0°
        // Moon=50°: H5 = 250°
        let positions: [(Factors, Double)] = [(.sun, 72.0), (.moon, 50.0)]
        let result = HarmonicsCalculator.calculate(positions: positions, harmonic: 5.0)
        #expect(result.count == 2)
        // sorted: 0° (Sun), 250° (Moon)
        #expect(abs(result[0].longitude - 0.0) < delta)
        #expect(abs(result[1].longitude - 250.0) < delta)
    }

    // MARK: - Reduction to 0–360°

    @Test("HarmonicsCalculator: result stays within 0–360°")
    func testResultInRange() {
        let positions = Self.makePositions()
        let result = HarmonicsCalculator.calculate(positions: positions, harmonic: 7.0)
        for item in result {
            #expect(item.longitude >= 0.0 && item.longitude < 360.0)
        }
    }

    @Test("HarmonicsCalculator: longitude exactly 0° when product is multiple of 360°")
    func testExactZeroResult() {
        // 180° × H2 = 360° → 0°
        let positions: [(Factors, Double)] = [(.sun, 180.0)]
        let result = HarmonicsCalculator.calculate(positions: positions, harmonic: 2.0)
        #expect(abs(result[0].longitude - 0.0) < delta)
    }

    // MARK: - Non-integer harmonic

    @Test("HarmonicsCalculator: fractional harmonic H1.5")
    func testFractionalHarmonic() {
        // Sun=100°: H1.5 = 150°
        // Moon=200°: H1.5 = 300°
        let positions: [(Factors, Double)] = [(.sun, 100.0), (.moon, 200.0)]
        let result = HarmonicsCalculator.calculate(positions: positions, harmonic: 1.5)
        #expect(result.count == 2)
        #expect(abs(result[0].longitude - 150.0) < delta)
        #expect(abs(result[1].longitude - 300.0) < delta)
    }

    @Test("HarmonicsCalculator: fractional harmonic reduces correctly past 360°")
    func testFractionalHarmonicWithWrap() {
        // Sun=300°: H1.5 = 450° → 90°
        let positions: [(Factors, Double)] = [(.sun, 300.0)]
        let result = HarmonicsCalculator.calculate(positions: positions, harmonic: 1.5)
        #expect(abs(result[0].longitude - 90.0) < delta)
    }

    // MARK: - H1 (identity)

    @Test("HarmonicsCalculator: H1 returns original longitudes")
    func testH1IsIdentity() {
        let positions = Self.makePositions()
        let result = HarmonicsCalculator.calculate(positions: positions, harmonic: 1.0)
        let originalSorted = positions.map(\.1).sorted()
        let resultLongitudes = result.map(\.longitude)
        for (expected, actual) in zip(originalSorted, resultLongitudes) {
            #expect(abs(actual - expected) < delta)
        }
    }

    // MARK: - Sorting

    @Test("HarmonicsCalculator: result is sorted ascending by longitude")
    func testResultIsSorted() {
        let positions = Self.makePositions()
        let result = HarmonicsCalculator.calculate(positions: positions, harmonic: 4.0)
        for i in 0..<(result.count - 1) {
            #expect(result[i].longitude <= result[i + 1].longitude)
        }
    }

    // MARK: - Edge cases

    @Test("HarmonicsCalculator: empty input returns empty list")
    func testEmptyInput() {
        let result = HarmonicsCalculator.calculate(positions: [], harmonic: 2.0)
        #expect(result.isEmpty)
    }

    @Test("HarmonicsCalculator: single factor returns one result")
    func testSingleFactor() {
        let result = HarmonicsCalculator.calculate(positions: [(.sun, 45.0)], harmonic: 2.0)
        #expect(result.count == 1)
        #expect(abs(result[0].longitude - 90.0) < delta)
    }

    // MARK: - Helpers

    /// Sun=22°, Moon=178°, Mars=302°, Jupiter=42°
    private static func makePositions() -> [(Factors, Double)] {
        [(.sun, 22.0), (.moon, 178.0), (.mars, 302.0), (.jupiter, 42.0)]
    }
}
