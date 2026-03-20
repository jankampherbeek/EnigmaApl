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
}
