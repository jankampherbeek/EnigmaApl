// SymbolicModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData
import Combine

/// Shared model for SymbolicScreen and SymbolicResults.
/// Created once in AppComposition and injected as an EnvironmentObject.
@MainActor
final class SymbolicModel: ObservableObject {

    @Published private(set) var events: [EventModel] = []
    @Published private(set) var horoscope: HoroscopeModel?
    @Published var selectedEvent: EventModel?
    @Published var selectedSymbolicKey: SymbolicKeys = .oneDegree
    @Published private(set) var results: [Factors: ProgressivePosition] = [:]
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
            .sink { [weak self] event in
                self?.selectedEvent = event
                self?.results = [:]
            }
            .store(in: &cancellables)
    }

    func loadHoroscope(matching namedChart: NamedChart) {
        guard let context = modelContext else { return }
        let repo = HoroscopeRepository(context: context)
        do {
            let all = try repo.fetchAll()
            let newHoroscope = all.first(where: { $0.name == namedChart.name })
            if let current = horoscope, let new = newHoroscope, current.id != new.id {
                progressiveSession?.clearSelection()
                results = [:]
            }
            horoscope = newHoroscope
            refreshEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func select(_ event: EventModel) {
        progressiveSession?.select(event)
        results = [:]
    }

    func reload() {
        refreshEvents()
    }

    func calculate() {
        guard let event = selectedEvent, let context = modelContext else { return }
        errorMessage = nil
        guard let natalJD = horoscope?.dateTimes.first(where: { $0.isPreferred })?.julianDate else {
            errorMessage = NSLocalizedString(SymbolicDirKeys.errorNoNatalJD, tableName: "SymbolicDir", bundle: .main, comment: "")
            return
        }
        let request = ProgressiveCalcRequest(
            julianDay: event.julianDate,
            method: .symdir,
            natalJulianDay: natalJD
        )
        let orchestrator = ProgressiveOrchestrator(context: context)
        do {
            results = try orchestrator.progressivePositions(request, symbolicKey: selectedSymbolicKey)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshEvents() {
        events = (horoscope?.events ?? []).sorted { $0.julianDate < $1.julianDate }
    }
}
