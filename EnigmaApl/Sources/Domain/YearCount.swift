// YearCount.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

// Indication of year count
enum YearCount: CaseIterable, Identifiable, Hashable {
    case ce
    case bc
    case astronomical

    var id: Self { self }
    var rbKey: String { YearCountKeys.key(for: self) }
}
