// HoroscopeDateTimeModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import SwiftData

/// Persistent model for a date and time belonging to a horoscope.
/// Multiple instances per horoscope are supported for uncertain birth times.
/// julianDate is Universal Time (UT) as used by the Swiss Ephemeris.
@Model
final class HoroscopeDateTimeModel {
    var id: UUID
    /// Julian Date in Universal Time (UT), as required by the Swiss Ephemeris.
    var julianDate: Double
    /// IANA timezone identifier, e.g. "Europe/Amsterdam". Used to reconstruct local time for display.
    var timeZoneIdentifier: String
    /// True when the time of birth is unknown. julianDate then conventionally represents noon (0.5 fraction).
    var timeIsUnknown: Bool
    /// True for the time used in calculations. Exactly one DateTime per horoscope should be preferred.
    var isPreferred: Bool
    /// Optional label to distinguish multiple times, e.g. "Opgegeven tijd", "Rectificatie A".
    var label: String?
    /// The original date and time as entered by the user, for display and feedback purposes.
    var originalInput: String?

    var horoscope: HoroscopeModel?

    init(
        julianDate: Double,
        timeZoneIdentifier: String = "UTC",
        timeIsUnknown: Bool = false,
        isPreferred: Bool = true,
        label: String? = nil,
        originalInput: String? = nil
    ) {
        self.id = UUID()
        self.julianDate = julianDate
        self.timeZoneIdentifier = timeZoneIdentifier
        self.timeIsUnknown = timeIsUnknown
        self.isPreferred = isPreferred
        self.label = label
        self.originalInput = originalInput
    }
}
