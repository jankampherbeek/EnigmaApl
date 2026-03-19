//
//  HoroscopeRepository.swift
//  EnigmaApl
//

import SwiftData
import Foundation

enum HoroscopeRepositoryError: Error {
    case notFound
    case multiplePreferred
}

@MainActor
final class HoroscopeRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Horoscope

    func add(
        name: String,
        category: String = "",
        notes: String? = nil,
        source: String? = nil,
        roddenRating: String = RoddenRating.none.rawValue,
        placeName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) throws -> HoroscopeModel {
        let horoscope = HoroscopeModel(
            name: name,
            category: category,
            notes: notes,
            source: source,
            roddenRating: roddenRating,
            placeName: placeName,
            latitude: latitude,
            longitude: longitude
        )
        context.insert(horoscope)
        try context.save()
        return horoscope
    }

    func update(_ horoscope: HoroscopeModel) throws {
        try context.save()
    }

    func delete(_ horoscope: HoroscopeModel) throws {
        context.delete(horoscope)
        try context.save()
    }

    func fetchAll() throws -> [HoroscopeModel] {
        let descriptor = FetchDescriptor<HoroscopeModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
    }

    func fetch(by id: UUID) throws -> HoroscopeModel? {
        let descriptor = FetchDescriptor<HoroscopeModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    // MARK: - HoroscopeDateTime

    /// Adds a date/time to a horoscope.
    /// If isPreferred is true, all other dateTimes for this horoscope are set to false.
    func addDateTime(
        to horoscope: HoroscopeModel,
        julianDate: Double,
        timeZoneIdentifier: String = "UTC",
        timeIsUnknown: Bool = false,
        isPreferred: Bool = true,
        label: String? = nil,
        originalInput: String? = nil
    ) throws -> HoroscopeDateTimeModel {
        if isPreferred {
            horoscope.dateTimes.forEach { $0.isPreferred = false }
        }
        let dateTime = HoroscopeDateTimeModel(
            julianDate: julianDate,
            timeZoneIdentifier: timeZoneIdentifier,
            timeIsUnknown: timeIsUnknown,
            isPreferred: isPreferred,
            label: label,
            originalInput: originalInput
        )
        horoscope.dateTimes.append(dateTime)
        try context.save()
        return dateTime
    }

    /// Makes one specific dateTime the preferred one for its horoscope.
    func setPreferred(_ dateTime: HoroscopeDateTimeModel) throws {
        guard let horoscope = dateTime.horoscope else { return }
        horoscope.dateTimes.forEach { $0.isPreferred = false }
        dateTime.isPreferred = true
        try context.save()
    }

    func updateDateTime(_ dateTime: HoroscopeDateTimeModel) throws {
        try context.save()
    }

    func deleteDateTime(_ dateTime: HoroscopeDateTimeModel) throws {
        context.delete(dateTime)
        try context.save()
    }
}
