//
//  YearCount.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 04/03/2026.
//

// Indication of year count
enum YearCount: String, CaseIterable, Identifiable {
    case ce = "enum.yearcount.ce"
    case bc = "enum.yearcount.bce"
    case astronomical = "enum.yearcount.astronomical"
    var id: String { rawValue }
}
