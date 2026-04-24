// SEActor.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Swift actor that serializes all Swiss Ephemeris calls.
/// SE is single-threaded; this actor ensures only one calculation runs at a time,
/// replacing the NSLock approach used elsewhere for research pipeline use.
///
/// Usage:
/// ```swift
/// let actor = SEActor()
/// let chart = try await actor.calculate(input: record, factors: factors, config: calcConfig)
/// ```
public actor SEActor {

    private let seWrapper: SEWrapper

    public init() {
        self.seWrapper = SEWrapper()
    }

    /// Calculates a full chart for one `ResearchInputRecord`.
    /// - Parameters:
    ///   - input: The horoscope input record (date, time, location, offset).
    ///   - factors: The `Factors` to include in the calculation.
    ///   - calcConfig: The `CalculationConfig` for this research project.
    /// - Returns: A `FullChart` with all requested positions.
    public func calculate(
        input: ResearchInputRecord,
        factors: [Factors],
        calcConfig: CalculationConfig
    ) -> FullChart {
        let utHour = utDecimalHour(
            hour: input.hour,
            minute: input.minute,
            second: input.second,
            offset: input.offset
        )
        let date = AstronomicalDate(Year: input.year, Month: input.month, Day: input.day)
        let time = AstronomicalTime(HourDecimal: utHour)
        let julDay = seWrapper.julianDay(date: date, time: time)

        let request = CalcRequest(
            JulianDay: julDay,
            FactorsToUse: factors,
            HouseSystem: calcConfig.houseSystem.rawValue,
            Latitude: input.geoLat,
            Longitude: input.geoLon,
            Height: 0,
            calculationConfig: calcConfig
        )
        return AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
    }

    // MARK: - Helpers

    /// Converts local h/m/s + UTC offset to a UT decimal hour.
    private func utDecimalHour(hour: Int, minute: Int, second: Int, offset: Double) -> Double {
        let localDecimal = Double(hour) + Double(minute) / 60.0 + Double(second) / 3600.0
        return localDecimal - offset
    }
}
