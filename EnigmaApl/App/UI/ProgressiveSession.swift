// ProgressiveSession.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

/// Shared session state for progressive techniques.
/// Holds the event selection that is shared across EventsOverviewScreen,
/// TransitScreen, and SecondaryScreen so that selecting an event in any
/// of those views pre-selects it in the others.
@MainActor
final class ProgressiveSession: ObservableObject {
    @Published var selectedEvent: EventModel?

    func select(_ event: EventModel) {
        selectedEvent = event
    }

    func clearSelection() {
        selectedEvent = nil
    }

    func clearIfDeleted(_ event: EventModel) {
        if selectedEvent?.id == event.id { selectedEvent = nil }
    }
}
