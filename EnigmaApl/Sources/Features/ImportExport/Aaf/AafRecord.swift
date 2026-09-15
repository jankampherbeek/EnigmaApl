// AafRecord.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Format-specific intermediate representation of one AAF'97 record
/// (#A93 + #B93 + optional #ZNAM/#SRC/#VIA/#COM chunks). Holds exactly the
/// data physically present in the record; no astrological calculation and no
/// IANA timezone resolution happens here. `AafMapper` converts this to and
/// from the Enigma domain model.
struct AafRecord {
    // #A93
    /// Raw field 0: last name, or a title for an event/institution. "*" means unknown.
    var lastName: String
    /// Raw field 1: first name. "*" or empty means unknown/not applicable.
    var firstName: String
    /// Raw field 2 type code: "m", "f", "w", "e", "l", "o", or "*".
    var type: String
    var day: Int
    var month: Int
    var year: Int
    /// Resolved calendar for this date: from the explicit 'g'/'j' suffix when
    /// present, otherwise from AAF's own cutover-date fallback rule.
    var isGregorian: Bool
    var hour: Int
    var minute: Int
    var second: Int
    var place: String
    /// Raw field 6: country/region code. "*" means unknown.
    var country: String

    // #B93
    /// Raw field 0, kept as text: "*" or a Julian Day number.
    var julianDayRaw: String
    var latitude: Double
    var longitude: Double
    /// Greenwich offset in seconds (standard, without DST), or nil for "*".
    var greenwichOffsetSeconds: Int?
    /// Raw field 4 time type code: "0", "1", "w", "2", "h", "L"/"l", or "m".
    var timeType: String

    // Free-text / metadata chunks
    var zoneName: String?
    var source: String?
    var via: String?
    var comment: String?

    /// Names of unrecognized chunks encountered for this record (informational only).
    var unknownChunkNames: [String] = []

    var isEvent: Bool { type == "e" }
}
