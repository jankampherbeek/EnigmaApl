// SynastryNavigation.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Combine

enum SynastryResultType: String, CaseIterable, Identifiable, Hashable {
    case compare
    case composite
    case combine
    case aspectComparison
    case midpointComparison
    case declinationComparison

    var id: String { rawValue }
}

struct SynastryNav: Equatable {
    var resultType: SynastryResultType? = nil
}

@MainActor
final class SynastryNavigator: ObservableObject {
    @Binding private var nav: SynastryNav

    init(nav: Binding<SynastryNav>) { _nav = nav }

    func showResult(_ type: SynastryResultType) {
        nav.resultType = type
    }

    func closeResult() {
        nav.resultType = nil
    }
}
