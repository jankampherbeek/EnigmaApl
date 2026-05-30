// RadixInputModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

final class RadixInputModel: ObservableObject {
    struct Input {
        let astronomicalYear: Int
        let month: Int
        let day: Int
        let gregorian: Bool
        let hour: Int
        let minute: Int
        let second: Int
        let offsetHour: Int
        let offsetMinute: Int
        let offsetSecond: Int
        let utOffsetEarlier: Bool
        let dstActive: Bool
        let latitudeDegrees: Int
        let latitudeMinutes: Int
        let latitudeSeconds: Int
        let latitudeSouth: Bool
        let longitudeDegrees: Int
        let longitudeMinutes: Int
        let longitudeSeconds: Int
        let longitudeWest: Bool
        var factorsToUse: [Factors] = [
            .sun, .moon, .mercury, .venus, .mars,
            .jupiter, .saturn, .uranus, .neptune, .pluto
        ]
        var calculationConfig: CalculationConfig = CalculationConfig()
    }

    @Published private(set) var lastRequest: CalcRequest?
    @Published private(set) var lastChart: FullChart?
    @Published private(set) var lastError: String?

    private let seWrapper = SEWrapper()

    func calculate(from input: Input) {
        let dateValidation = AstronomicalDateValidation.validateDateComponents(
            year: input.astronomicalYear,
            month: input.month,
            day: input.day,
            gregorian: input.gregorian
        )

        guard dateValidation.isValid else {
            lastRequest = nil
            lastChart = nil
            lastError = dateValidation.message ?? "Invalid date"
            return
        }

        let localDate = AstronomicalDate(
            Year: input.astronomicalYear,
            Month: input.month,
            Day: input.day,
            Gregorian: input.gregorian
        )
        let localTime = AstronomicalTime(Hour: input.hour, Minute: input.minute, Second: input.second)
        let localJulianDay = seWrapper.julianDay(date: localDate, time: localTime)

        let offsetSeconds = Double((input.offsetHour * 3600) + (input.offsetMinute * 60) + input.offsetSecond)
        let utOffsetSign = input.utOffsetEarlier ? -1.0 : 1.0
        let dstSeconds = input.dstActive ? -3600.0 : 0.0
        let utJulianDay = localJulianDay + ((utOffsetSign * offsetSeconds + dstSeconds) / 86_400.0)

        let request = CalcRequest(
            JulianDay: utJulianDay,
            FactorsToUse: input.factorsToUse,
            HouseSystem: Int(input.calculationConfig.houseSystem.seId.asciiValue ?? 80),
            Latitude: Self.dmsToDecimal(
                degrees: input.latitudeDegrees,
                minutes: input.latitudeMinutes,
                seconds: input.latitudeSeconds,
                negative: input.latitudeSouth
            ),
            Longitude: Self.dmsToDecimal(
                degrees: input.longitudeDegrees,
                minutes: input.longitudeMinutes,
                seconds: input.longitudeSeconds,
                negative: input.longitudeWest
            ),
            Height: 0.0,
            calculationConfig: input.calculationConfig
        )

        let chart = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        lastRequest = request
        lastChart = chart
        lastError = nil
    }

    private static func dmsToDecimal(degrees: Int, minutes: Int, seconds: Int, negative: Bool) -> Double {
        let absoluteValue = Double(degrees) + (Double(minutes) / 60.0) + (Double(seconds) / 3600.0)
        return negative ? -absoluteValue : absoluteValue
    }
}
