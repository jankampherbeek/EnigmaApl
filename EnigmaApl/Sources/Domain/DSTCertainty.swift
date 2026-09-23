// DSTCertainty.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

/// Flags date/location combinations where the historical DST rule cannot be trusted.
/// DST in the US was a local (city/state) option before the Uniform Time Act took effect in 1967,
/// so pre-1967 US DST data is unreliable regardless of what the bundled tz data resolves to.
enum DSTCertainty {
    static func isUncertain(countryCode: String?, year: Int) -> Bool {
        countryCode == "US" && year < 1967
    }
}
