//
//  AppState.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import Combine

// The central observable state

@MainActor
final class AppState: ObservableObject {
    @Published var nav = NavigationState()
    @Published var ui = UIState()

    // Demo data
    @Published var radixItems: [RadixItem] = [
        .init(id: UUID(), title: "Horoscope"),
        .init(id: UUID(), title: "Positions"),
        .init(id: UUID(), title: "Analysis"),
    ]
    @Published var projects: [ResearchProject] = [
        .init(id: UUID(), title: "Datafiles"),
        .init(id: UUID(), title: "Projects"),
    ]
    @Published var profiles: [CyclesProfile] = [
        .init(id: UUID(), title: "Astronomical Cycles"),
        .init(id: UUID(), title: "Waves"),
        .init(id: UUID(), title: "Tables/Graphs"),
    ]
    func ensureDefaultSelection() {
        switch nav.mode {
        case .radix:
            if nav.radix.selectedID == nil { nav.radix.selectedID = radixItems.first?.id }
        case .progressive:
            break
        case .research:
            if nav.research.selectedID == nil { nav.research.selectedID = projects.first?.id }
        case .cycles:
            if nav.cycles.selectedID == nil { nav.cycles.selectedID = profiles.first?.id }
        case .fixstars:
            break
        case .calculators:
            break
        case .config:
            break
        case .synastry:
            break
        }
    }

    func setMode(_ mode: AppMode) {
        guard nav.mode != mode else { return }
        nav.mode = mode
        if mode == .radix { nav.radix.inspector = .overview }
        ensureDefaultSelection()
    }

    func openNewChartInDetail(isCompact: Bool) {
        DispatchQueue.main.async {
            // Assign whole UIState once to avoid nested publishes during a render pass.
            var next = self.ui
            next.showRadixInputInDetail = true
            if isCompact { next.showInspectorSheet = true }
            self.ui = next
        }
    }

    func closeNewChartDetail() {
        DispatchQueue.main.async {
            var next = self.ui
            next.showRadixInputInDetail = false
            next.showInspectorSheet = false
            self.ui = next
        }
    }

    func setInspectorSheet(_ isPresented: Bool) {
        DispatchQueue.main.async {
            var next = self.ui
            next.showInspectorSheet = isPresented
            self.ui = next
        }
    }

}



enum AppMode: String, CaseIterable, Identifiable, Hashable {
    case radix = "Radix"
    case progressive = "Progressive"
    case fixstars = "Fixed Stars"
    case research = "Research"
    case cycles = "Periods"
    case calculators = "Calculators"
    case config = "Configuratie"
    case synastry = "Synastry"

    var id: String { rawValue }

    // Modes shown in the sidebar; fixstars is accessed via the Radix overview button instead.
    static var sidebarModes: [AppMode] {
        allCases.filter { $0 != .fixstars }
    }

    var systemImage: String {
        switch self {
        case .radix:        return "circle.grid.cross"
        case .progressive:  return "arrow.forward.circle"
        case .fixstars:     return "star.circle"
        case .research:     return "flask"
        case .cycles:       return "waveform.path.ecg"
        case .calculators:  return "function"
        case .config:       return "gear"
        case .synastry:     return "person.2.circle"
        }
    }
}

// MARK: - Navigation State

struct NavigationState: Equatable {
    var mode: AppMode = .radix
    var radix = RadixNav()
    var progressive = ProgressiveNav()
    var research = ResearchNav()
    var cycles = CyclesNav()
    var calculators = CalculatorsNav()
    var synastry = SynastryNav()
}

struct UIState: Equatable {
    var sidebarSearch: String = ""
    var showInspectorSheet: Bool = false
    var showRadixInputInDetail: Bool = false
    var blackWhite: Bool = false
    var hideAspects: Bool = false
    var hideTime: Bool = false
}




// MARK: - Demo Models (replace with SwiftData / repositories)

struct RadixItem: Identifiable, Hashable { let id: UUID; var title: String }
struct ResearchProject: Identifiable, Hashable { let id: UUID; var title: String }
struct CyclesProfile: Identifiable, Hashable { let id: UUID; var title: String }
