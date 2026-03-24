//
//  ChartSession.swift
//  EnigmaApl
//

import SwiftUI
import Combine

/// A chart with a display name, as stored in the session.
struct NamedChart: Identifiable {
    let id: UUID       // stable identity (preserved on recalculation)
    let version: UUID  // changes on every recalculation — use as update trigger
    let name: String
    let chart: FullChart
    let baseRequest: CalcRequest

    init(name: String, chart: FullChart, baseRequest: CalcRequest) {
        self.id = UUID()
        self.version = UUID()
        self.name = name
        self.chart = chart
        self.baseRequest = baseRequest
    }

    /// Used internally to preserve identity while replacing chart content.
    fileprivate init(preservingId id: UUID, name: String, chart: FullChart, baseRequest: CalcRequest) {
        self.id = id
        self.version = UUID()
        self.name = name
        self.chart = chart
        self.baseRequest = baseRequest
    }
}

/// Runtime session state for charts calculated or found during the current app session.
/// This is in-memory only and is not persisted. SwiftData handles persistence.
@MainActor
final class ChartSession: ObservableObject {
    @Published var charts: [NamedChart] = []
    @Published var selected: NamedChart?
    @Published var editingHoroscope: HoroscopeModel?
    @Published var editingNamedChart: NamedChart?

    private let seWrapper = SEWrapper()

    var selectedChart: FullChart? { selected?.chart }

    func add(name: String, chart: FullChart, baseRequest: CalcRequest) {
        let named = NamedChart(name: name, chart: chart, baseRequest: baseRequest)
        charts.append(named)
        selected = named
    }

    func select(_ named: NamedChart) {
        selected = named
    }

    func remove(at index: Int) {
        guard charts.indices.contains(index) else { return }
        let removedId = charts[index].id
        charts.remove(at: index)
        if selected?.id == removedId {
            selected = charts.last
        }
    }

    func clear() {
        charts = []
        selected = nil
    }

    func removeFromSession(horoscope: HoroscopeModel) {
        let preferredDT = horoscope.dateTimes.first(where: { $0.isPreferred }) ?? horoscope.dateTimes.first
        let julianDate = preferredDT?.julianDate
        charts.removeAll { named in
            named.name == horoscope.name &&
            (julianDate == nil || true) // match by name; julian date not tracked in NamedChart
        }
        if let sel = selected, !charts.contains(where: { $0.id == sel.id }) {
            selected = charts.last
        }
    }

    func replace(_ old: NamedChart, with new: NamedChart) {
        guard let index = charts.firstIndex(where: { $0.id == old.id }) else { return }
        charts[index] = new
        if selected?.id == old.id {
            selected = new
        }
    }

    /// Recalculates all session charts using the given factor list and keeps each chart's identity stable.
    func recalculateAll(factorsToUse: [Factors]) {
        guard !charts.isEmpty else { return }
        let selectedId = selected?.id
        charts = charts.map { named in
            let newRequest = CalcRequest(
                JulianDay: named.baseRequest.JulianDay,
                FactorsToUse: factorsToUse,
                HouseSystem: named.baseRequest.HouseSystem,
                Latitude: named.baseRequest.Latitude,
                Longitude: named.baseRequest.Longitude,
                Height: named.baseRequest.Height,
                calculationConfig: named.baseRequest.calculationConfig
            )
            let newChart = AstronCalcOrchestrator.PerformCalculation(newRequest, seWrapper: seWrapper)
            return NamedChart(preservingId: named.id, name: named.name, chart: newChart, baseRequest: newRequest)
        }
        if let selectedId {
            selected = charts.first(where: { $0.id == selectedId })
        }
    }
}
