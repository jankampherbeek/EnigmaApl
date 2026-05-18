// WavesCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates a "wave value" across a time period based on the total pairwise angular
/// separation of a set of slow-moving planets.
///
/// Three cycle types are supported:
/// - **Saturn** (default): Saturn, Uranus, Neptune, Pluto — 6 pairs.
/// - **Jupiter**: Jupiter, Saturn, Uranus, Neptune, Pluto — 10 pairs.
/// - **Uranus**: Uranus,  Neptune, Pluto — 4 pairs.
///
/// For each time step the ecliptic longitudes of the planets are calculated.
/// All pairwise shortest angular distances (0°–180°) are summed to produce
/// a single WaveValue for that moment.
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

    /// Calculates the wave value at each step between two Julian Day numbers.
    /// - Parameters:
    ///   - startJdNr: Julian Day number for the start of the period.
    ///   - endJdNr: Julian Day number for the end of the period (inclusive).
    ///   - interval: Step size in days between successive calculations.
    ///   - cycleType: The planet that defines the cycle. Must be `.jupiter`, `.saturn`, or `.uranus`.
    ///                Defaults to `.saturn`.
    ///   - seWrapper: SEWrapper instance. Must be provided to ensure thread-safety with
    ///                Swiss Ephemeris. For production use the app-level instance; for tests
    ///                use SEWrapperTestCoordinator.shared.getSEWrapper().
    /// - Returns: A list of (julianDay, waveValue) tuples in chronological order.
    public static func PerformCalculation(
        startJdNr: Double,
        endJdNr: Double,
        interval: Int,
        cycleType: Factors = .saturn,
        seWrapper: SEWrapper
    ) -> [(julianDay: Double, waveValue: Double)] {

        let config = CalculationConfig(houseSystem: .noHouses)
        let step = Double(interval)
        let outerPlanets = planets(for: cycleType)
        var results: [(julianDay: Double, waveValue: Double)] = []
        var jd = startJdNr

        while jd <= endJdNr {
            // Calculate ecliptic longitude for each planet at this JD
            var longitudes: [Factors: Double] = [:]
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
                let (_, longitude) = AstronCalcOrchestrator.PerformSingleCoordinateCalculation(
                    calcRequest,
                    coordinate: .longitude,
                    seWrapper: seWrapper
                )
                longitudes[factor] = longitude
            }

            // Compute shortest angular distance for all pairs and sum them
            var distances: [Double] = []
            for i in 0..<outerPlanets.count {
                for j in (i + 1)..<outerPlanets.count {
                    let lon1 = longitudes[outerPlanets[i]] ?? 0.0
                    let lon2 = longitudes[outerPlanets[j]] ?? 0.0
                    distances.append(shortestAngularDistance(lon1, lon2))
                }
            }

            let waveValue = distances.reduce(0.0, +)
            results.append((julianDay: jd, waveValue: waveValue))
            jd += step
        }

        return results
    }

    // MARK: - Private helpers

    /// Returns the shortest angular distance between two ecliptic longitudes (0°–180°).
    private static func shortestAngularDistance(_ lon1: Double, _ lon2: Double) -> Double {
        let diff = abs(lon1 - lon2).truncatingRemainder(dividingBy: 360.0)
        return diff > 180.0 ? 360.0 - diff : diff
    }
}
