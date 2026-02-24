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
    var section: ResearchSection = .editor
}

enum ResearchSection: String, CaseIterable, Identifiable, Hashable {
    case editor = "Input"
    case results = "Resultaten"
    case notes = "Notities"
    var id: String { rawValue }
}


@MainActor
final class ResearchNavigator: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    @Binding private var nav: ResearchNav
    init(nav: Binding<ResearchNav>) { _nav = nav }

    func select(_ id: UUID?) {
        objectWillChange.send()
        nav.selectedID = id
        if id != nil { nav.section = .editor }
    }

    func setSection(_ section: ResearchSection) {
        objectWillChange.send()
        nav.section = section
    }
}

