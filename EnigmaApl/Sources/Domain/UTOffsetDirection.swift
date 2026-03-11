//
//  UTOffsetDirection.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 06/03/2026.
//

enum UTOffsetDirection: CaseIterable, Identifiable, Hashable {
    case later
    case earlier

    var id: Self { self }
    var rbKey: String { UTOffsetDirectionKeys.key(for: self) }
}
