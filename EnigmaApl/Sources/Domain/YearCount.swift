//
//  YearCount.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 04/03/2026.
//

// Indication of year count
enum YearCount: CaseIterable, Identifiable, Hashable {
    case ce
    case bc
    case astronomical

    var id: Self { self }
    var rbKey: String { YearCountKeys.key(for: self) }
}
