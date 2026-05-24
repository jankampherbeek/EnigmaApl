// EventDao.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

enum EventDaoError: Error {
    case chartNotFound(UUID)
    case eventNotFound(UUID)
}

/// Raw SwiftData access for EventModel and its HoroscopeModel relationships.
/// All methods run on the main actor because ModelContext is not Sendable.
@MainActor
struct EventDao {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Fetch

    func fetchChart(id: UUID) throws -> HoroscopeModel {
        let descriptor = FetchDescriptor<HoroscopeModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let chart = try context.fetch(descriptor).first else {
            throw EventDaoError.chartNotFound(id)
        }
        return chart
    }

    func fetchEvent(id: UUID) throws -> EventModel {
        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let event = try context.fetch(descriptor).first else {
            throw EventDaoError.eventNotFound(id)
        }
        return event
    }

    // MARK: - Write

    func insert(_ event: EventModel) throws {
        context.insert(event)
        try context.save()
    }

    func save() throws {
        try context.save()
    }

    func delete(_ event: EventModel) throws {
        context.delete(event)
        try context.save()
    }

    /// Deletes all given events in a single save round-trip.
    func deleteAll(_ events: [EventModel]) throws {
        events.forEach { context.delete($0) }
        try context.save()
    }
}
