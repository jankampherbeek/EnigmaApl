// EventModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

/// Persistent model for an astrological event.
/// An event must be linked to one or more horoscopes (enforced by application logic).
@Model
final class EventModel {
    var id: UUID
    var title: String
    var eventDescription: String?
    /// Julian Date in Universal Time (UT), as required by the Swiss Ephemeris.
    var julianDate: Double
    /// IANA timezone identifier, e.g. "Europe/Amsterdam". Used to reconstruct local time for display.
    var timeZoneIdentifier: String
    /// The original date and time as entered by the user, for display and feedback purposes.
    var originalInput: String?
    var placeName: String?
    var latitude: Double?
    var longitude: Double?
    var country: String?
    var location: String?

    var horoscopes: [HoroscopeModel]

    init(
        title: String = "",
        eventDescription: String? = nil,
        julianDate: Double,
        timeZoneIdentifier: String = "UTC",
        originalInput: String? = nil,
        placeName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        country: String? = nil,
        location: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.eventDescription = eventDescription
        self.julianDate = julianDate
        self.timeZoneIdentifier = timeZoneIdentifier
        self.originalInput = originalInput
        self.placeName = placeName
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.location = location
        self.horoscopes = []
    }
}
