// PresentableVspPosition.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import Foundation

/// A Venus Star Point position ready for display in the UI.
struct PresentableVspPosition: Identifiable {
    var id: Int { sequenceId }
    let sequenceId: Int
    let phenomenon: VenusPhenomena
    /// Julian Day of the exact Sun–Venus conjunction.
    let jd: Double
    /// Formatted as "yyyy/mm/dd hh:mi:ss"
    let dateText: String
    /// Ecliptical longitude in degrees (0–360)
    let longitude: Double
}
