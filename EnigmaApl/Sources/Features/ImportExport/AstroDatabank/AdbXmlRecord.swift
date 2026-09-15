// AdbXmlRecord.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Format-specific intermediate representation of one Astro-Databank
/// `<adb_entry>` (its `public_data`, plus `sourcenotes` from `text_data`).
/// Holds exactly the data physically present in the entry; no astrological
/// calculation happens here, and `<positions>` and `<research_data>` are
/// deliberately never read (see the format specification). `AdbXmlMapper`
/// converts this to the Enigma domain model; there is no export direction,
/// Astro-Databank XML is import-only.
struct AdbXmlRecord {
    var adbId: String?
    var name: String?
    var sflname: String?
    var birthname: String?
    /// `gender`'s `csex` attribute: "m", "f", "e", or "u".
    var genderCode: String?
    /// `roddenrating` element text, e.g. "AA", "A", "DD", "X".
    var roddenRating: String?

    var hasDate = false
    var isGregorian = true
    var year = 0
    var month = 0
    var day = 0

    var hasTime = false
    var hour = 0
    var minute = 0
    var second = 0
    /// `sbtime`'s `ctimetype` attribute: "s", "d", "w", "2", "h", "l", or "u".
    var timeTypeCode: String?
    /// `sbtime`'s `stmerid` attribute, e.g. "h1e", "m72e30". Raw text; parsed by `AdbXmlMapper`.
    var stmerid: String?
    /// `sbtime`'s `jd_ut` attribute, used only as a consistency check.
    var jdUt: Double?

    var placeName: String?
    var latitude: Double?
    var longitude: Double?

    var countryName: String?
    /// `country`'s `sctr` attribute; not necessarily an ISO code.
    var countryCode: String?

    var sourceNotes: String?

    /// True when a `<bdata_alt>` block was present; its contents are never read (see spec 4.18).
    var hasAlternativeBirthData = false
}
