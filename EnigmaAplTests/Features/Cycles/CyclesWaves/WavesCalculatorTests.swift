// WavesCalculatorTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

@MainActor
struct WavesCalculatorTests {

    // MARK: - Shared test parameters

    /// JD for 2010-01-01 0:00 UT — consistent with other SE-dependent tests in this suite.
    private let baseJd   = 2455197.5
    private let interval = 10
    private let delta    = 1e-6

    // MARK: - Result count and JD sequence

    @Test("WavesCalculator: single step produces exactly one result")
    func testSingleStep_resultCount() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = WavesCalculator.PerformCalculation(
            startJdNr: baseJd, endJdNr: baseJd, interval: interval, seWrapper: seWrapper)
        #expect(results.count == 1)
    }

    @Test("WavesCalculator: three-step period produces exactly three results")
    func testThreeSteps_resultCount() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = WavesCalculator.PerformCalculation(
            startJdNr: baseJd,
            endJdNr: baseJd + Double(interval * 2),
            interval: interval,
            seWrapper: seWrapper)
        #expect(results.count == 3)
    }

    @Test("WavesCalculator: Julian day values follow the correct sequence")
    func testMultipleSteps_julianDaySequence() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = WavesCalculator.PerformCalculation(
            startJdNr: baseJd,
            endJdNr: baseJd + Double(interval * 2),
            interval: interval,
            seWrapper: seWrapper)
        for (index, entry) in results.enumerated() {
            let expectedJd = baseJd + Double(index * interval)
            #expect(abs(entry.julianDay - expectedJd) < delta,
                    "Step \(index): expected JD \(expectedJd), got \(entry.julianDay)")
        }
    }

    @Test("WavesCalculator: endJdNr exactly on a step boundary is included")
    func testEndJdExactlyOnStep_isIncluded() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let endJd = baseJd + Double(interval * 2)   // exactly on the third step
        let results = WavesCalculator.PerformCalculation(
            startJdNr: baseJd, endJdNr: endJd, interval: interval, seWrapper: seWrapper)
        #expect(results.count == 3)
        #expect(abs(results.last!.julianDay - endJd) < delta)
    }

    @Test("WavesCalculator: endJdNr between steps stops before exceeding it")
    func testEndJdBetweenSteps_stopsBeforeExceeding() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        // end falls halfway between step 2 and step 3 → only 3 results
        let endJd = baseJd + Double(interval * 2) + Double(interval) / 2.0
        let results = WavesCalculator.PerformCalculation(
            startJdNr: baseJd, endJdNr: endJd, interval: interval, seWrapper: seWrapper)
        #expect(results.count == 3)
        #expect(results.last!.julianDay <= endJd)
    }

    @Test("WavesCalculator: startJdNr after endJdNr returns empty list")
    func testStartAfterEnd_returnsEmpty() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = WavesCalculator.PerformCalculation(
            startJdNr: baseJd + 1.0, endJdNr: baseJd, interval: interval, seWrapper: seWrapper)
        #expect(results.isEmpty)
    }

    // MARK: - Julian day preservation

    @Test("WavesCalculator: first result Julian day equals startJdNr")
    func testFirstResult_julianDayEqualsStart() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = WavesCalculator.PerformCalculation(
            startJdNr: baseJd, endJdNr: baseJd, interval: interval, seWrapper: seWrapper)
        #expect(abs(results[0].julianDay - baseJd) < delta)
    }

    // MARK: - Wave value range

    @Test("WavesCalculator: wave value is non-negative")
    func testWaveValue_isNonNegative() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = WavesCalculator.PerformCalculation(
            startJdNr: baseJd,
            endJdNr: baseJd + Double(interval * 2),
            interval: interval,
            seWrapper: seWrapper)
        for entry in results {
            #expect(entry.waveValue >= 0.0,
                    "waveValue \(entry.waveValue) at JD \(entry.julianDay) is negative")
        }
    }

    @Test("WavesCalculator: wave value does not exceed 180°")
    func testWaveValue_doesNotExceed180() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let results = WavesCalculator.PerformCalculation(
            startJdNr: baseJd,
            endJdNr: baseJd + Double(interval * 2),
            interval: interval,
            seWrapper: seWrapper)
        for entry in results {
            #expect(entry.waveValue <= 180.0,
                    "waveValue \(entry.waveValue) at JD \(entry.julianDay) exceeds 180°")
        }
    }

    // MARK: - Correctness against manual computation

    /// Computes the same wave value independently using PerformSingleCoordinateCalculation
    /// for each outer planet and verifies that WavesCalculator produces an identical result.
    @Test("WavesCalculator: single-step result matches manual pairwise mean computation")
    func testSingleStep_matchesManualComputation() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()

        let results = WavesCalculator.PerformCalculation(
            startJdNr: baseJd, endJdNr: baseJd, interval: interval, seWrapper: seWrapper)
        #expect(results.count == 1)

        // Independently fetch each outer planet's longitude
        let planets: [Factors] = [.saturn, .uranus, .neptune, .pluto]
        let config = CalculationConfig(houseSystem: .noHouses)
        var longitudes: [Factors: Double] = [:]
        for factor in planets {
            let request = CalcRequest(
                JulianDay: baseJd,
                FactorsToUse: [factor],
                HouseSystem: HouseSystems.noHouses.rawValue,
                Latitude: 0.0,
                Longitude: 0.0,
                Height: 0.0,
                calculationConfig: config
            )
            let (_, lon) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
                request, coordinate: .longitude, seWrapper: seWrapper)
            longitudes[factor] = lon
        }

        // Compute the six pairwise shortest distances and their mean
        var distances: [Double] = []
        for i in 0..<planets.count {
            for j in (i + 1)..<planets.count {
                let lon1 = longitudes[planets[i]] ?? 0.0
                let lon2 = longitudes[planets[j]] ?? 0.0
                let diff = abs(lon1 - lon2).truncatingRemainder(dividingBy: 360.0)
                distances.append(diff > 180.0 ? 360.0 - diff : diff)
            }
        }
        let expectedWave = distances.reduce(0.0, +) / Double(distances.count)

        #expect(abs(results[0].waveValue - expectedWave) < delta,
                "Expected wave value \(expectedWave), got \(results[0].waveValue)")
    }

    /// Verifies that the wave value is deterministic: two identical calls return the same result.
    @Test("WavesCalculator: repeated call with same parameters returns identical results")
    func testDeterminism_sameInputSameOutput() {
        let seWrapper = SEWrapperTestCoordinator.shared.getSEWrapper()
        let first = WavesCalculator.PerformCalculation(
            startJdNr: baseJd, endJdNr: baseJd, interval: interval, seWrapper: seWrapper)
        let second = WavesCalculator.PerformCalculation(
            startJdNr: baseJd, endJdNr: baseJd, interval: interval, seWrapper: seWrapper)
        #expect(first.count == second.count)
        #expect(abs(first[0].waveValue - second[0].waveValue) < delta)
    }
}
