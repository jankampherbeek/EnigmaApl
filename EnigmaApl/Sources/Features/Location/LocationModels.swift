// LocationModels.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// A country entry from the database.
public struct LocationCountry {
    public let code: String
    public let name: String
    public let continent: String
}

/// A city entry from the database, including its resolved IANA timezone name.
public struct LocationCity: Equatable {
    public let id: Int
    public let countryCode: String
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let regionCode: String?
    public let elevation: Int?
    public let timezoneId: Int
    public let timezoneName: String
}

/// A parsed row from the TzData table.
struct TzDataRow {
    let zoneName: String
    let offsetH: Int
    let offsetM: Int
    let offsetS: Int
    let rule: String
    let format: String
    let untilYear: Int
    let untilMonth: Int
    let untilDay: String
    let atH: Int
    let atM: Int
    let atS: Int

    var standardOffsetSeconds: Int { offsetH * 3600 + offsetM * 60 + offsetS }
}

/// A parsed row from the DstData table.
struct DstDataRow {
    let ruleName: String
    let fromYear: Int
    let toYear: String     // "only", "max", or a year number as string
    let month: Int
    let day: String        // fixed day, "lastN", ">=N", "<=N"
    let atH: Int
    let atM: Int
    let atS: Int
    let useUt: String      // "u" means UT, otherwise local time
    let saveH: Int
    let saveM: Int
    let saveS: Int
    let letter: String

    var saveSeconds: Int { saveH * 3600 + saveM * 60 + saveS }
}

/// The result of a full timezone resolution for a given date/time.
public struct ZoneInfo {
    /// Total UTC offset in seconds (standard + DST).
    public let offsetSeconds: Int
    /// Formatted timezone name (e.g. "CET", "CEST", "GMT+1").
    public let tzName: String
    /// Whether DST is currently active.
    public let dstUsed: Bool
    /// True when the given local time falls in the DST gap (clocks spring forward).
    public let isInvalid: Bool
    /// True when the given local time is ambiguous (clocks fall back).
    public let isAmbiguous: Bool
}
