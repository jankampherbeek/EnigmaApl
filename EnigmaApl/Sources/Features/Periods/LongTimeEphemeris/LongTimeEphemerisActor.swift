// LongTimeEphemerisActor.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

actor LongTimeEphemerisActor {
    private let seWrapper = SEWrapper()

    func calculateBatch(
        jdValues: [Double],
        startIndex: Int,
        factors: [Factors],
        coordinate: EphemerisCoordinate,
        observerPosition: ObserverPositions,
        ayanamsha: Ayanamshas
    ) -> [LongTimeEphemerisRow] {
        guard !Task.isCancelled else { return [] }

        let config = CalculationConfig(
            houseSystem: .noHouses,
            ayanamsha: ayanamsha,
            observerPosition: observerPosition
        )
        var results: [LongTimeEphemerisRow] = []
        results.reserveCapacity(jdValues.count)

        for (batchIdx, jd) in jdValues.enumerated() {
            guard !Task.isCancelled else { break }

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

            var values: [Factors: Double] = [:]
            for factor in factors {
                if let pos = chart.Coordinates[factor],
                   let val = extractValue(pos: pos, coordinate: coordinate) {
                    values[factor] = val
                }
            }

            let dt = seWrapper.dateFromJulianDay(jd)
            let dateStr = formatDateTime(dt)

            results.append(LongTimeEphemerisRow(
                id: startIndex + batchIdx,
                julianDay: jd,
                dateTimeString: dateStr,
                values: values
            ))
        }

        return results
    }

    private func extractValue(pos: FullFactorPosition, coordinate: EphemerisCoordinate) -> Double? {
        switch coordinate {
        case .longitude:        return pos.ecliptical.first?.mainPos
        case .latitude:         return pos.ecliptical.first?.deviation
        case .rightAscension:   return pos.equatorial.first?.mainPos
        case .declination:      return pos.equatorial.first?.deviation
        case .distance:         return pos.ecliptical.first?.distance
        case .speedLongitude:   return pos.ecliptical.first?.mainPosSpeed
        case .speedDeclination: return pos.equatorial.first?.deviationSpeed
        }
    }

    private func formatDateTime(_ dt: AstronomicalDateTime) -> String {
        let y = dt.Date.Year
        let yearStr = (y >= 0 && y <= 9999)
            ? String(format: "%04d", y)
            : String(y)
        return String(
            format: "%@/%02d/%02d %02d:%02d:%02d",
            yearStr,
            dt.Date.Month, dt.Date.Day,
            dt.Time.Hour, dt.Time.Minute, dt.Time.Second
        )
    }
}
