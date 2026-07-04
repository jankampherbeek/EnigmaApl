// ParansModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

@MainActor
final class ParansModel: ObservableObject {
    @Published var result: ParansResult?
    @Published var isCalculating = false
    @Published var errorMessage: String?

    private let seWrapper = SEWrapper()

    func calculate(
        chart: FullChart,
        geoLon: Double,
        geoLat: Double,
        height: Double,
        factorConfig: FactorConfig,
        fixStarConfig: FixStarConfig,
        calculationConfig: CalculationConfig,
        paranTimeOrbMinutes: Double
    ) {
        isCalculating = true
        errorMessage = nil
        result = nil

        let overriddenConfig = FixStarConfig(
            includeGalacticCenter: fixStarConfig.includeGalacticCenter,
            fixStarOrb: fixStarConfig.fixStarOrb,
            paranTimeOrb: paranTimeOrbMinutes,
            activeSelection: fixStarConfig.activeSelection,
            magnitudeLimit: fixStarConfig.magnitudeLimit,
            fixStarSettings: fixStarConfig.fixStarSettings
        )

        let wrapper = seWrapper
        Task.detached(priority: .userInitiated) {
            let computed = ParansOrchestrator.calculate(
                chart: chart,
                geoLon: geoLon,
                geoLat: geoLat,
                height: height,
                factorConfig: factorConfig,
                fixStarConfig: overriddenConfig,
                calculationConfig: calculationConfig,
                seWrapper: wrapper
            )
            await MainActor.run {
                self.result = computed
                self.isCalculating = false
            }
        }
    }
}
