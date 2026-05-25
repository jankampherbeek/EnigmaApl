// SecondaryModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData
import Combine

/// Shared model for SecondaryScreen and SecondaryResults.
/// Created once in AppComposition and injected as an EnvironmentObject.
@MainActor
final class SecondaryModel: ObservableObject {

    @Published private(set) var events: [EventModel] = []
    @Published private(set) var horoscope: HoroscopeModel?
    @Published var selectedEvent: EventModel?
    @Published private(set) var results: [Factors: ProgressivePosition] = [:]
    @Published var errorMessage: String?

    private var modelContext: ModelContext?

    func setup(context: ModelContext) {
        modelContext = context
    }

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

    func select(_ event: EventModel) {
        selectedEvent = event
        results = [:]
    }

    func reload() {
        refreshEvents()
    }

    func calculate() {
        guard let event = selectedEvent, let context = modelContext else { return }
        errorMessage = nil
        guard let natalJD = horoscope?.dateTimes.first(where: { $0.isPreferred })?.julianDate else {
            errorMessage = NSLocalizedString(SecondaryKeys.errorNoNatalJD, tableName: "Secondary", bundle: .main, comment: "")
            return
        }
        let request = ProgressiveCalcRequest(
            julianDay: event.julianDate,
            method: .secdir,
            natalJulianDay: natalJD
        )
        let orchestrator = ProgressiveOrchestrator(context: context)
        do {
            results = try orchestrator.progressivePositions(request)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshEvents() {
        events = (horoscope?.events ?? []).sorted { $0.julianDate < $1.julianDate }
    }
}
