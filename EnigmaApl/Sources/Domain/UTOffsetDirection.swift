// UTOffsetDirection.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

enum UTOffsetDirection: CaseIterable, Identifiable, Hashable {
    case later
    case earlier

    var id: Self { self }
    var rbKey: String { UTOffsetDirectionKeys.key(for: self) }
}
