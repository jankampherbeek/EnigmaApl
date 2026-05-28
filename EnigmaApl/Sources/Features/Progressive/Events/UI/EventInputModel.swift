// EventInputModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData
import Combine

@MainActor
final class EventInputModel: ObservableObject {

    @Published var errorMessage: String?

    private let seWrapper = SEWrapper()

    /// Computes the Julian Day in UT for the given local date, time and offset fields.
    func computeJulianDay(
        astronomicalYear: Int,
        month: Int, day: Int,
        gregorian: Bool,
        hour: Int, minute: Int, second: Int,
        offsetHour: Int, offsetMinute: Int, offsetSecond: Int,
        utOffsetEarlier: Bool,
        dstActive: Bool
    ) -> Double {
        let localDate = AstronomicalDate(Year: astronomicalYear, Month: month, Day: day, Gregorian: gregorian)
        let localTime = AstronomicalTime(Hour: hour, Minute: minute, Second: second)
        let localJD = seWrapper.julianDay(date: localDate, time: localTime)

        let offsetSec = Double(offsetHour * 3600 + offsetMinute * 60 + offsetSecond)
        let sign = utOffsetEarlier ? -1.0 : 1.0
        let dst = dstActive ? -3600.0 : 0.0
        return localJD + (sign * offsetSec + dst) / 86_400.0
    }

    /// Creates and persists a new EventModel linked to the given horoscope.
    /// Returns true on success; sets errorMessage and returns false on failure.
    func createEvent(
        title: String,
        eventDescription: String?,
        julianDate: Double,
        timeZoneIdentifier: String,
        originalInput: String?,
        placeName: String?,
        latitude: Double?,
        longitude: Double?,
        country: String?,
        location: String?,
        horoscope: HoroscopeModel,
        context: ModelContext
    ) -> Bool {
        let repo = EventRepository(context: context)
        do {
            _ = try repo.add(
                title: title,
                eventDescription: eventDescription.flatMap { $0.isEmpty ? nil : $0 },
                julianDate: julianDate,
                timeZoneIdentifier: timeZoneIdentifier,
                originalInput: originalInput,
                placeName: placeName.flatMap { $0.isEmpty ? nil : $0 },
                latitude: latitude,
                longitude: longitude,
                country: country.flatMap { $0.isEmpty ? nil : $0 },
                location: location.flatMap { $0.isEmpty ? nil : $0 },
                horoscopes: [horoscope]
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
