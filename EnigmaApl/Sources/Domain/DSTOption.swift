//
//  DSTOption.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 06/03/2026.
//

enum DSTOption: CaseIterable, Identifiable, Hashable {
    case dst
    case noDST

    var id: Self { self }
    var rbKey: String { DSTOptionKeys.key(for: self) }
}
