// WavesCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates a "wave value" across a time period based on the mean pairwise angular
/// separation of the four outer planets (Saturn, Uranus, Neptune, Pluto).
///
/// For each time step the ecliptic longitudes of the four planets are calculated.
/// All six pairwise shortest angular distances (0°–180°) are then averaged to produce
/// a single WaveValue for that moment.
public struct WavesCalculator {

    private init() {}

    /// The four outer planets used in the wave calculation.
    private static let outerPlanets: [Factors] = [.saturn, .uranus, .neptune, .pluto]

    /// Calculates the wave value at each step between two Julian Day numbers.
    /// - Parameters:
    ///   - startJdNr: Julian Day number for the start of the period.
    ///   - endJdNr: Julian Day number for the end of the period (inclusive).
    ///   - interval: Step size in days between successive calculations.
    ///   - seWrapper: SEWrapper instance. Must be provided to ensure thread-safety with
    ///                Swiss Ephemeris. For production use the app-level instance; for tests
    ///                use SEWrapperTestCoordinator.shared.getSEWrapper().
    /// - Returns: A list of (julianDay, waveValue) tuples in chronological order.
    public static func PerformCalculation(
        startJdNr: Double,
        endJdNr: Double,
        interval: Int,
        seWrapper: SEWrapper
    ) -> [(julianDay: Double, waveValue: Double)] {

        let config = CalculationConfig(houseSystem: .noHouses)
        let step = Double(interval)
        var results: [(julianDay: Double, waveValue: Double)] = []
        var jd = startJdNr

        while jd <= endJdNr {
            // Calculate ecliptic longitude for each outer planet at this JD
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

            // Compute shortest angular distance for all 6 pairs and average them
            var distances: [Double] = []
            for i in 0..<outerPlanets.count {
                for j in (i + 1)..<outerPlanets.count {
                    let lon1 = longitudes[outerPlanets[i]] ?? 0.0
                    let lon2 = longitudes[outerPlanets[j]] ?? 0.0
                    distances.append(shortestAngularDistance(lon1, lon2))
                }
            }

            let waveValue = distances.reduce(0.0, +) / Double(distances.count)
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
