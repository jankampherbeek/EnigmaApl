// WavesCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates a "wave value" across a time period based on the total pairwise
/// separation of a set of slow-moving planets for a given coordinate.
///
/// Three cycle types are supported:
/// - **Saturn** (default): Saturn, Uranus, Neptune, Pluto — 6 pairs.
/// - **Jupiter**: Jupiter, Saturn, Uranus, Neptune, Pluto — 10 pairs.
/// - **Uranus**: Uranus, Neptune, Pluto — 3 pairs.
///
/// For longitude and right ascension the pairwise distance is the shortest arc (0°–180°).
/// For all other coordinates (latitude, declination, distance) it is the absolute difference.
/// All pairwise distances are summed to produce a single WaveValue for each time step.
public struct WavesCalculator {

    private init() {}

    /// Returns the planet list for the given cycle type.
    /// Only `.jupiter`, `.saturn`, and `.uranus` are valid; any other value falls back to Saturn.
    private static func planets(for cycleType: Factors) -> [Factors] {
        switch cycleType {
        case .jupiter:
            return [.jupiter, .saturn, .uranus, .neptune, .pluto]
        case .uranus:
            return [.uranus, .neptune, .pluto]
        default:
            if cycleType != .saturn {
                Logger.log.warning("WavesCalculator: unsupported cycleType \(cycleType), falling back to Saturn cycle.")
            }
            return [.saturn, .uranus, .neptune, .pluto]
        }
    }

    /// Calculates the wave value using a WavesRequest.
    public static func PerformCalculation(
        _ request: WavesRequest,
        seWrapper: SEWrapper
    ) -> [(julianDay: Double, waveValue: Double)] {
        PerformCalculation(
            startJdNr: request.JdStart,
            endJdNr: request.JdEnd,
            interval: request.Interval,
            cycleType: request.CycleType,
            coordinate: request.Coordinate,
            observerPosition: request.ObserverPosition,
            seWrapper: seWrapper
        )
    }

    /// Calculates the wave value at each step between two Julian Day numbers.
    /// - Parameters:
    ///   - startJdNr: Julian Day number for the start of the period.
    ///   - endJdNr: Julian Day number for the end of the period (inclusive).
    ///   - interval: Step size in days between successive calculations.
    ///   - cycleType: The planet that defines the cycle. Must be `.jupiter`, `.saturn`, or `.uranus`.
    ///                Defaults to `.saturn`.
    ///   - coordinate: The coordinate to calculate for each planet. Defaults to `.longitude`.
    ///   - seWrapper: SEWrapper instance. Must be provided to ensure thread-safety with
    ///                Swiss Ephemeris. For production use the app-level instance; for tests
    ///                use SEWrapperTestCoordinator.shared.getSEWrapper().
    /// - Returns: A list of (julianDay, waveValue) tuples in chronological order.
    public static func PerformCalculation(
        startJdNr: Double,
        endJdNr: Double,
        interval: Int,
        cycleType: Factors = .saturn,
        coordinate: Coordinates = .longitude,
        observerPosition: ObserverPositions = .geoCentric,
        seWrapper: SEWrapper
    ) -> [(julianDay: Double, waveValue: Double)] {

        let config = CalculationConfig(houseSystem: .noHouses, observerPosition: observerPosition)
        let step = Double(interval)
        let outerPlanets = planets(for: cycleType)
        var results: [(julianDay: Double, waveValue: Double)] = []
        var jd = startJdNr

        while jd <= endJdNr {
            var positions: [Factors: Double] = [:]
            for factor in outerPlanets {
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
                    calcRequest,
                    coordinate: coordinate,
                    seWrapper: seWrapper
                )
                positions[factor] = position
            }

            var distances: [Double] = []
            for i in 0..<outerPlanets.count {
                for j in (i + 1)..<outerPlanets.count {
                    let p1 = positions[outerPlanets[i]] ?? 0.0
                    let p2 = positions[outerPlanets[j]] ?? 0.0
                    distances.append(computeDifference(p1, p2, coordinate: coordinate))
                }
            }

            let waveValue = distances.reduce(0.0, +)
            results.append((julianDay: jd, waveValue: waveValue))
            jd += step
        }

        return results
    }

    // MARK: - Private helpers

    /// Shortest arc (0°–180°) for cyclic coordinates; absolute difference for linear ones.
    private static func computeDifference(_ p1: Double, _ p2: Double, coordinate: Coordinates) -> Double {
        switch coordinate {
        case .longitude, .rightAscension:
            let diff = abs(p1 - p2).truncatingRemainder(dividingBy: 360.0)
            return diff > 180.0 ? 360.0 - diff : diff
        case .latitude, .declination, .distance:
            return abs(p1 - p2)
        }
    }
}
