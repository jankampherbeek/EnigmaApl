// SolarReturnModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

/// Shared model for SolarInputScreen (right column) and SolarResultsScreen (center column).
/// Created once in AppComposition and injected as an EnvironmentObject.
@MainActor
final class SolarReturnModel: ObservableObject {

    @Published private(set) var positions: [Factors: ProgressivePosition] = [:]
    @Published private(set) var solarFullChart: FullChart?
    @Published private(set) var solarJd: Double?
    @Published private(set) var solarDateText: String = ""
    @Published private(set) var radixDateText: String = ""
    @Published private(set) var radixSunLongitude: Double?
    @Published private(set) var solarSunLongitude: Double?
    @Published var errorMessage: String?

    // Input parameters retained for display in results
    private(set) var age: Int = 0
    private(set) var useSidereal: Bool = false
    private(set) var geoLong: Double = 0.0
    private(set) var geoLat: Double = 0.0

    var hasResults: Bool { !positions.isEmpty }

    /// Runs the solar return calculation.
    /// - Parameters:
    ///   - age: Age in whole years.
    ///   - useSidereal: True for sidereal return (Fagan ayanamsha).
    ///   - geoLong: Geographic longitude (negative = West).
    ///   - geoLat: Geographic latitude (negative = South).
    ///   - chart: The radix FullChart.
    ///   - factors: Factors to calculate at the solar return.
    ///   - calculationConfig: The active calculation configuration.
    func calculate(
        age: Int,
        useSidereal: Bool,
        geoLong: Double,
        geoLat: Double,
        chart: FullChart,
        factors: [Factors],
        calculationConfig: CalculationConfig
    ) {
        errorMessage = nil
        self.age = age
        self.useSidereal = useSidereal
        self.geoLong = geoLong
        self.geoLat = geoLat

        let seWrapper = SEWrapper()
        let radixDt   = seWrapper.dateFromJulianDay(chart.JulianDay)
        radixDateText = String(format: "%04d/%02d/%02d %02d:%02d:%02d UT",
                               radixDt.Date.Year, radixDt.Date.Month, radixDt.Date.Day,
                               radixDt.Time.Hour, radixDt.Time.Minute, radixDt.Time.Second)

        let result = SolarReturnOrchestrator.calculate(
            birthJd:           chart.JulianDay,
            age:               age,
            useSidereal:       useSidereal,
            geoLong:           geoLong,
            geoLat:            geoLat,
            factors:           factors,
            calculationConfig: calculationConfig
        )

        positions            = result.positions
        solarFullChart       = result.solarFullChart
        solarJd              = result.solarJd
        solarDateText        = result.dateText
        radixSunLongitude    = result.radixSunLongitude
        solarSunLongitude    = result.solarSunLongitude
    }

    func clear() {
        positions         = [:]
        solarFullChart    = nil
        solarJd           = nil
        solarDateText     = ""
        radixDateText     = ""
        radixSunLongitude = nil
        solarSunLongitude = nil
        errorMessage      = nil
    }
}
