// EventRepository.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftData
import Foundation

enum EventRepositoryError: Error {
    /// Thrown when unlinking a horoscope would leave the event without any horoscope.
    case eventRequiresAtLeastOneHoroscope
}

@MainActor
final class EventRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Event

    /// Creates an event. At least one horoscope must be supplied.
    func add(
        title: String,
        eventDescription: String? = nil,
        julianDate: Double,
        timeZoneIdentifier: String = "UTC",
        originalInput: String? = nil,
        placeName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        country: String? = nil,
        location: String? = nil,
        horoscopes: [HoroscopeModel]
    ) throws -> EventModel {
        let event = EventModel(
            title: title,
            eventDescription: eventDescription,
            julianDate: julianDate,
            timeZoneIdentifier: timeZoneIdentifier,
            originalInput: originalInput,
            placeName: placeName,
            latitude: latitude,
            longitude: longitude,
            country: country,
            location: location
        )
        context.insert(event)
        event.horoscopes = horoscopes
        try context.save()
        return event
    }

    func update(_ event: EventModel) throws {
        try context.save()
    }

    func delete(_ event: EventModel) throws {
        context.delete(event)
        try context.save()
    }

    func fetchAll() throws -> [EventModel] {
        let descriptor = FetchDescriptor<EventModel>(
            sortBy: [SortDescriptor(\.julianDate)]
        )
        return try context.fetch(descriptor)
    }

    func fetch(by id: UUID) throws -> EventModel? {
        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    // MARK: - Horoscope linking

    func link(horoscope: HoroscopeModel, to event: EventModel) throws {
        if !event.horoscopes.contains(where: { $0.id == horoscope.id }) {
            event.horoscopes.append(horoscope)
        }
        try context.save()
    }

    /// Removes the link between a horoscope and an event.
    /// Throws EventRepositoryError.eventRequiresAtLeastOneHoroscope when it is the last linked horoscope.
    func unlink(horoscope: HoroscopeModel, from event: EventModel) throws {
        guard event.horoscopes.count > 1 else {
            throw EventRepositoryError.eventRequiresAtLeastOneHoroscope
        }
        event.horoscopes.removeAll { $0.id == horoscope.id }
        try context.save()
    }
}
