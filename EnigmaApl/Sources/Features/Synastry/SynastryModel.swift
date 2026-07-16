// SynastryModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData
import Combine

@MainActor
final class SynastryModel: ObservableObject {

    @Published private(set) var selectedCharts: [NamedChart] = []
    @Published private(set) var searchResults: [HoroscopeModel] = []
    @Published private(set) var searchError: String? = nil

    private let seWrapper = SEWrapper()

    /// Compare, Aspect/Midpoint/Declination Comparison require exactly two charts.
    var canCompare: Bool { selectedCharts.count == 2 }

    /// Combine (Davison) and Composite also accept more than two charts.
    var canCombine: Bool { selectedCharts.count >= 2 }
    var canComposite: Bool { selectedCharts.count >= 2 }

    /// Fetches all horoscopes and filters in memory (case- and diacritic-insensitive contains).
    func search(query: String, context: ModelContext) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }
        do {
            let descriptor = FetchDescriptor<HoroscopeModel>(sortBy: [SortDescriptor(\.name)])
            let all = try context.fetch(descriptor)
            searchResults = all.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
            searchError = nil
        } catch {
            searchResults = []
            searchError = error.localizedDescription
        }
    }

    /// Calculates the FullChart for the preferred (or first) datetime of the given horoscope
    /// and adds it to the selection. Does nothing when the horoscope has no datetime/location,
    /// and does not add a duplicate of an already-selected chart.
    func addChart(from horoscope: HoroscopeModel, factorsToUse: [Factors], calculationConfig: CalculationConfig) {
        guard let dateTime = horoscope.dateTimes.first(where: { $0.isPreferred }) ?? horoscope.dateTimes.first,
              let latitude = horoscope.latitude,
              let longitude = horoscope.longitude else { return }

        let request = CalcRequest(
            JulianDay: dateTime.julianDate,
            FactorsToUse: factorsToUse,
            HouseSystem: Int(calculationConfig.houseSystem.seId.asciiValue ?? 80),
            Latitude: latitude,
            Longitude: longitude,
            Height: 0.0,
            calculationConfig: calculationConfig
        )
        let chart = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let named = NamedChart(name: horoscope.name, chart: chart, baseRequest: request)
        addFromSession(named)
    }

    /// Adds an already-calculated chart (e.g. from the current ChartSession) to the selection.
    /// A new selection never replaces an existing one; duplicates (by name + JulianDay) are ignored.
    func addFromSession(_ named: NamedChart) {
        guard !selectedCharts.contains(where: { $0.name == named.name && $0.chart.JulianDay == named.chart.JulianDay }) else { return }
        selectedCharts.append(named)
    }

    func removeChart(id: UUID) {
        selectedCharts.removeAll { $0.id == id }
    }

    func isSelected(_ named: NamedChart) -> Bool {
        selectedCharts.contains { $0.name == named.name && $0.chart.JulianDay == named.chart.JulianDay }
    }
}
