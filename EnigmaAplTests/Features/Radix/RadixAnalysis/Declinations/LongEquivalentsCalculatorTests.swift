// LongEquivalentsCalculatorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Testing
@testable import EnigmaApl

/// Reference obliquity used throughout: 23.4367°  (close to J2000 true obliquity).
///
/// Analytically derived test expectations
/// ──────────────────────────────────────
/// Sun: decl = 0°, long = 5° (first quadrant)
///   candidate1 = asin(0 / sin(23.4367°)) = 0°  diff = 5°
///   candidate2 = 90 + (90 − 0) = 180°           diff = 175°  → equivalent = 0°
///
/// Moon: decl = 23.4367° (= obliquity), long = 91°
///   candidate1 = asin(1) = 90°                  diff = 1°
///   candidate2 = 90 + (90 − 90) = 90°           diff = 1°  → candidate1 wins (tie goes to c1)
///   → equivalent ≈ 90°
///
/// Mars: decl = 11.7184° (= obliquity/2), long = 45°
///   sin(decl)/sin(obliq) = sin(11.7184°)/sin(23.4367°) = 0.5
///   candidate1 = asin(0.5) = 30°                diff = 15°
///   candidate2 = 90+(90−30) = 150°              diff = 105° → equivalent = 30°
///
/// Saturn: decl = −23.4367° (south, at obliquity), long = 270°
///   candidate1 = asin(−1) = −90° → normalised = 270°   diff = 0°
///   candidate2 = 270+(270−270) = 270°                   diff = 0°  → c1 wins
///   → equivalent = 270°
///
/// Jupiter: decl = 30.0° > 23.4367° → OOB
///   oobPart = 30.0 − 23.4367 = 6.5633°
///   reflected = 23.4367 − 6.5633 = 16.8734°
///   candidate1 = asin(sin(16.8734°)/sin(23.4367°)) ≈ asin(0.6347) ≈ 39.4°
///   long = 60° < 180 → candidate2 = 90+(90−39.4) = 140.6°   diff1 = 20.6°, diff2 = 80.6°
///   → equivalent ≈ 39.4°,  isOutOfBounds = true
///
/// Mercury: decl = −30.0° < −23.4367° → OOB (south)
///   reflected = 6.5633 − 23.4367 = −16.8734°
///   candidate1 = asin(sin(−16.8734°)/sin(23.4367°)) ≈ −39.4° → +360 = 320.6°
///   long = 300° ≥ 180 → candidate2 = 270+(270−320.6) = 219.4°  diff1=20.6°, diff2=80.6°
///   → equivalent ≈ 320.6°,  isOutOfBounds = true
struct LongEquivalentsCalculatorTests {

    private let delta = 1e-3          // ≈ 0.001° tolerance for trig rounding
    private let obliquity = 23.4367   // reference obliquity for all tests

    // MARK: - Shared helpers

    private func makePos(longitude: Double, declination: Double) -> FullFactorPosition {
        FullFactorPosition(
            ecliptical: [MainAstronomicalPosition(mainPos: longitude, deviation: 0, distance: 1)],
            equatorial: [MainAstronomicalPosition(mainPos: 0, deviation: declination, distance: 1)],
            horizontal: [HorizontalPosition(azimuth: 0, altitude: 0)]
        )
    }

    private func makeChart(factors: [(Factors, Double, Double)], obliquity: Double) -> FullChart {
        let coords = Dictionary(uniqueKeysWithValues: factors.map {
            ($0.0, makePos(longitude: $0.1, declination: $0.2))
        })
        let cusp   = FullCuspPosition(longitude: 0, rightAscension: 0, declination: 0,
                                      horizontal: HorizontalPosition(azimuth: 0, altitude: 0))
        let houses = HousePositions(cusps: Array(repeating: cusp, count: 13),
                                    ascendant: cusp, midheaven: cusp,
                                    eastpoint: cusp, vertex: cusp)
        return FullChart(Coordinates: coords, HousePositions: houses,
                         SiderealTime: 0, JulianDay: 0, Obliquity: obliquity)
    }

    private func makeConfig(factors: [Factors]) -> FactorConfig {
        let settings = factors.map { FactorSettings(factor: $0, isUsed: true, isDrawn: true) }
        return FactorConfig(factorSettings: settings)
    }

    // MARK: - Zero declination

    @Test("LongEquivalentsCalculator: zero declination gives equivalent near 0°")
    func testZeroDeclination() {
        // Sun: decl=0°, long=5° → candidate1=0°, diff=5°; c2=180°, diff=175° → 0°
        let chart  = makeChart(factors: [(.sun, 5.0, 0.0)], obliquity: obliquity)
        let config = makeConfig(factors: [.sun])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(result.count == 1)
        #expect(abs(result[0].longitudeEquivalent - 0.0) < delta)
        #expect(result[0].isOutOfBounds == false)
    }

    // MARK: - Declination equals obliquity

    @Test("LongEquivalentsCalculator: declination equal to obliquity gives equivalent ~90°")
    func testDeclEqualObliquity() {
        // Moon: decl=obliquity, long=91° → candidate1≈90°, is closest
        let chart  = makeChart(factors: [(.moon, 91.0, obliquity)], obliquity: obliquity)
        let config = makeConfig(factors: [.moon])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(result.count == 1)
        #expect(abs(result[0].longitudeEquivalent - 90.0) < delta)
        #expect(result[0].isOutOfBounds == false)
    }

    // MARK: - Half obliquity

    @Test("LongEquivalentsCalculator: half-obliquity declination gives correct equivalent")
    func testHalfObliquity() {
        // Mars: decl=obliquity/2, long=45° (first quadrant)
        // candidate1 = asin(sin(decl)/sin(obl)); long<180 → candidate2 = 90+(90−c1)
        // diff1 = |c1−45|, diff2 = |c2−45|; pick smaller
        let decl     = obliquity / 2.0
        let sinRatio = sin(decl * .pi / 180.0) / sin(obliquity * .pi / 180.0)
        let c1       = asin(sinRatio) * 180.0 / .pi          // ≈ 30.71°
        let c2       = 90.0 + (90.0 - c1)                    // ≈ 149.29°
        let expected = abs(c1 - 45.0) < abs(c2 - 45.0) ? c1 : c2   // c1 is closer

        let chart  = makeChart(factors: [(.mars, 45.0, decl)], obliquity: obliquity)
        let config = makeConfig(factors: [.mars])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(result.count == 1)
        #expect(abs(result[0].longitudeEquivalent - expected) < delta)
        #expect(result[0].isOutOfBounds == false)
    }

    // MARK: - South declination (candidate in third/fourth quadrant)

    @Test("LongEquivalentsCalculator: south declination equal to obliquity gives equivalent ~270°")
    func testSouthDeclEqualObliquity() {
        // Saturn: decl=−obliquity, long=270° → asin(−1)=−90° → normalised 270°
        let chart  = makeChart(factors: [(.saturn, 270.0, -obliquity)], obliquity: obliquity)
        let config = makeConfig(factors: [.saturn])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(result.count == 1)
        #expect(abs(result[0].longitudeEquivalent - 270.0) < delta)
        #expect(result[0].isOutOfBounds == false)
    }

    // MARK: - Out of bounds (OOB)

    @Test("LongEquivalentsCalculator: declination beyond obliquity sets isOutOfBounds")
    func testOobFlagSet() {
        // Jupiter: decl=30° > 23.4367° → OOB
        let chart  = makeChart(factors: [(.jupiter, 60.0, 30.0)], obliquity: obliquity)
        let config = makeConfig(factors: [.jupiter])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(result.count == 1)
        #expect(result[0].isOutOfBounds == true)
    }

    @Test("LongEquivalentsCalculator: OOB north factor: reflected declination used for equivalent")
    func testOobNorthEquivalent() {
        // Jupiter: decl=30°, oobPart=6.5633°, reflected=16.8734°
        // candidate1 = asin(sin(16.8734°)/sin(23.4367°))
        let chart  = makeChart(factors: [(.jupiter, 60.0, 30.0)], obliquity: obliquity)
        let config = makeConfig(factors: [.jupiter])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)

        let reflected  = obliquity - (30.0 - obliquity)
        let sinRefl    = sin(reflected * .pi / 180.0)
        let sinObl     = sin(obliquity * .pi / 180.0)
        let expected   = asin(sinRefl / sinObl) * 180.0 / .pi  // ≈ 39.4°

        #expect(abs(result[0].longitudeEquivalent - expected) < delta)
    }

    @Test("LongEquivalentsCalculator: OOB south factor: isOutOfBounds is true")
    func testOobSouthFlag() {
        // Mercury: decl=−30° < −23.4367° → OOB
        let chart  = makeChart(factors: [(.mercury, 300.0, -30.0)], obliquity: obliquity)
        let config = makeConfig(factors: [.mercury])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(result.count == 1)
        #expect(result[0].isOutOfBounds == true)
    }

    @Test("LongEquivalentsCalculator: declination exactly at obliquity is not OOB")
    func testExactlyAtObliquityIsNotOob() {
        let chart  = makeChart(factors: [(.sun, 90.0, obliquity)], obliquity: obliquity)
        let config = makeConfig(factors: [.sun])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(result[0].isOutOfBounds == false)
    }

    // MARK: - Candidate selection

    @Test("LongEquivalentsCalculator: second quadrant longitude selects candidate on same arc")
    func testSecondQuadrantCandidateSelection() {
        // decl = obliquity/2, long = 140° < 180°
        // candidate1 = asin(sin(decl)/sin(obl)); candidate2 = 90+(90−c1)
        // candidate2 is closer to 140° than candidate1 is
        let decl     = obliquity / 2.0
        let sinRatio = sin(decl * .pi / 180.0) / sin(obliquity * .pi / 180.0)
        let c1       = asin(sinRatio) * 180.0 / .pi          // ≈ 30.71°
        let c2       = 90.0 + (90.0 - c1)                    // ≈ 149.29°
        let expected = abs(c1 - 140.0) < abs(c2 - 140.0) ? c1 : c2  // c2 is closer

        let chart  = makeChart(factors: [(.sun, 140.0, decl)], obliquity: obliquity)
        let config = makeConfig(factors: [.sun])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(abs(result[0].longitudeEquivalent - expected) < delta)
    }

    @Test("LongEquivalentsCalculator: third quadrant longitude uses candidate2 formula for ≥180°")
    func testThirdQuadrantCandidateSelection() {
        // Sun: decl = −obliquity/2, long = 220° ≥ 180°
        // candidate1 = asin(sin(−decl)/sin(obl)) < 0 → normalised to > 180°
        // candidate2 = 270+(270−c1); candidate2 is closer to 220°
        let decl     = obliquity / 2.0
        let sinRatio = sin(-decl * .pi / 180.0) / sin(obliquity * .pi / 180.0)
        var c1       = asin(sinRatio) * 180.0 / .pi
        if c1 < 0.0 { c1 += 360.0 }                          // ≈ 329.29°
        let c2       = 270.0 + (270.0 - c1)                  // ≈ 210.71°
        let expected = abs(c1 - 220.0) < abs(c2 - 220.0) ? c1 : c2  // c2 is closer

        let chart  = makeChart(factors: [(.sun, 220.0, -decl)], obliquity: obliquity)
        let config = makeConfig(factors: [.sun])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(abs(result[0].longitudeEquivalent - expected) < delta)
    }

    // MARK: - FactorConfig filtering

    @Test("LongEquivalentsCalculator: inactive factor is excluded")
    func testInactiveFactorExcluded() {
        // Chart has Sun and Moon; config marks only Sun as used
        let chart  = makeChart(factors: [(.sun, 5.0, 0.0), (.moon, 91.0, obliquity)],
                               obliquity: obliquity)
        let config = makeConfig(factors: [.sun])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(result.count == 1)
        #expect(result[0].factor == .sun)
    }

    @Test("LongEquivalentsCalculator: factor absent from chart is excluded")
    func testAbsentFactorExcluded() {
        // Config asks for Sun and Jupiter; chart has only Sun
        let chart  = makeChart(factors: [(.sun, 5.0, 0.0)], obliquity: obliquity)
        let config = makeConfig(factors: [.sun, .jupiter])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(result.count == 1)
        #expect(result[0].factor == .sun)
    }

    // MARK: - Multiple factors

    @Test("LongEquivalentsCalculator: returns one result per active factor")
    func testResultCountMatchesActiveFactors() {
        let chart  = makeChart(factors: [(.sun,     5.0,  0.0),
                                         (.moon,   91.0,  obliquity),
                                         (.mars,   45.0,  obliquity / 2.0),
                                         (.saturn, 270.0, -obliquity)],
                               obliquity: obliquity)
        let config = makeConfig(factors: [.sun, .moon, .mars, .saturn])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(result.count == 4)
    }

    // MARK: - Edge cases

    @Test("LongEquivalentsCalculator: empty chart returns empty list")
    func testEmptyChart() {
        let chart  = makeChart(factors: [], obliquity: obliquity)
        let config = makeConfig(factors: [.sun, .moon])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(result.isEmpty)
    }

    @Test("LongEquivalentsCalculator: factor property matches the requested factor")
    func testFactorPropertyIsCorrect() {
        let chart  = makeChart(factors: [(.mars, 45.0, obliquity / 2.0)], obliquity: obliquity)
        let config = makeConfig(factors: [.mars])
        let result = LongEquivalentsCalculator.equivalents(chart: chart, factorConfig: config)
        #expect(result[0].factor == .mars)
    }
}
