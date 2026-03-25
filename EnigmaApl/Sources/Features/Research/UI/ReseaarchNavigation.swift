// ReseaarchNavigation.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Combine



struct ResearchNav: Equatable {
    var selectedID: UUID? = nil
    var section: ResearchSection = .datafiles
}

enum ResearchSection: String, CaseIterable, Identifiable, Hashable {
    case datafiles = "Datafiles"
    case projects = "Projects"
    var id: String { rawValue }
}


@MainActor
final class ResearchNavigator: ObservableObject {
    @Binding private var nav: ResearchNav
    init(nav: Binding<ResearchNav>) { _nav = nav }

    func select(_ id: UUID?) {
        nav.selectedID = id
        if id != nil { nav.section = .datafiles }
    }

    func setSection(_ section: ResearchSection) {
        nav.section = section
    }
}
