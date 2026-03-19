//
//  HoroscopeModel.swift
//  EnigmaApl
//

import Foundation
import SwiftData

/// Persistent model for a horoscope. Contains metadata and location.
/// Date and time are stored in related HoroscopeDateTime objects to support multiple time options.
@Model
final class HoroscopeModel {
    var id: UUID
    var name: String
    /// Category of the horoscope, e.g. "natal", "mundane", "horary". Use RoddenRating.rawValue for rating.
    var category: String
    var notes: String?
    /// Source of the birth data, e.g. birth certificate, biography.
    var source: String?
    /// Rodden rating rawValue (e.g. "AA", "A", "B"). See RoddenRating enum.
    var roddenRating: String
    var placeName: String?
    var latitude: Double?
    var longitude: Double?

    @Relationship(deleteRule: .cascade, inverse: \HoroscopeDateTimeModel.horoscope)
    var dateTimes: [HoroscopeDateTimeModel]

    @Relationship(inverse: \EventModel.horoscopes)
    var events: [EventModel]

    init(
        name: String = "",
        category: String = "",
        notes: String? = nil,
        source: String? = nil,
        roddenRating: String = RoddenRating.none.rawValue,
        placeName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.notes = notes
        self.source = source
        self.roddenRating = roddenRating
        self.placeName = placeName
        self.latitude = latitude
        self.longitude = longitude
        self.dateTimes = []
        self.events = []
    }
}
