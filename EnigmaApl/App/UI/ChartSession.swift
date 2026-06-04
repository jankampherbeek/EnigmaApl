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
    /// UTC offset in decimal hours (e.g. 1.0 for +01:00, -5.5 for -05:30).
    let timeZoneOffsetHours: Double

    init(name: String, chart: FullChart, baseRequest: CalcRequest, timeZoneOffsetHours: Double = 0.0) {
        self.id = UUID()
        self.version = UUID()
        self.name = name
        self.chart = chart
        self.baseRequest = baseRequest
        self.timeZoneOffsetHours = timeZoneOffsetHours
    }

    /// Used internally to preserve identity while replacing chart content.
    fileprivate init(preservingId id: UUID, name: String, chart: FullChart, baseRequest: CalcRequest, timeZoneOffsetHours: Double) {
        self.id = id
        self.version = UUID()
        self.name = name
        self.chart = chart
        self.baseRequest = baseRequest
        self.timeZoneOffsetHours = timeZoneOffsetHours
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

    /// Calculates the 12 house-cusp ecliptic longitudes for the selected chart using
    /// the given house system. Returns nil when no chart is selected or the calculation fails.
    func houseCuspLongitudes(for houseSystem: HouseSystems) -> [Double]? {
        guard let named = selected else { return nil }
        let hsInt = Int(houseSystem.seId.asciiValue ?? 75)
        guard let (raw, _) = try? seWrapper.calculateHouses(
            julianDay:   named.chart.JulianDay,
            latitude:    named.baseRequest.Latitude,
            longitude:   named.baseRequest.Longitude,
            houseSystem: hsInt
        ), raw.count >= 13 else { return nil }
        return Array(raw[1...12])
    }

    func add(name: String, chart: FullChart, baseRequest: CalcRequest, timeZoneOffsetHours: Double = 0.0) {
        let named = NamedChart(name: name, chart: chart, baseRequest: baseRequest, timeZoneOffsetHours: timeZoneOffsetHours)
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

    func replace(_ old: NamedChart, with new: NamedChart, timeZoneOffsetHours: Double? = nil) {
        guard let index = charts.firstIndex(where: { $0.id == old.id }) else { return }
        let updated: NamedChart
        if let tz = timeZoneOffsetHours {
            updated = NamedChart(preservingId: old.id, name: new.name, chart: new.chart, baseRequest: new.baseRequest, timeZoneOffsetHours: tz)
        } else {
            updated = NamedChart(preservingId: old.id, name: new.name, chart: new.chart, baseRequest: new.baseRequest, timeZoneOffsetHours: old.timeZoneOffsetHours)
        }
        charts[index] = updated
        if selected?.id == old.id {
            selected = updated
        }
    }

    /// Recalculates all session charts using the given factor list and calculation config,
    /// keeping each chart's identity stable.
    func recalculateAll(factorsToUse: [Factors], calculationConfig: CalculationConfig) {
        guard !charts.isEmpty else { return }
        let selectedId = selected?.id
        charts = charts.map { named in
            let newRequest = CalcRequest(
                JulianDay: named.baseRequest.JulianDay,
                FactorsToUse: factorsToUse,
                HouseSystem: Int(calculationConfig.houseSystem.seId.asciiValue ?? 80),
                Latitude: named.baseRequest.Latitude,
                Longitude: named.baseRequest.Longitude,
                Height: named.baseRequest.Height,
                calculationConfig: calculationConfig
            )
            let newChart = AstronCalcOrchestrator.PerformCalculation(newRequest, seWrapper: seWrapper)
            return NamedChart(preservingId: named.id, name: named.name, chart: newChart, baseRequest: newRequest, timeZoneOffsetHours: named.timeZoneOffsetHours)
        }
        if let selectedId {
            selected = charts.first(where: { $0.id == selectedId })
        }
    }
}
