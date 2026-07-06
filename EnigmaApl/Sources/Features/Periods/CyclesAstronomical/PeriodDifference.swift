// PeriodDifference.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates the difference in a single coordinate between pairs of celestial factors
/// across a time period at regular intervals.
///
/// For longitude and right ascension the result is the shortest angular distance
/// (0°–180°). For latitude, declination, and distance the result is the absolute
/// difference between the two positions.
public struct PeriodDifference {

    private init() {}

    /// Calculates the positional difference for each factor pair at each step.
    /// - Parameters:
    ///   - request: The PeriodDifferenceRequest describing the factor pairs, interval,
    ///              time range, and coordinate to compare.
    ///   - seWrapper: SEWrapper instance. Must be provided to ensure thread-safety with
    ///                Swiss Ephemeris. For production use the app-level instance; for tests
    ///                use SEWrapperTestCoordinator.shared.getSEWrapper().
    /// - Returns: One time series per factor pair, in the same order as request.FactorPairs.
    ///            Each series contains (julianDay, difference) tuples from JdStart to JdEnd.
    public static func PerformCalculation(
        _ request: PeriodDifferenceRequest,
        seWrapper: SEWrapper
    ) -> [[(julianDay: Double, difference: Double)]] {

        let config = CalculationConfig(houseSystem: .noHouses, observerPosition: request.ObserverPosition)
        var results: [[(julianDay: Double, difference: Double)]] =
            Array(repeating: [], count: request.FactorPairs.count)

        var jd = request.JdStart
        while jd <= request.JdEnd {
            for (index, pair) in request.FactorPairs.enumerated() {
                let pos1 = calculatePosition(
                    factor: pair.factor1, jd: jd,
                    coordinate: request.Coordinate, config: config, seWrapper: seWrapper)
                let pos2 = calculatePosition(
                    factor: pair.factor2, jd: jd,
                    coordinate: request.Coordinate, config: config, seWrapper: seWrapper)
                let difference = computeDifference(pos1, pos2, coordinate: request.Coordinate)
                results[index].append((julianDay: jd, difference: difference))
            }
            jd += request.Interval
        }

        return results
    }

    // MARK: - Private helpers

    private static func calculatePosition(
        factor: Factors,
        jd: Double,
        coordinate: Coordinates,
        config: CalculationConfig,
        seWrapper: SEWrapper
    ) -> Double {
        let calcRequest = CalcRequest(
            JulianDay: jd,
            FactorsToUse: [factor],
            HouseSystem: HouseSystems.noHouses.rawValue,
            Latitude: 0.0,
            Longitude: 0.0,
            Height: 0.0,
            calculationConfig: config
        )
        let (_, position) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
            calcRequest, coordinate: coordinate, seWrapper: seWrapper)
        return position
    }

    /// Returns the difference between two positional values.
    /// Longitude and right ascension use the shortest angular distance (0°–180°).
    /// All other coordinates use the absolute difference.
    private static func computeDifference(
        _ pos1: Double,
        _ pos2: Double,
        coordinate: Coordinates
    ) -> Double {
        switch coordinate {
        case .longitude, .rightAscension:
            let diff = abs(pos1 - pos2).truncatingRemainder(dividingBy: 360.0)
            return diff > 180.0 ? 360.0 - diff : diff
        case .latitude, .declination, .distance:
            return abs(pos1 - pos2)
        }
    }
}
