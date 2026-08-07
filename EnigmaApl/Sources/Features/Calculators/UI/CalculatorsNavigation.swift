// CalculatorsNavigation.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Combine

struct CalculatorsNav: Equatable {
    var section: CalculatorsSection = .julianDay
}

enum CalculatorsSection: String, CaseIterable, Identifiable, Hashable {
    case julianDay    = "Julian Day"
    case obliquity    = "Obliquity"
    var id: String { rawValue }
}

@MainActor
final class CalculatorsNavigator: ObservableObject {
    @Binding private var nav: CalculatorsNav
    init(nav: Binding<CalculatorsNav>) { _nav = nav }

    func setSection(_ section: CalculatorsSection) {
        nav.section = section
    }
}
