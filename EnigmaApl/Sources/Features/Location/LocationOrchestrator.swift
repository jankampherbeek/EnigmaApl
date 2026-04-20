// LocationOrchestrator.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Single entry point for all geographic and timezone lookups.
///
/// **Typical frontend usage**
/// ```swift
/// // Inject the app-level SEWrapper via @EnvironmentObject or pass it directly.
/// let orch = LocationOrchestrator(seWrapper: seWrapper)
///
/// // 1. Populate a country picker
/// let countries = try orch.allCountries(lang: "en")
///
/// // 2. Populate a city list after the user picks a country
/// let cities = try orch.cities(countryCode: "NL", pattern: "A*")
///
/// // 3. After the user picks a city, resolve the UTC offset for the birth date/time
/// let dateTime = AstronomicalDateTime(
///     Date: AstronomicalDate(Year: 1975, Month: 3, Day: 30),
///     Time: AstronomicalTime(Hour: 14, Minute: 25, Second: 0)
/// )
/// let zone = try orch.timezoneInfo(tzName: city.timezoneName, dateTime: dateTime)
/// // zone.offsetSeconds → total UTC offset including DST
/// ```
public struct LocationOrchestrator {

    private let db: LocationDb
    private let seWrapper: SEWrapper

    /// Creates the orchestrator.
    /// - Parameter seWrapper: The app-level SEWrapper (thread-safe Swiss Ephemeris wrapper).
    public init(seWrapper: SEWrapper) throws {
        self.db        = try LocationDb()
        self.seWrapper = seWrapper
    }

    // MARK: - Country lookup

    /// Returns all countries sorted by localised name for the given language code (e.g. "en", "nl", "de", "fr").
    public func allCountries(lang: String) throws -> [LocationCountry] {
        try db.allCountries(lang: lang)
    }

    /// Returns countries whose localised name matches the pattern, for the given language.
    public func countries(lang: String, pattern: String) throws -> [LocationCountry] {
        try db.countries(lang: lang, pattern: pattern)
    }

    // MARK: - City lookup

    /// Returns cities for the given country, optionally filtered by a name pattern.
    ///
    /// - Parameters:
    ///   - countryCode: ISO 3166-1 alpha-2 code, e.g. `"NL"`.
    ///   - pattern:     Name filter.  Only `*` is supported as a wildcard (matches any
    ///                  number of characters).  An empty string or `"*"` returns all cities.
    ///                  The match is case-insensitive.  Examples:
    ///                  - `"A*"` → all cities starting with A
    ///                  - `"*dam"` → all cities ending with "dam"
    ///                  - `"*ster*"` → all cities containing "ster"
    public func cities(countryCode: String, pattern: String = "*") throws -> [LocationCity] {
        try db.cities(countryCode: countryCode, pattern: pattern)
    }

    // MARK: - Timezone resolution

    /// Resolves the full UTC offset (including DST) and timezone name for the given local date/time.
    ///
    /// - Parameters:
    ///   - tzName:    IANA timezone identifier, e.g. `"Europe/Amsterdam"`.
    ///                Obtained from `LocationCity.timezoneName`.
    ///   - dateTime:  Local date and time for which the offset should be calculated.
    ///   - longitude: Optional geographic longitude (decimal degrees, East positive).
    ///                Supply this to enable LMT (Local Mean Time) support for historical dates.
    /// - Returns: A `ZoneInfo` with `offsetSeconds`, `tzName`, `dstUsed`, `isInvalid`, `isAmbiguous`.
    public func timezoneInfo(
        tzName:    String,
        dateTime:  AstronomicalDateTime,
        longitude: Double? = nil
    ) throws -> ZoneInfo {
        let resolver = TzResolver(db: db, seWrapper: seWrapper)
        return try resolver.resolve(dateTime: dateTime, zoneName: tzName, longitude: longitude)
    }
}
