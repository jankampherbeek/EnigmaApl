// VspOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Coordinates the Venus Star Point calculation and formats results for display.
struct VspOrchestrator {

    private init() {}

    /// Returns the five VSP positions for the given birth Julian Day.
    static func calculate(birthJd: Double) -> [PresentableVspPosition] {
        let se        = SEWrapper()
        let phenomena = VspCalculator.calculateVspJds(birthJd: birthJd, seWrapper: se)

        return phenomena.enumerated().map { index, item in
            let (jd, phenomenon) = item
            let longitude = se.calculateFactorPosition(julianDay: jd, factor: 0, flags: 2)?.mainPos ?? 0.0
            let dt        = se.dateFromJulianDay(jd)
            return PresentableVspPosition(
                sequenceId: index + 1,
                phenomenon: phenomenon,
                dateText:   formatDateTime(dt),
                longitude:  longitude
            )
        }
    }

    // MARK: - Helpers

    private static func formatDateTime(_ dt: AstronomicalDateTime) -> String {
        String(format: "%04d/%02d/%02d %02d:%02d:%02d",
               dt.Date.Year, dt.Date.Month, dt.Date.Day,
               dt.Time.Hour, dt.Time.Minute, dt.Time.Second)
    }
}
