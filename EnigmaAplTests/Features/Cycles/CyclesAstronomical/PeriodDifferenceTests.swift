// PeriodDifferenceTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

@MainActor
struct PeriodDifferenceTests {

    // MARK: - Shared test parameters

    /// JD for 2010-01-01 0:00 UT — consistent with other SE-dependent tests.
    private let baseJd   = 2455197.5
    private let interval = 10.0
    private let delta    = 1e-6

    private func makeRequest(
        factor1: Factors = .sun,
        factor2: Factors = .moon,
        interval: Double? = nil,
        endOffset: Double = 0.0,
        coordinate: Coordinates = .longitude
    ) -> PeriodDifferenceRequest {
        PeriodDifferenceRequest(
            Factor1: factor1,
            Factor2: factor2,
            Interval: interval ?? self.interval,
            JdStart: baseJd,
            JdEnd: baseJd + endOffset,
            Coordinate: coordinate
        )
    }

    // MARK: - Result count and JD sequence

    @Test("PeriodDifference: single step produces exactly one result")
    func testSingleStep_resultCount() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = PeriodDifference.PerformCalculation(makeRequest(), seWrapper: seWrapper)
        #expect(results.count == 1)
    }

    @Test("PeriodDifference: three-step period produces exactly three results")
    func testThreeSteps_resultCount() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = PeriodDifference.PerformCalculation(
            makeRequest(endOffset: interval * 2), seWrapper: seWrapper)
        #expect(results.count == 3)
    }

    @Test("PeriodDifference: Julian day values follow the correct sequence")
    func testMultipleSteps_julianDaySequence() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = PeriodDifference.PerformCalculation(
            makeRequest(endOffset: interval * 2), seWrapper: seWrapper)
        for (index, entry) in results.enumerated() {
            let expectedJd = baseJd + interval * Double(index)
            #expect(abs(entry.julianDay - expectedJd) < delta,
                    "Step \(index): expected JD \(expectedJd), got \(entry.julianDay)")
        }
    }

    @Test("PeriodDifference: endJdEnd exactly on a step boundary is included")
    func testEndJdExactlyOnStep_isIncluded() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = PeriodDifference.PerformCalculation(
            makeRequest(endOffset: interval * 2), seWrapper: seWrapper)
        #expect(results.count == 3)
        #expect(abs(results.last!.julianDay - (baseJd + interval * 2)) < delta)
    }

    @Test("PeriodDifference: endJdNr between steps stops before exceeding it")
    func testEndJdBetweenSteps_stopsBeforeExceeding() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        // end falls halfway between step 2 and step 3 → only 3 results
        let results = PeriodDifference.PerformCalculation(
            makeRequest(endOffset: interval * 2 + interval / 2), seWrapper: seWrapper)
        #expect(results.count == 3)
        #expect(results.last!.julianDay <= baseJd + interval * 2 + interval / 2)
    }

    @Test("PeriodDifference: startJdNr after endJdNr returns empty list")
    func testStartAfterEnd_returnsEmpty() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = PeriodDifferenceRequest(
            Factor1: .sun, Factor2: .moon, Interval: interval,
            JdStart: baseJd + 1.0, JdEnd: baseJd, Coordinate: .longitude)
        let results = PeriodDifference.PerformCalculation(request, seWrapper: seWrapper)
        #expect(results.isEmpty)
    }

    // MARK: - Difference correctness: same factor

    @Test("PeriodDifference: same factor produces zero longitude difference")
    func testSameFactor_longitudeDifferenceIsZero() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest(factor1: .sun, factor2: .sun, coordinate: .longitude)
        let results = PeriodDifference.PerformCalculation(request, seWrapper: seWrapper)
        #expect(abs(results[0].difference) < delta,
                "Sun vs Sun longitude difference should be 0, got \(results[0].difference)")
    }

    @Test("PeriodDifference: same factor produces zero declination difference")
    func testSameFactor_declinationDifferenceIsZero() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest(factor1: .moon, factor2: .moon, coordinate: .declination)
        let results = PeriodDifference.PerformCalculation(request, seWrapper: seWrapper)
        #expect(abs(results[0].difference) < delta,
                "Moon vs Moon declination difference should be 0, got \(results[0].difference)")
    }

    // MARK: - Difference correctness: manual computation

    @Test("PeriodDifference: longitude difference matches manual shortest-arc computation")
    func testLongitudeDifference_matchesManual() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest(factor1: .sun, factor2: .moon, coordinate: .longitude)
        let results = PeriodDifference.PerformCalculation(request, seWrapper: seWrapper)
        #expect(results.count == 1)

        // Independently fetch longitudes via PerformSingleCoordinateCalculation
        let config = CalculationConfig(houseSystem: .noHouses)
        func longitude(for factor: Factors) -> Double {
            let req = CalcRequest(
                JulianDay: baseJd, FactorsToUse: [factor],
                HouseSystem: HouseSystems.noHouses.rawValue,
                Latitude: 0.0, Longitude: 0.0, Height: 0.0,
                calculationConfig: config)
            let (_, pos) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
                req, coordinate: .longitude, seWrapper: seWrapper)
            return pos
        }

        let lon1 = longitude(for: .sun)
        let lon2 = longitude(for: .moon)
        let diff = abs(lon1 - lon2).truncatingRemainder(dividingBy: 360.0)
        let expected = diff > 180.0 ? 360.0 - diff : diff

        #expect(abs(results[0].difference - expected) < delta,
                "Expected longitude difference \(expected), got \(results[0].difference)")
    }

    @Test("PeriodDifference: declination difference matches manual absolute computation")
    func testDeclinationDifference_matchesManual() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest(factor1: .sun, factor2: .moon, coordinate: .declination)
        let results = PeriodDifference.PerformCalculation(request, seWrapper: seWrapper)
        #expect(results.count == 1)

        let config = CalculationConfig(houseSystem: .noHouses)
        func declination(for factor: Factors) -> Double {
            let req = CalcRequest(
                JulianDay: baseJd, FactorsToUse: [factor],
                HouseSystem: HouseSystems.noHouses.rawValue,
                Latitude: 0.0, Longitude: 0.0, Height: 0.0,
                calculationConfig: config)
            let (_, pos) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
                req, coordinate: .declination, seWrapper: seWrapper)
            return pos
        }

        let expected = abs(declination(for: .sun) - declination(for: .moon))
        #expect(abs(results[0].difference - expected) < delta,
                "Expected declination difference \(expected), got \(results[0].difference)")
    }

    // MARK: - Symmetry

    @Test("PeriodDifference: swapping Factor1 and Factor2 gives the same difference")
    func testSymmetry_swappedFactorsGiveSameDifference() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let forward = PeriodDifference.PerformCalculation(
            makeRequest(factor1: .sun, factor2: .saturn, coordinate: .longitude),
            seWrapper: seWrapper)
        let swapped = PeriodDifference.PerformCalculation(
            makeRequest(factor1: .saturn, factor2: .sun, coordinate: .longitude),
            seWrapper: seWrapper)
        #expect(abs(forward[0].difference - swapped[0].difference) < delta,
                "Sun-Saturn and Saturn-Sun should give identical difference")
    }

    // MARK: - Range constraints

    @Test("PeriodDifference: longitude difference is in [0, 180]")
    func testLongitudeDifference_inValidRange() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = PeriodDifference.PerformCalculation(
            makeRequest(factor1: .sun, factor2: .moon,
                        endOffset: interval * 2, coordinate: .longitude),
            seWrapper: seWrapper)
        for entry in results {
            #expect(entry.difference >= 0.0,
                    "Longitude difference \(entry.difference) at JD \(entry.julianDay) is negative")
            #expect(entry.difference <= 180.0,
                    "Longitude difference \(entry.difference) at JD \(entry.julianDay) exceeds 180°")
        }
    }

    @Test("PeriodDifference: declination difference is non-negative")
    func testDeclinationDifference_isNonNegative() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = PeriodDifference.PerformCalculation(
            makeRequest(factor1: .sun, factor2: .moon,
                        endOffset: interval * 2, coordinate: .declination),
            seWrapper: seWrapper)
        for entry in results {
            #expect(entry.difference >= 0.0,
                    "Declination difference \(entry.difference) at JD \(entry.julianDay) is negative")
        }
    }

    @Test("PeriodDifference: distance difference is non-negative")
    func testDistanceDifference_isNonNegative() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = PeriodDifference.PerformCalculation(
            makeRequest(factor1: .sun, factor2: .moon,
                        endOffset: interval * 2, coordinate: .distance),
            seWrapper: seWrapper)
        for entry in results {
            #expect(entry.difference >= 0.0,
                    "Distance difference \(entry.difference) at JD \(entry.julianDay) is negative")
        }
    }

    // MARK: - Determinism

    @Test("PeriodDifference: repeated call with same parameters returns identical results")
    func testDeterminism_sameInputSameOutput() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let request = makeRequest(factor1: .sun, factor2: .moon, coordinate: .longitude)
        let first  = PeriodDifference.PerformCalculation(request, seWrapper: seWrapper)
        let second = PeriodDifference.PerformCalculation(request, seWrapper: seWrapper)
        #expect(first.count == second.count)
        #expect(abs(first[0].difference - second[0].difference) < delta)
    }
}
