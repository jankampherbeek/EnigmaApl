// SkippedFactorsTests.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Testing
import Foundation
@testable import EnigmaApl

/// Factors without meaning for the observer position are skipped and reported in `skippedFactors`.
@MainActor
@Suite(.tags(.integration))
struct SkippedFactorsTests {

    private func calculate(_ factors: [Factors], observer: ObserverPositions) -> FullChart {
        let config = CalculationConfig(houseSystem: .placidus, ayanamsha: .tropical, observerPosition: observer)
        let request = CalcRequest(
            JulianDay: 2461041.5,
            FactorsToUse: factors,
            HouseSystem: 80,
            Latitude: 52.218056,
            Longitude: 6.895556,
            Height: 0.0,
            calculationConfig: config
        )
        return AstronCalcOrchestrator.PerformCalculation(request, seWrapper: SEWrapperTestCoordinator.shared.getSEWrapper())
    }

    @Test func heliocentricChartReportsSunMoonAndNodeAsSkipped() {
        let chart = calculate([.sun, .moon, .mercury, .earth, .northNode], observer: .helioCentric)
        #expect(chart.skippedFactors == [.sun, .moon, .northNode])
        #expect(chart.omittedFactors.isEmpty)
        #expect(chart.Coordinates[.sun] == nil)
        #expect(chart.Coordinates[.earth] != nil)
    }

    @Test func geocentricChartReportsNothingAsSkipped() {
        // Earth has no geocentric position and is skipped, but that needs no message.
        let chart = calculate([.sun, .moon, .earth], observer: .geoCentric)
        #expect(chart.skippedFactors.isEmpty)
        #expect(chart.Coordinates[.earth] == nil)
    }
}
