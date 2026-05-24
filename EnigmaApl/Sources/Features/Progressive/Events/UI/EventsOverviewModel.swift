// EventsOverviewModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData
import Combine

/// Model for EventsOverviewScreen.
/// Matches the selected session chart to its persisted HoroscopeModel and exposes
/// the linked events. Call setup(context:) once from onAppear before any other method.
@MainActor
final class EventsOverviewModel: ObservableObject {

    @Published private(set) var events: [EventModel] = []
    @Published private(set) var horoscope: HoroscopeModel?
    /// The event chosen for use in progressive calculations.
    @Published var selectedEvent: EventModel?
    @Published var errorMessage: String?

    private var modelContext: ModelContext?

    func setup(context: ModelContext) {
        modelContext = context
    }

    /// Finds the persisted HoroscopeModel whose name matches the given session chart
    /// and refreshes the event list.
    func loadHoroscope(matching namedChart: NamedChart) {
        guard let context = modelContext else { return }
        let repo = HoroscopeRepository(context: context)
        do {
            let all = try repo.fetchAll()
            horoscope = all.first(where: { $0.name == namedChart.name })
            refreshEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Deletes the given event from the store and refreshes the list.
    func delete(_ event: EventModel) {
        guard let context = modelContext else { return }
        let repo = EventRepository(context: context)
        do {
            if selectedEvent?.id == event.id { selectedEvent = nil }
            try repo.delete(event)
            refreshEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Marks an event as the active one for progressive calculations.
    func select(_ event: EventModel) {
        selectedEvent = event
    }

    /// Re-reads events from the current horoscope. Call after external mutations (e.g. event creation).
    func reload() {
        refreshEvents()
    }

    // MARK: - Private

    private func refreshEvents() {
        events = (horoscope?.events ?? []).sorted { $0.julianDate < $1.julianDate }
    }
}
