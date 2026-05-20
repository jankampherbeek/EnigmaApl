// RadixSearchModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData
import Combine

@MainActor
final class RadixSearchModel: ObservableObject {

    @Published private(set) var results: [HoroscopeModel] = []
    @Published private(set) var searchError: String? = nil

    private let seWrapper = SEWrapper()

    /// Fetches all horoscopes and filters in memory (case- and diacritic-insensitive contains).
    func search(query: String, context: ModelContext) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            return
        }
        do {
            let descriptor = FetchDescriptor<HoroscopeModel>(sortBy: [SortDescriptor(\.name)])
            let all = try context.fetch(descriptor)
            results = all.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
            searchError = nil
        } catch {
            results = []
            searchError = error.localizedDescription
        }
    }

    /// Calculates the FullChart for the preferred (or first) datetime of the given horoscope.
    /// Returns nil when the horoscope has no datetimes or no location.
    func calculateChart(for horoscope: HoroscopeModel, factorsToUse: [Factors], calculationConfig: CalculationConfig) -> (FullChart, CalcRequest)? {
        guard let dateTime = horoscope.dateTimes.first(where: { $0.isPreferred }) ?? horoscope.dateTimes.first,
              let latitude = horoscope.latitude,
              let longitude = horoscope.longitude else { return nil }

        let request = CalcRequest(
            JulianDay: dateTime.julianDate,
            FactorsToUse: factorsToUse,
            HouseSystem: HouseSystems.placidus.rawValue,
            Latitude: latitude,
            Longitude: longitude,
            Height: 0.0,
            calculationConfig: calculationConfig
        )
        let chart = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        return (chart, request)
    }
}
