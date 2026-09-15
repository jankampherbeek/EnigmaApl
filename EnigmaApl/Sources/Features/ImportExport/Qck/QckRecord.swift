// QckRecord.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Format-specific intermediate representation of one Quick*Chart / QCK
/// fixed-width record (100 or 101 characters). Holds exactly the data that is
/// physically present in the record; no astrological calculation and no
/// timezone/IANA resolution happens here. `QckMapper` converts this to and
/// from the Enigma domain model.
struct QckRecord {
    var name: String
    var month: Int
    var day: Int
    var year: Int
    var hour: Int
    var minute: Int
    var second: Int
    var isPM: Bool
    /// Three-letter timezone abbreviation as found in the record (e.g. "CET",
    /// "EST", "LMT"), or empty when the record used plain zone time (three spaces).
    var timeZoneAbbreviation: String
    /// The QCK correction, in minutes, using QCK's own sign convention:
    /// UT = LocalTime + qckCorrection. NOT the modern UTC-offset sign.
    var qckCorrectionMinutes: Int
    /// Decimal degrees, East positive.
    var longitude: Double
    /// Decimal degrees, North positive.
    var latitude: Double
    var place: String

    var isLmt: Bool { timeZoneAbbreviation == "LMT" }

    /// True when the timezone abbreviation's second letter is "D" or "W",
    /// the legacy QCK convention for daylight/war time. Informational only:
    /// the numeric correction remains authoritative for the computed instant.
    var indicatesDaylightOrWarTime: Bool {
        guard timeZoneAbbreviation.count == 3 else { return false }
        let secondChar = timeZoneAbbreviation[timeZoneAbbreviation.index(timeZoneAbbreviation.startIndex, offsetBy: 1)]
        return secondChar == "D" || secondChar == "W"
    }

    /// Effective modern UTC offset in minutes, per QCK's inverted sign convention.
    var effectiveUtcOffsetMinutes: Int { -qckCorrectionMinutes }
}
