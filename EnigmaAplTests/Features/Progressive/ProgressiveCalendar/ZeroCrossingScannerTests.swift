// ZeroCrossingScannerTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

struct ZeroCrossingScannerTests {

    // MARK: - Single crossing

    @Test("ZeroCrossingScanner: finds a single linear crossing within tolerance")
    func testSingleLinearCrossing() {
        let crossings = ZeroCrossingScanner.scan(
            startJD: 0.0,
            endJD: 10.0,
            stepSize: { _ in 1.0 },
            f: { jd in jd - 5.35 }
        )
        #expect(crossings.count == 1, "Expected exactly one crossing, got \(crossings.count)")
        if let crossing = crossings.first {
            #expect(abs(crossing - 5.35) < 1e-6, "Expected crossing near 5.35, got \(crossing)")
        }
    }

    // MARK: - Multiple crossings

    @Test("ZeroCrossingScanner: finds multiple crossings in ascending order")
    func testMultipleCrossingsAscendingOrder() {
        // f(jd) = sin(jd) has zero crossings at 0, π, 2π, ... — scan (0.5, 20) to skip jd=0.
        let crossings = ZeroCrossingScanner.scan(
            startJD: 0.5,
            endJD: 20.0,
            stepSize: { _ in 0.5 },
            f: { jd in sin(jd) }
        )
        let pi: Double = Double.pi
        var expected: [Double] = []
        var multiple: Double = pi
        while multiple < 20.0 {
            expected.append(multiple)
            multiple += pi
        }
        #expect(crossings.count == expected.count, "Crossing count mismatch")
        for i in 0..<min(crossings.count, expected.count) {
            let actual: Double = crossings[i]
            let exp: Double = expected[i]
            let diff: Double = abs(actual - exp)
            #expect(diff < 1e-6, "Expected crossing near \(exp), got \(actual)")
        }
        var isAscending = true
        if crossings.count > 1 {
            for i in 1..<crossings.count {
                if crossings[i] < crossings[i - 1] { isAscending = false }
            }
        }
        #expect(isAscending, "Crossings must be in ascending order")
    }

    // MARK: - No crossing

    @Test("ZeroCrossingScanner: returns empty when the function never changes sign")
    func testNoCrossingReturnsEmpty() {
        let crossings = ZeroCrossingScanner.scan(
            startJD: 0.0,
            endJD: 10.0,
            stepSize: { _ in 1.0 },
            f: { jd in jd + 5.0 }
        )
        #expect(crossings.isEmpty, "Expected no crossings, got \(crossings)")
    }

    @Test("ZeroCrossingScanner: returns empty when startJD is not before endJD")
    func testInvalidRangeReturnsEmpty() {
        let crossings = ZeroCrossingScanner.scan(
            startJD: 10.0,
            endJD: 10.0,
            stepSize: { _ in 1.0 },
            f: { jd in jd - 5.0 }
        )
        #expect(crossings.isEmpty, "Expected no crossings for an empty range")
    }

    // MARK: - Plausibility guard (wraparound rejection)

    @Test("ZeroCrossingScanner: isPlausibleCrossing guard rejects a wraparound sign change")
    func testPlausibilityGuardRejectsWraparound() {
        // Simulates an angular deviation that jumps from +179 to -179 (a real sign change,
        // but not a genuine zero crossing) between two samples, and a genuine crossing near 5.0.
        func f(_ jd: Double) -> Double {
            if jd < 2.0 { return 179.0 }
            if jd < 3.0 { return -179.0 }
            return jd - 5.35
        }
        let crossings = ZeroCrossingScanner.scan(
            startJD: 0.0,
            endJD: 10.0,
            stepSize: { _ in 1.0 },
            isPlausibleCrossing: { fA, fB in abs(fA) + abs(fB) < 90.0 },
            f: f
        )
        #expect(crossings.count == 1, "Wraparound crossing should be rejected, only the genuine one kept")
        if let crossing = crossings.first {
            #expect(abs(crossing - 5.35) < 1e-6, "Expected the genuine crossing near 5.35, got \(crossing)")
        }
    }

    // MARK: - Adaptive step size

    @Test("ZeroCrossingScanner: adaptive step size still finds the crossing")
    func testAdaptiveStepSize() {
        let crossings = ZeroCrossingScanner.scan(
            startJD: 0.0,
            endJD: 100.0,
            stepSize: { jd in jd < 50.0 ? 10.0 : 1.0 },
            f: { jd in jd - 55.42 }
        )
        #expect(crossings.count == 1, "Expected exactly one crossing, got \(crossings.count)")
        if let crossing = crossings.first {
            #expect(abs(crossing - 55.42) < 1e-6, "Expected crossing near 55.42, got \(crossing)")
        }
    }

    // MARK: - Extremum via derivative crossing (e.g. max declination pattern)

    @Test("ZeroCrossingScanner: extremum of a function found via its derivative crossing zero")
    func testExtremumViaDerivativeZeroCrossing() {
        // f(jd) = -(jd - 5.35)^2 + 25 has its maximum at jd = 5.35; its derivative is -2(jd - 5.35).
        func derivative(_ jd: Double) -> Double { -2.0 * (jd - 5.35) }
        let crossings = ZeroCrossingScanner.scan(
            startJD: 0.0,
            endJD: 10.0,
            stepSize: { _ in 1.0 },
            f: derivative
        )
        #expect(crossings.count == 1, "Expected exactly one extremum, got \(crossings.count)")
        if let crossing = crossings.first {
            #expect(abs(crossing - 5.35) < 1e-6, "Expected extremum near jd=5.35, got \(crossing)")
        }
    }
}
