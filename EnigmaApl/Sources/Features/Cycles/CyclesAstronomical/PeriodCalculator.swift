// PeriodCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates a single coordinate for one factor across a time period at regular intervals.
public struct PeriodCalculator {

    private init() {}

    /// Calculates positions for a single factor at evenly spaced Julian Day steps.
    /// - Parameters:
    ///   - request: The PeriodCalculatorRequest describing the factor, interval, time range,
    ///              and coordinate to calculate.
    ///   - seWrapper: SEWrapper instance. Must be provided to ensure thread-safety with Swiss
    ///                Ephemeris. For production use the app-level instance; for tests use
    ///                SEWrapperTestCoordinator.shared.getSEWrapper().
    /// - Returns: A list of (julianDay, position) tuples in chronological order, one entry
    ///            per step from JdStart up to and including JdEnd.
    public static func PerformCalculation(
        _ request: PeriodCalculatorRequest,
        seWrapper: SEWrapper
    ) -> [(julianDay: Double, position: Double)] {

        let config = CalculationConfig(houseSystem: .noHouses, observerPosition: request.ObserverPosition)
        var results: [(julianDay: Double, position: Double)] = []
        var jd = request.JdStart

        while jd <= request.JdEnd {
            let calcRequest = CalcRequest(
                JulianDay: jd,
                FactorsToUse: [request.Factor],
                HouseSystem: HouseSystems.noHouses.rawValue,
                Latitude: 0.0,
                Longitude: 0.0,
                Height: 0.0,
                calculationConfig: config
            )
            let result = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
                calcRequest,
                coordinate: request.Coordinate,
                seWrapper: seWrapper
            )
            results.append(result)
            jd += request.Interval
        }

        return results
    }
}
