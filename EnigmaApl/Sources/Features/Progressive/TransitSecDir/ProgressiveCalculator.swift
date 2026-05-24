// ProgressiveCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Calculates geocentric longitude and declination for a set of factors at a given Julian Day.
/// Used as the shared astronomical core for transits and secondary directions.
public struct ProgressiveCalculator {

    private init() {}

    /// Calculates geocentric longitude and declination for each factor at the Julian Day in the request.
    ///
    /// All settings are derived from `calculationConfig` with one override: if the observer position is
    /// topocentric it is silently replaced with geocentric, since progressive techniques are always geocentric.
    /// Oblique-longitude projection is also disabled (not applicable to progressives).
    ///
    /// - Parameters:
    ///   - request: The Julian Day for the progressive date.
    ///   - calculationConfig: The user's active calculation configuration.
    ///   - factors: Factors to calculate — pass `TransitsConfig.factors` or
    ///     `SecondaryDirectionsConfig.factors` depending on the technique.
    ///   - seWrapper: Swiss Ephemeris wrapper. Use the app-level instance for production;
    ///     use `SEWrapperTestCoordinator.shared.getSEWrapper()` in tests.
    /// - Returns: Longitude and declination for every successfully calculated factor.
    public static func performCalculation(
        _ request: ProgressiveCalcRequest,
        calculationConfig: CalculationConfig,
        factors: [Factors],
        seWrapper: SEWrapper
    ) -> [Factors: ProgressivePosition] {

        let effectiveObserverPosition: ObserverPositions =
            calculationConfig.observerPosition == .topoCentric ? .geoCentric : calculationConfig.observerPosition

        let effectiveConfig = CalculationConfig(
            houseSystem: .noHouses,
            ayanamsha: calculationConfig.ayanamsha,
            observerPosition: effectiveObserverPosition,
            projectionType: .twoDimensional,
            blackMoonCorrectionType: calculationConfig.blackMoonCorrectionType,
            lunarNodeType: calculationConfig.lunarNodeType,
            lotsType: calculationConfig.lotsType,
            stationaryPercentage: calculationConfig.stationaryPercentage,
            slowPercentage: calculationConfig.slowPercentage
        )

        let calcRequest = CalcRequest(
            JulianDay: request.julianDay,
            FactorsToUse: factors,
            HouseSystem: HouseSystems.noHouses.rawValue,
            Latitude: 0.0,
            Longitude: 0.0,
            Height: 0.0,
            calculationConfig: effectiveConfig
        )

        let fullChart = AstronCalcOrchestrator.PerformCalculation(calcRequest, seWrapper: seWrapper)

        var results: [Factors: ProgressivePosition] = [:]
        for (factor, position) in fullChart.Coordinates {
            let longitude = position.ecliptical.first?.mainPos ?? 0.0
            let declination = position.equatorial.first?.deviation ?? 0.0
            results[factor] = ProgressivePosition(longitude: longitude, declination: declination)
        }
        return results
    }
}
