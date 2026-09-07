// EnigmaExportModels.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Top-level container for the Enigma JSON import/export format.
/// Covers all persisted chart and event data needed to reconstruct them;
/// calculated positions are deliberately excluded, since they are derived at
/// calculation time from a date/time plus the active UserConfiguration.
struct EnigmaExportFile: Codable {
    var formatVersion: Int
    var exportedAt: Date
    var charts: [EnigmaChartDTO]
    var events: [EnigmaEventDTO]

    static let currentFormatVersion = 1
}

struct EnigmaDateTimeDTO: Codable {
    var id: UUID
    var julianDate: Double
    var timeZoneIdentifier: String
    var timeIsUnknown: Bool
    var isPreferred: Bool
    var label: String?
    var originalInput: String?
}

struct EnigmaChartDTO: Codable {
    var id: UUID
    var name: String
    var category: String
    var notes: String?
    var source: String?
    var roddenRating: String
    var placeName: String?
    var latitude: Double?
    var longitude: Double?
    var dateTimes: [EnigmaDateTimeDTO]
}

struct EnigmaEventDTO: Codable {
    var id: UUID
    var title: String
    var eventDescription: String?
    var julianDate: Double
    var timeZoneIdentifier: String
    var originalInput: String?
    var placeName: String?
    var latitude: Double?
    var longitude: Double?
    var country: String?
    var location: String?
    /// Ids of the charts this event is linked to. Reconstructs the many-to-many
    /// relationship on import; the chart side does not carry the inverse list.
    var chartIds: [UUID]
}
