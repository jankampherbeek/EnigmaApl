// RadixNavigation.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
import SwiftUI
import Combine

// Feature coordinator used by views

struct RadixNav: Equatable {
    var selectedID: UUID? = nil
    var inspector: RadixInspector = .overview
}


enum RadixInspector: String, CaseIterable, Identifiable, Hashable {
    case overview        = "Overzicht"
    case horoscope       = "Horoscope"
    case positions       = "Positions"
    case analysis        = "Analysis"
    case analysisAspects    = "Aspecten"
    case analysisMidpoints  = "Midpunten"
    case analysisHarmonics  = "Harmonischen"
    case analysisDeclinations = "Declinaties"
    case analysisZodiacDivisions = "ZodiacDivisions"
    case analysisEnneagram       = "Enneagram"
    case newChart        = "New Chart"
    case search          = "Zoek"
    case editChart       = "Wijzig"
    var id: String { rawValue }
}


@MainActor
final class RadixNavigator: ObservableObject {
    @Binding private var nav: RadixNav
    init(nav: Binding<RadixNav>) { _nav = nav }

    func select(_ id: UUID?) {
        nav.selectedID = id
        if id != nil { nav.inspector = .overview }
    }

    func setInspector(_ section: RadixInspector) {
        nav.inspector = section
    }
}
