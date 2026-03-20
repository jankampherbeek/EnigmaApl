//
//  ChartSession.swift
//  EnigmaApl
//

import SwiftUI
import Combine

/// A chart with a display name, as stored in the session.
struct NamedChart: Identifiable {
    let id: UUID
    let name: String
    let chart: FullChart

    init(name: String, chart: FullChart) {
        self.id = UUID()
        self.name = name
        self.chart = chart
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

    var selectedChart: FullChart? { selected?.chart }

    func add(name: String, chart: FullChart) {
        let named = NamedChart(name: name, chart: chart)
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
            (julianDate == nil || true) // match by name; julian date not stored in NamedChart
        }
        // More precise: remove by name match only (julianDate not tracked in NamedChart)
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
}
