// TransitModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData
import Combine

/// Shared model for TransitScreen (right column) and TransitResults (middle column).
/// Created once in AppComposition and injected as an EnvironmentObject.
@MainActor
final class TransitModel: ObservableObject {

    @Published private(set) var events: [EventModel] = []
    @Published private(set) var horoscope: HoroscopeModel?
    @Published var selectedEvent: EventModel?
    @Published private(set) var results: [Factors: ProgressivePosition] = [:]
    @Published var errorMessage: String?

    private var modelContext: ModelContext?

    /// Must be called once from onAppear before any other method.
    func setup(context: ModelContext) {
        modelContext = context
    }

    /// Finds the persisted HoroscopeModel whose name matches the given session chart
    /// and refreshes the linked event list.
    func loadHoroscope(matching namedChart: NamedChart) {
        guard let context = modelContext else { return }
        let repo = HoroscopeRepository(context: context)
        do {
            let all = try repo.fetchAll()
            horoscope = all.first(where: { $0.name == namedChart.name })
            selectedEvent = nil
            results = [:]
            refreshEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Marks an event as selected for the transit calculation. Clears any previous results.
    func select(_ event: EventModel) {
        selectedEvent = event
        results = [:]
    }

    /// Re-reads events from the current horoscope. Call after external mutations (e.g. event creation).
    func reload() {
        refreshEvents()
    }

    /// Runs the transit calculation for the selected event.
    func calculate() {
        guard let event = selectedEvent, let context = modelContext else { return }
        errorMessage = nil
        let request = ProgressiveCalcRequest(julianDay: event.julianDate, method: .transit)
        let orchestrator = ProgressiveOrchestrator(context: context)
        do {
            results = try orchestrator.progressivePositions(request)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private

    private func refreshEvents() {
        events = (horoscope?.events ?? []).sorted { $0.julianDate < $1.julianDate }
    }
}
