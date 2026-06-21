// EphemerisCalculator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

struct EphemerisCalculator {
    private init() {}

    private static let helioExcluded: Set<Factors> = [
        .sun, .moon, .northNode, .apogeeMean, .apogeeKoch, .apogeeDuval, .apogeeInterpolated,
        .perigeeInterpolated, .priapus, .priapusKoch, .priapusDuval, .priapusInterpolated,
        .dragon, .beast, .southNode, .blackSun, .diamond
    ]

    private static let alwaysExcluded: Set<Factors> = [.logTimeScale, .agePoint]

    static func availableFactors(for observerPosition: ObserverPositions) -> [Factors] {
        let positionExcluded: Set<Factors> = observerPosition == .helioCentric
            ? helioExcluded
            : [.earth]
        return Factors.allCases.filter { factor in
            guard !alwaysExcluded.contains(factor) else { return false }
            guard !positionExcluded.contains(factor) else { return false }
            let ct = factor.calculationType
            guard ct != .Mundane && ct != .Lots && ct != .ZodiacFixed && ct != .Unknown else { return false }
            return true
        }
    }

    static func calculate(
        year: Int,
        month: Int,
        factors: [Factors],
        observerPosition: ObserverPositions,
        ayanamsha: Ayanamshas,
        seWrapper: SEWrapper
    ) -> [EphemerisRow] {
        guard !factors.isEmpty else { return [] }

        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!

        guard let range = utcCalendar.range(of: .day, in: .month,
                                             for: utcCalendar.date(from: DateComponents(year: year, month: month))!) else {
            return []
        }

        let midnight = AstronomicalTime(HourDecimal: 0.0)
        let config = CalculationConfig(houseSystem: .noHouses, ayanamsha: ayanamsha, observerPosition: observerPosition)
        var rows: [EphemerisRow] = []

        for day in range {
            let astroDate = AstronomicalDate(Year: year, Month: month, Day: day, Gregorian: true)
            let jd = seWrapper.julianDay(date: astroDate, time: midnight)
            let request = CalcRequest(
                JulianDay: jd,
                FactorsToUse: factors,
                HouseSystem: HouseSystems.noHouses.rawValue,
                Latitude: 0.0,
                Longitude: 0.0,
                Height: 0.0,
                calculationConfig: config
            )
            let chart = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
            rows.append(EphemerisRow(id: day, julianDay: jd, positions: chart.Coordinates))
        }

        return rows
    }
}
