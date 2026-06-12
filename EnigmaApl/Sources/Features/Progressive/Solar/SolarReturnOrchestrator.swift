// SolarReturnOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

private let TROPICAL_YEAR_IN_DAYS: Double = 365.242199074
private let SE_SUN: Int = 0
private let SE_FLAGS_TROPICAL: Int = 2 + 256     // SEFLG_SWIEPH + SEFLG_SPEED
private let SE_FLAGS_SIDEREAL: Int = 2 + 256 + 65536  // + SEFLG_SIDEREAL
private let FAGAN_AYANAMSHA_ID: Int = 0
private let MAX_ITERATIONS: Int = 1000
private let TARGET_PRECISION: Double = 1e-8   // ~0.01 arc-second
private let MIN_INTERVAL: Double = 1e-12

/// Calculates a solar return: the Julian Day when the Sun returns to its natal longitude,
/// then provides all planet positions at that moment.
struct SolarReturnOrchestrator {

    private init() {}

    struct Result {
        let solarJd: Double
        let dateText: String
        let positions: [Factors: ProgressivePosition]
        let solarFullChart: FullChart
        let radixSunLongitude: Double
        let solarSunLongitude: Double
    }

    /// Calculates the solar return.
    /// - Parameters:
    ///   - birthJd: Julian Day of birth.
    ///   - age: The year of life for which the solar return is calculated.
    ///   - useSidereal: If true, Fagan ayanamsha is applied.
    ///   - geoLong: Longitude of the location (negative = West).
    ///   - geoLat: Latitude of the location (negative = South).
    ///   - factors: Factors (planets, etc.) to calculate at the solar return.
    ///   - calculationConfig: The active calculation config.
    static func calculate(
        birthJd: Double,
        age: Int,
        useSidereal: Bool,
        geoLong: Double,
        geoLat: Double,
        factors: [Factors],
        calculationConfig: CalculationConfig
    ) -> Result {
        let seWrapper = SEWrapper()

        if useSidereal {
            seWrapper.setAyanamsha(idAyanamsha: FAGAN_AYANAMSHA_ID)
        }

        let flags = useSidereal ? SE_FLAGS_SIDEREAL : SE_FLAGS_TROPICAL
        let radixSunLong = seWrapper.calculateFactorPosition(
            julianDay: birthJd, factor: SE_SUN, flags: flags)?.mainPos ?? 0.0

        let estimatedJd = birthJd + Double(age) * TROPICAL_YEAR_IN_DAYS
        let solarJd = findSolarReturnJd(
            estimated: estimatedJd,
            targetLongitude: radixSunLong,
            flags: flags,
            seWrapper: seWrapper
        )

        let solarSunLong = seWrapper.calculateFactorPosition(
            julianDay: solarJd, factor: SE_SUN, flags: flags)?.mainPos ?? 0.0

        let (solarPositions, solarFullChart) = calculatePositions(
            jd: solarJd,
            geoLong: geoLong,
            geoLat: geoLat,
            factors: factors,
            calculationConfig: calculationConfig,
            useSidereal: useSidereal,
            seWrapper: seWrapper
        )

        let dt = seWrapper.dateFromJulianDay(solarJd)
        let dateText = String(format: "%04d/%02d/%02d %02d:%02d:%02d UT",
                              dt.Date.Year, dt.Date.Month, dt.Date.Day,
                              dt.Time.Hour, dt.Time.Minute, dt.Time.Second)

        return Result(
            solarJd: solarJd,
            dateText: dateText,
            positions: solarPositions,
            solarFullChart: solarFullChart,
            radixSunLongitude: radixSunLong,
            solarSunLongitude: solarSunLong
        )
    }

    // MARK: - Binary search

    private static func findSolarReturnJd(
        estimated: Double,
        targetLongitude: Double,
        flags: Int,
        seWrapper: SEWrapper
    ) -> Double {
        let startLong = seWrapper.calculateFactorPosition(
            julianDay: estimated, factor: SE_SUN, flags: flags)?.mainPos ?? 0.0

        var angularDiff = targetLongitude - startLong
        if angularDiff > 180  { angularDiff -= 360 }
        if angularDiff < -180 { angularDiff += 360 }

        let timeDiff = abs(angularDiff)
        var jdLow: Double
        var jdHigh: Double
        if angularDiff < 0 {
            jdHigh = estimated
            jdLow  = estimated - timeDiff
        } else {
            jdLow  = estimated
            jdHigh = estimated + timeDiff
        }

        var counter = 0
        var delta: Double = Double.greatestFiniteMagnitude
        var tempJd = estimated

        repeat {
            counter += 1
            if counter > MAX_ITERATIONS { break }
            if abs(jdHigh - jdLow) < MIN_INTERVAL { break }

            tempJd = (jdLow + jdHigh) / 2.0
            let trialLong = seWrapper.calculateFactorPosition(
                julianDay: tempJd, factor: SE_SUN, flags: flags)?.mainPos ?? 0.0

            var diff = targetLongitude - trialLong
            if diff > 180  { diff -= 360 }
            if diff < -180 { diff += 360 }
            delta = abs(diff)

            if diff < 0 {
                jdHigh = tempJd
            } else {
                jdLow  = tempJd
            }
        } while delta > TARGET_PRECISION

        return tempJd
    }

    // MARK: - Position calculation

    private static func calculatePositions(
        jd: Double,
        geoLong: Double,
        geoLat: Double,
        factors: [Factors],
        calculationConfig: CalculationConfig,
        useSidereal: Bool,
        seWrapper: SEWrapper
    ) -> ([Factors: ProgressivePosition], FullChart) {
        let effectiveConfig: CalculationConfig
        if useSidereal {
            effectiveConfig = CalculationConfig(
                houseSystem:             calculationConfig.houseSystem,
                ayanamsha:               .fagan,
                observerPosition:        calculationConfig.observerPosition,
                projectionType:          calculationConfig.projectionType,
                blackMoonCorrectionType: calculationConfig.blackMoonCorrectionType,
                lunarNodeType:           calculationConfig.lunarNodeType,
                lotsType:                calculationConfig.lotsType,
                stationaryPercentage:    calculationConfig.stationaryPercentage,
                slowPercentage:          calculationConfig.slowPercentage
            )
        } else {
            effectiveConfig = calculationConfig
        }

        let request = CalcRequest(
            JulianDay:         jd,
            FactorsToUse:      factors,
            HouseSystem:       Int(calculationConfig.houseSystem.seId.asciiValue ?? 80),
            Latitude:          geoLat,
            Longitude:         geoLong,
            Height:            0.0,
            calculationConfig: effectiveConfig
        )

        let fullChart = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)

        var results: [Factors: ProgressivePosition] = [:]
        for (factor, position) in fullChart.Coordinates {
            let longitude    = position.ecliptical.first?.mainPos ?? 0.0
            let declination  = position.equatorial.first?.deviation ?? 0.0
            results[factor] = ProgressivePosition(longitude: longitude, declination: declination)
        }
        return (results, fullChart)
    }
}
