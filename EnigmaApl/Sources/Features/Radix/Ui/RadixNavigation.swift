//
//  RadixNavigation.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//
import SwiftUI
import Combine

struct RadixNav: Equatable {
    var selectedID: UUID? = nil
    var inspector: RadixInspector = .aspects
}


enum RadixInspector: String, CaseIterable, Identifiable, Hashable {
    case aspects = "Aspecten"
    case midpoints = "Halfsommen"
    case progressions = "Progressies"
    var id: String { rawValue }
}


@MainActor
final class RadixNavigator: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    @Binding private var nav: RadixNav
    init(nav: Binding<RadixNav>) { _nav = nav }

    func select(_ id: UUID?) {
        objectWillChange.send()
        nav.selectedID = id
        if id != nil { nav.inspector = .aspects }
    }

    func setInspector(_ section: RadixInspector) {
        objectWillChange.send()
        nav.inspector = section
    }
}


