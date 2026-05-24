// EventsOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

/// Value type carrying the mutable fields of an EventModel.
/// Used for both creation and updates to avoid long parameter lists.
struct EventValues {
    let title: String
    let eventDescription: String?
    let julianDate: Double
    /// IANA timezone identifier, e.g. "Europe/Amsterdam".
    let timeZoneIdentifier: String
    /// Date and time as entered by the user, for display purposes (yyyy-MM-dd HH:mm:ss).
    let originalInput: String?
    let placeName: String?
    let latitude: Double?
    let longitude: Double?

    init(
        title: String,
        eventDescription: String? = nil,
        julianDate: Double,
        timeZoneIdentifier: String = "UTC",
        originalInput: String? = nil,
        placeName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.title = title
        self.eventDescription = eventDescription
        self.julianDate = julianDate
        self.timeZoneIdentifier = timeZoneIdentifier
        self.originalInput = originalInput
        self.placeName = placeName
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// Orchestrates all create / read / edit / delete operations on EventModel,
/// including managing the many-to-many relationship with HoroscopeModel.
///
/// All methods run on the main actor because ModelContext is not Sendable.
/// Obtain a `ModelContext` from the SwiftUI environment (`@Environment(\.modelContext)`)
/// and pass it to the initialiser.
@MainActor
struct EventsOrchestrator {

    private let dao: EventDao

    init(context: ModelContext) {
        self.dao = EventDao(context: context)
    }

    // MARK: - Create

    /// Creates a new EventModel, persists it, and links it to the given chart.
    @discardableResult
    func create(values: EventValues, chartId: UUID) throws -> EventModel {
        let chart = try dao.fetchChart(id: chartId)
        let event = EventModel(
            title: values.title,
            eventDescription: values.eventDescription,
            julianDate: values.julianDate,
            timeZoneIdentifier: values.timeZoneIdentifier,
            originalInput: values.originalInput,
            placeName: values.placeName,
            latitude: values.latitude,
            longitude: values.longitude
        )
        event.horoscopes.append(chart)
        try dao.insert(event)
        return event
    }

    // MARK: - Read

    /// Returns all events linked to the chart with the given id, sorted by Julian Date.
    func events(for chartId: UUID) throws -> [EventModel] {
        let chart = try dao.fetchChart(id: chartId)
        return chart.events.sorted { $0.julianDate < $1.julianDate }
    }

    // MARK: - Edit values

    /// Overwrites all scalar fields of the event with the supplied values and saves.
    func updateValues(_ event: EventModel, values: EventValues) throws {
        event.title = values.title
        event.eventDescription = values.eventDescription
        event.julianDate = values.julianDate
        event.timeZoneIdentifier = values.timeZoneIdentifier
        event.originalInput = values.originalInput
        event.placeName = values.placeName
        event.latitude = values.latitude
        event.longitude = values.longitude
        try dao.save()
    }

    // MARK: - Edit chart links

    /// Links the event to an additional chart. No-op if the link already exists.
    func linkChart(_ chartId: UUID, to event: EventModel) throws {
        guard !event.horoscopes.contains(where: { $0.id == chartId }) else { return }
        let chart = try dao.fetchChart(id: chartId)
        event.horoscopes.append(chart)
        try dao.save()
    }

    /// Removes the link between the event and the given chart.
    /// The event itself is not deleted; use `delete(_:)` for that.
    func unlinkChart(_ chartId: UUID, from event: EventModel) throws {
        event.horoscopes.removeAll { $0.id == chartId }
        try dao.save()
    }

    // MARK: - Delete

    /// Deletes the event and all its chart links.
    func delete(_ event: EventModel) throws {
        try dao.delete(event)
    }

    /// Deletes every event that is linked exclusively to the given chart.
    /// Events shared with other charts are left untouched.
    /// Call this before deleting the chart itself to avoid leaving orphaned events.
    func deleteOrphans(for chartId: UUID) throws {
        let chart = try dao.fetchChart(id: chartId)
        let orphans = chart.events.filter { $0.horoscopes.count == 1 }
        try dao.deleteAll(orphans)
    }
}
