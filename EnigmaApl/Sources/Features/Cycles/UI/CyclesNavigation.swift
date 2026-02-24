//
//  CyclesNavigation.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import Combine

struct CyclesNav: Equatable {
    var selectedID: UUID? = nil
    var section: CyclesSection = .chart
}

enum CyclesSection: String, CaseIterable, Identifiable, Hashable {
    case chart = "Grafiek"
    case stats = "Statistiek"
    var id: String { rawValue }
}

@MainActor
final class CyclesNavigator: ObservableObject {
    @Binding private var nav: CyclesNav
    init(nav: Binding<CyclesNav>) { _nav = nav }

    func select(_ id: UUID?) {
        nav.selectedID = id
        if id != nil { nav.section = .chart }
    }

    func setSection(_ section: CyclesSection) {
        nav.section = section
    }
}
