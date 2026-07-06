// CyclesNavigation.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Combine

struct CyclesNav: Equatable {
    var selectedID: UUID? = nil
    var section: CyclesSection = .astronomicalCycles
}

enum CyclesSection: String, CaseIterable, Identifiable, Hashable {
    case astronomicalCycles = "Astronomical Cycles"
    case waves = "Waves"
    case tablesGraphs = "Tables/Graphs"
    case ephemeris = "Ephemeris"
    case eclipses = "Eclipses"
    var id: String { rawValue }
}

@MainActor
final class CyclesNavigator: ObservableObject {
    @Binding private var nav: CyclesNav
    init(nav: Binding<CyclesNav>) { _nav = nav }

    func select(_ id: UUID?) {
        nav.selectedID = id
        if id != nil { nav.section = .astronomicalCycles }
    }

    func setSection(_ section: CyclesSection) {
        nav.section = section
    }
}
