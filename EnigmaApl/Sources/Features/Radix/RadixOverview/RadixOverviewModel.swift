// RadixOverviewModel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation
import Combine

@MainActor
final class RadixOverviewModel: ObservableObject {

    /// Formats a Julian Day number for display.
    func formattedJulianDay(_ julianDay: Double) -> String {
        String(format: "%.4f", julianDay)
    }
}
