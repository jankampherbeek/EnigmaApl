// EphemerisModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

@MainActor
final class EphemerisModel: ObservableObject {
    @Published var rows: [EphemerisRow] = []
    @Published var selectedFactors: [Factors] = []
    @Published var selectedCoordinate: EphemerisCoordinate = .longitude
    @Published var month: Int = Calendar.current.component(.month, from: Date())
    @Published var year: Int = Calendar.current.component(.year, from: Date())
    @Published var observerPosition: ObserverPositions = .geoCentric
    @Published var ayanamsha: Ayanamshas = .tropical

    func recalculate(seWrapper: SEWrapper) {
        guard !selectedFactors.isEmpty else {
            rows = []
            return
        }
        let available = EphemerisCalculator.availableFactors(for: observerPosition)
        let factors = selectedFactors.filter { available.contains($0) }
        rows = EphemerisCalculator.calculate(
            year: year,
            month: month,
            factors: factors,
            observerPosition: observerPosition,
            ayanamsha: ayanamsha,
            seWrapper: seWrapper
        )
    }
}
