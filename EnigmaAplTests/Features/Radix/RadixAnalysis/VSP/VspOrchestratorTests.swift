// VspOrchestratorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

/// SE-backed VSP orchestrator test functions.
/// These are static helpers — not @Test decorated — called sequentially
/// from VspTestCoordinator so that one shared SEWrapper is used throughout.
struct VspOrchestratorTests {

    // MARK: - Test: exactly 5 positions and valid sequence IDs

    static func testHappyFlow(seWrapper: SEWrapper) {
        let birthJd = 2_459_580.5   // 2022-01-01
        let result  = VspOrchestrator.calculate(birthJd: birthJd, seWrapper: seWrapper)

        if result.count != 5 {
            Issue.record("Expected exactly 5 VSP positions, got \(result.count)")
            return
        }
        for (i, pos) in result.enumerated() {
            let expectedSeq = i + 1
            if pos.sequenceId != expectedSeq {
                Issue.record("Position \(i): expected sequenceId \(expectedSeq), got \(pos.sequenceId)")
            }
            if pos.jd <= 0 {
                Issue.record("Position \(i) has non-positive JD: \(pos.jd)")
            }
            if pos.dateText.isEmpty {
                Issue.record("Position \(i) has empty dateText")
            }
        }
    }

    // MARK: - Test: JDs are in strict chronological order

    static func testChronologicalOrder(seWrapper: SEWrapper) {
        let result = VspOrchestrator.calculate(birthJd: 2_459_580.5, seWrapper: seWrapper)
        guard result.count >= 2 else {
            Issue.record("Need at least 2 positions to check order, got \(result.count)")
            return
        }
        for i in 1..<result.count {
            if result[i].jd <= result[i - 1].jd {
                Issue.record("JDs not in ascending order at index \(i): \(result[i - 1].jd) >= \(result[i].jd)")
            }
        }
    }

    // MARK: - Test: all longitudes within [0, 360)

    static func testLongitudesInValidRange(seWrapper: SEWrapper) {
        let result = VspOrchestrator.calculate(birthJd: 2_459_580.5, seWrapper: seWrapper)
        for pos in result {
            if pos.longitude < 0.0 || pos.longitude >= 360.0 {
                Issue.record("Longitude out of range [0, 360): \(pos.longitude) for sequenceId \(pos.sequenceId)")
            }
        }
    }

    // MARK: - Test: result contains both inferior and superior conjunctions

    static func testBothPhenomenaPresent(seWrapper: SEWrapper) {
        let result = VspOrchestrator.calculate(birthJd: 2_459_580.5, seWrapper: seWrapper)
        let hasInferior = result.contains { $0.phenomenon == .inferiorConjunction }
        let hasSuperior = result.contains { $0.phenomenon == .superiorConjunction }
        if !hasInferior {
            Issue.record("No inferior conjunction found in VSP positions")
        }
        if !hasSuperior {
            Issue.record("No superior conjunction found in VSP positions")
        }
    }

    // MARK: - Test: same input produces identical results

    static func testConsistentResults(seWrapper: SEWrapper) {
        let birthJd = 2_459_580.5
        let first   = VspOrchestrator.calculate(birthJd: birthJd, seWrapper: seWrapper)
        let second  = VspOrchestrator.calculate(birthJd: birthJd, seWrapper: seWrapper)

        if first.count != second.count {
            Issue.record("Inconsistent count: \(first.count) vs \(second.count)")
            return
        }
        for i in 0..<first.count {
            if first[i].sequenceId != second[i].sequenceId {
                Issue.record("sequenceId mismatch at \(i): \(first[i].sequenceId) vs \(second[i].sequenceId)")
            }
            if abs(first[i].jd - second[i].jd) > 1e-8 {
                Issue.record("JD mismatch at \(i): \(first[i].jd) vs \(second[i].jd)")
            }
            if abs(first[i].longitude - second[i].longitude) > 1e-8 {
                Issue.record("Longitude mismatch at \(i): \(first[i].longitude) vs \(second[i].longitude)")
            }
            if first[i].phenomenon != second[i].phenomenon {
                Issue.record("Phenomenon mismatch at \(i)")
            }
        }
    }

    // MARK: - Test: Jan 2022 inferior conjunction is near 18° Capricorn (≈288°)

    static func testKnownLongitudeJan2022(seWrapper: SEWrapper) {
        let birthJd = 2_459_580.5   // 2022-01-01
        let result  = VspOrchestrator.calculate(birthJd: birthJd, seWrapper: seWrapper)

        // The Venus–Sun inferior conjunction of Jan 8–9, 2022 was at ~18° Capricorn ≈ 288°.
        // One of the five positions should land near that longitude.
        let hasNearCapricorn = result.contains { abs($0.longitude - 288.0) < 5.0 }
        if !hasNearCapricorn {
            let longitudes = result.map { String(format: "%.1f°", $0.longitude) }.joined(separator: ", ")
            Issue.record("Expected one VSP position near 288° (18° Capricorn), got: \(longitudes)")
        }
    }

    // MARK: - Test: historical and future dates return 5 valid positions

    static func testVariousDates(seWrapper: SEWrapper) {
        let dates: [(Double, String)] = [
            (2_440_000.5, "1968-05-01"),
            (2_451_545.0, "2000-01-01"),
            (2_459_580.5, "2022-01-01"),
            (2_480_000.5, "2050-01-22"),
        ]
        for (jd, label) in dates {
            let result = VspOrchestrator.calculate(birthJd: jd, seWrapper: seWrapper)
            if result.count != 5 {
                Issue.record("\(label): expected 5 positions, got \(result.count)")
                continue
            }
            for pos in result {
                if pos.longitude < 0.0 || pos.longitude >= 360.0 {
                    Issue.record("\(label): longitude out of range: \(pos.longitude)")
                }
                if pos.jd <= 0 {
                    Issue.record("\(label): non-positive JD: \(pos.jd)")
                }
            }
        }
    }
}
