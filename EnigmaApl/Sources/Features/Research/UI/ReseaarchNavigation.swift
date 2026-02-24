//
//  ReseaarchNavigation.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

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
