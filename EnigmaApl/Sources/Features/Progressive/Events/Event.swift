// Event.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

/// Persistent model for a progressive event (e.g. a transit or secondary direction date).
@Model
final class Event {
    @Attribute(.unique) var nid: Int
    var name: String
    var eventDescription: String
    /// Date and time formatted as yyyy-MM-dd hh:mm:ss.
    var dateTime: String
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    var julianDay: Double

    init(
        nid: Int,
        name: String,
        eventDescription: String,
        dateTime: String,
        locationName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        julianDay: Double
    ) {
        self.nid = nid
        self.name = name
        self.eventDescription = eventDescription
        self.dateTime = dateTime
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.julianDay = julianDay
    }
}
