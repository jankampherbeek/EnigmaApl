// NoonPositions.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Ecliptical and equatorial coordinates extracted from a full chart calculation.
public struct NoonPositionResult {
    /// Ecliptical longitude in decimal degrees (0–360).
    public let longitude: Double
    /// Ecliptical latitude in decimal degrees (positive = north).
    public let latitude: Double
    /// Equatorial declination in decimal degrees (positive = north).
    public let declination: Double
}

/// Calculates the positions of Sun, Moon, and Uranus at noon UT for a given date.
///
/// Always uses tropical zodiac, geocentric observer position, and two-dimensional projection.
/// Requires an ``SEWrapper`` instance for thread-safe Swiss Ephemeris access.
public struct NoonPositions {

    private static let noonTime = AstronomicalTime(Hour: 12, Minute: 0, Second: 0)

    private static let calcConfig = CalculationConfig(
        ayanamsha: .tropical,
        observerPosition: .geoCentric,
        projectionType: .twoDimensional
    )

    private static let factorsToUse: [Factors] = [.sun, .moon, .uranus]

    /// Calculates ecliptical longitude, ecliptical latitude, and declination for
    /// Sun, Moon, and Uranus at 12:00:00 UT on the supplied date.
    ///
    /// - Parameters:
    ///   - date: The date for which noon positions are calculated (Gregorian by default).
    ///   - seWrapper: Swiss Ephemeris wrapper. For production use the app-level instance;
    ///                for tests use ``SEWrapperTestCoordinator/shared``.
    /// - Returns: A dictionary mapping each of the three ``Factors`` (.sun, .moon, .uranus)
    ///            to its ``NoonPositionResult``, or `nil` for any factor whose data is missing.
    public static func calcNoonPositions(
        date: AstronomicalDate,
        seWrapper: SEWrapper
    ) -> [Factors: NoonPositionResult] {

        let julianDay = seWrapper.julianDay(date: date, time: noonTime)

        // HouseSystem expects the ASCII value of the SE house-system character.
        // noHouses uses 'W' (whole-sign placeholder) = 87; houses are not needed here.
        let noHousesId = Int(Character("W").asciiValue ?? 87)

        let request = CalcRequest(
            JulianDay: julianDay,
            FactorsToUse: factorsToUse,
            HouseSystem: noHousesId,
            Latitude: 0.0,
            Longitude: 0.0,
            Height: 0.0,
            calculationConfig: calcConfig
        )

        let chart = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)

        var results: [Factors: NoonPositionResult] = [:]
        for factor in factorsToUse {
            guard
                let position = chart.Coordinates[factor],
                let ecliptical = position.ecliptical.first,
                let equatorial = position.equatorial.first
            else { continue }

            results[factor] = NoonPositionResult(
                longitude: ecliptical.mainPos,
                latitude: ecliptical.deviation,
                declination: equatorial.deviation
            )
        }
        return results
    }
}
