// LocalToUtJulianDay.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// Converts a local calendar date/time plus a known UTC offset into a Julian
/// Day in Universal Time, as required by `HoroscopeDateTimeModel.julianDate`.
/// Exchange formats (QCK, AAF'97, Astro-Databank XML) supply an explicit
/// offset rather than an IANA zone, so `TzResolver` does not apply here;
/// this mirrors the same technique `TzResolver` uses internally: read the
/// local clock numbers as if they were UT to get a Julian Day on the local
/// scale, then shift by the offset (expressed in days) to reach true UT.
enum LocalToUtJulianDay {

    static func convert(localDate: AstronomicalDate, localTime: AstronomicalTime, offsetSeconds: Int, seWrapper: SEWrapper) -> Double {
        let localJd = seWrapper.julianDay(date: localDate, time: localTime)
        return localJd - Double(offsetSeconds) / 86400.0
    }
}
