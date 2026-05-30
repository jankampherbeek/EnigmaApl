// DSTOption.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

enum DSTOption: CaseIterable, Identifiable, Hashable {
    case dst
    case noDST

    var id: Self { self }
    var rbKey: String { DSTOptionKeys.key(for: self) }
}
