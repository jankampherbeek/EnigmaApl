// LongTimeEphemerisRow.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

struct LongTimeEphemerisRow: Identifiable, Sendable {
    let id: Int
    let julianDay: Double
    let dateTimeString: String
    let values: [Factors: Double]
}
