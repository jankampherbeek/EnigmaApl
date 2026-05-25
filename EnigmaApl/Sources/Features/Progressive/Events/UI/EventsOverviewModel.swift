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
    @Published var selectedEvent: EventModel?
    @Published var errorMessage: String?

    private var modelContext: ModelContext?
    private var progressiveSession: ProgressiveSession?
    private var cancellables = Set<AnyCancellable>()

    func setup(context: ModelContext) {
        modelContext = context
    }

    func setSession(_ session: ProgressiveSession) {
        progressiveSession = session
        selectedEvent = session.selectedEvent
        session.$selectedEvent
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] event in self?.selectedEvent = event }
            .store(in: &cancellables)
    }

    /// Finds the persisted HoroscopeModel whose name matches the given session chart
    /// and refreshes the event list.
    func loadHoroscope(matching namedChart: NamedChart) {
        guard let context = modelContext else { return }
        let repo = HoroscopeRepository(context: context)
        do {
            let all = try repo.fetchAll()
            let newHoroscope = all.first(where: { $0.name == namedChart.name })
            if let current = horoscope, let new = newHoroscope, current.id != new.id {
                progressiveSession?.clearSelection()
            }
            horoscope = newHoroscope
            refreshEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Deletes the given event via EventsOrchestrator and refreshes the list.
    func delete(_ event: EventModel) {
        guard let context = modelContext else { return }
        let orchestrator = EventsOrchestrator(context: context)
        do {
            progressiveSession?.clearIfDeleted(event)
            try orchestrator.delete(event)
            refreshEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Marks an event as the active one for progressive calculations.
    func select(_ event: EventModel) {
        progressiveSession?.select(event)
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
