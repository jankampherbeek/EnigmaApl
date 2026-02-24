//
//  AppState.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var nav = NavigationState()
    @Published var ui = UIState()

    // Demo data
    @Published var radixItems: [RadixItem] = [
        .init(id: UUID(), title: "Jan — 12:34"),
        .init(id: UUID(), title: "Marie — 09:10"),
        .init(id: UUID(), title: "Project X — 18:05"),
    ]
    @Published var projects: [ResearchProject] = [
        .init(id: UUID(), title: "Proef: Halfsommen"),
        .init(id: UUID(), title: "Dataset: 1900–1950"),
        .init(id: UUID(), title: "Vergelijking huizensystemen"),
    ]
    @Published var profiles: [CyclesProfile] = [
        .init(id: UUID(), title: "Saturnus-cyclus"),
        .init(id: UUID(), title: "Jupiter transits"),
        .init(id: UUID(), title: "Progressies preset A"),
    ]

    func ensureDefaultSelection() {
        switch nav.mode {
        case .radix:
            if nav.radix.selectedID == nil { nav.radix.selectedID = radixItems.first?.id }
        case .research:
            if nav.research.selectedID == nil { nav.research.selectedID = projects.first?.id }
        case .cycles:
            if nav.cycles.selectedID == nil { nav.cycles.selectedID = profiles.first?.id }
        }
    }
}



enum AppMode: String, CaseIterable, Identifiable, Hashable {
    case radix = "Radix"
    case research = "Onderzoek"
    case cycles = "Cycli"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .radix: return "circle.grid.cross"
        case .research: return "flask"
        case .cycles: return "waveform.path.ecg"
        }
    }
}

// MARK: - Navigation State

struct NavigationState: Equatable {
    var mode: AppMode = .radix
    var radix = RadixNav()
    var research = ResearchNav()
    var cycles = CyclesNav()
}

struct UIState: Equatable {
    var sidebarSearch: String = ""
    var showInspectorSheet: Bool = false
}




// MARK: - Demo Models (replace with SwiftData / repositories)

struct RadixItem: Identifiable, Hashable { let id: UUID; var title: String }
struct ResearchProject: Identifiable, Hashable { let id: UUID; var title: String }
struct CyclesProfile: Identifiable, Hashable { let id: UUID; var title: String }
