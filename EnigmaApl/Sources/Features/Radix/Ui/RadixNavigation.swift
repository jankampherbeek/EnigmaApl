//
//  RadixNavigation.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//
import SwiftUI
import Combine

// Feature coordinator used by views

struct RadixNav: Equatable {
    var selectedID: UUID? = nil
    var inspector: RadixInspector = .horoscope
}


enum RadixInspector: String, CaseIterable, Identifiable, Hashable {
    case horoscope = "Horoscope"
    case positions = "Positions"
    case analysis = "Analysis"
    case newChart = "New Chart"
    case search = "Zoek"
    var id: String { rawValue }
}


@MainActor
final class RadixNavigator: ObservableObject {
    @Binding private var nav: RadixNav
    init(nav: Binding<RadixNav>) { _nav = nav }

    func select(_ id: UUID?) {
        nav.selectedID = id
        if id != nil { nav.inspector = .horoscope }
    }

    func setInspector(_ section: RadixInspector) {
        nav.inspector = section
    }
}
