// SpiritualBirthtimeCalculatorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
@testable import EnigmaApl

/// Integration tests for SpiritualBirthtimeCalculator.
///
/// Reference input:
///   Birth:    1970-06-15, 14:30:00 LT
///   Timezone: +1 h (CET without DST)
///   Location: 52°13'N (+52.2167°), 6°54'E (+6.9°)
///
/// These tests verify the shape and plausibility of the output.
/// Exact LST/TLT values depend on SE ephemeris data, so bounds-based
/// checks are used rather than hard-coded absolute values.
@MainActor
struct SpiritualBirthtimeCalculatorTests {

    private static let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()

    private static let input = SpiritualBirthtimeInput(
        year: 1970, month: 6, day: 15,
        hour: 14, minute: 30, second: 0,
        timeZone: 1.0,
        geoLatitude:  52.2167,
        geoLongitude:  6.9
    )

    // MARK: - Result structure

    @Test("SpiritualBirthtimeCalculator: returns at least one candidate")
    func testReturnsAtLeastOneCandidate() {
        let result = SpiritualBirthtimeCalculator.calculate(input: Self.input, seWrapper: Self.seWrapper)
        #expect(!result.isEmpty)
    }

    @Test("SpiritualBirthtimeCalculator: all LST values in 0–24 hours")
    func testLstRange() {
        let result = SpiritualBirthtimeCalculator.calculate(input: Self.input, seWrapper: Self.seWrapper)
        for candidate in result {
            #expect(candidate.lst >= 0.0 && candidate.lst <= 24.0)
        }
    }

    @Test("SpiritualBirthtimeCalculator: all TLT values in 0–24 hours")
    func testTltRange() {
        let result = SpiritualBirthtimeCalculator.calculate(input: Self.input, seWrapper: Self.seWrapper)
        for candidate in result {
            #expect(candidate.tlt >= 0.0 && candidate.tlt <= 24.0)
        }
    }

    @Test("SpiritualBirthtimeCalculator: all ARC values in 0–2π")
    func testArcRange() {
        let result = SpiritualBirthtimeCalculator.calculate(input: Self.input, seWrapper: Self.seWrapper)
        for candidate in result {
            #expect(candidate.arc >= 0.0 && candidate.arc <= 2.0 * Double.pi)
        }
    }

    @Test("SpiritualBirthtimeCalculator: candidates are sorted by TLT ascending")
    func testSortedByTlt() {
        let result = SpiritualBirthtimeCalculator.calculate(input: Self.input, seWrapper: Self.seWrapper)
        for i in 1..<result.count {
            #expect(result[i].tlt >= result[i - 1].tlt)
        }
    }

    @Test("SpiritualBirthtimeCalculator: additionalHours is 0 or 6")
    func testAdditionalHoursIsZeroOrSix() {
        let result = SpiritualBirthtimeCalculator.calculate(input: Self.input, seWrapper: Self.seWrapper)
        for candidate in result {
            #expect(candidate.additionalHours == 0 || candidate.additionalHours == 6)
        }
    }

    // MARK: - Window constraint

    @Test("SpiritualBirthtimeCalculator: candidate count is bounded (LST filter is working)")
    func testCandidateCountBounded() {
        let result = SpiritualBirthtimeCalculator.calculate(input: Self.input, seWrapper: Self.seWrapper)
        // The triple nested loop (4 moonNums × 4 uranusNums × 8 slots) gives at most 128
        // raw slots; after the ±window filter the surviving count must be smaller.
        // A sane upper bound is 32; the algorithm typically produces 2–12 candidates.
        #expect(result.count <= 32)
    }

    // MARK: - Southern hemisphere

    @Test("SpiritualBirthtimeCalculator: southern hemisphere input produces candidates")
    func testSouthernHemisphere() {
        let southInput = SpiritualBirthtimeInput(
            year: 1970, month: 6, day: 15,
            hour: 14, minute: 30, second: 0,
            timeZone: 2.0,
            geoLatitude:  -33.87,   // Sydney
            geoLongitude: 151.21
        )
        let result = SpiritualBirthtimeCalculator.calculate(input: southInput, seWrapper: Self.seWrapper)
        #expect(!result.isEmpty)
    }

    // MARK: - Different dates

    @Test("SpiritualBirthtimeCalculator: winter birth produces candidates")
    func testWinterBirth() {
        let winterInput = SpiritualBirthtimeInput(
            year: 1970, month: 1, day: 5,
            hour: 8, minute: 0, second: 0,
            timeZone: 1.0,
            geoLatitude:  52.0,
            geoLongitude:  5.0
        )
        let result = SpiritualBirthtimeCalculator.calculate(input: winterInput, seWrapper: Self.seWrapper)
        #expect(!result.isEmpty)
    }
}
