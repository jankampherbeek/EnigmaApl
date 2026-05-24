// ProgressiveNavigation.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Combine

struct ProgressiveNav: Equatable {
    var section: ProgressiveSection = .events
}

enum ProgressiveSection: String, CaseIterable, Identifiable, Hashable {
    case events               = "Events"
    case primary              = "Primary"
    case secondary            = "Secondary"
    case transit              = "Transit"
    case symbolic             = "Symbolic"
    case solar                = "Solar"
    case prenatal             = "Prenatal"
    case logarithmicTimescale = "Logarithmic Timescale"
    case profections          = "Profections"
    case firdaria             = "Firdaria"
    case progressiveCalendar  = "Progressive Calendar"

    var id: String { rawValue }
}

@MainActor
final class ProgressiveNavigator: ObservableObject {
    @Binding private var nav: ProgressiveNav

    init(nav: Binding<ProgressiveNav>) { _nav = nav }

    func setSection(_ section: ProgressiveSection) {
        nav.section = section
    }
}
