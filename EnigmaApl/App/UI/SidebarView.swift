//
//  SidebarView.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import Combine

// The navigationbar in the left part of the NavigationSplitView of the app.

struct SidebarView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var radixNav: RadixNavigator
    @EnvironmentObject private var progressiveNav: ProgressiveNavigator
    @EnvironmentObject private var researchNav: ResearchNavigator
    @EnvironmentObject private var cyclesNav: CyclesNavigator
    @EnvironmentObject private var calculatorsNav: CalculatorsNavigator
    @EnvironmentObject private var configNav: ConfigNavigator
    @EnvironmentObject private var importExportNav: ImportExportNavigator
    @EnvironmentObject private var unsavedChanges: UnsavedChangesGuard

    var body: some View {
        List(selection: selection) {
            Section(nv(NavigationKeys.sidebarModes)) {
                ForEach(AppMode.sidebarModes) { mode in
                    Label(le(mode.rbKey), systemImage: mode.systemImage)
                        .tag(SidebarItem.mode(mode))
                }
            }

            switch app.nav.mode {
            case .radix:
                Section(le(AppMode.radix.rbKey)) {
                    ForEach(Self.radixItems) { inspector in
                        Text(le(inspector.rbKey)).tag(SidebarItem.radix(inspector))
                    }
                }
            case .progressive:
                Section(le(AppMode.progressive.rbKey)) {
                    ForEach(ProgressiveSection.allCases) { section in
                        Text(le(section.rbKey)).tag(SidebarItem.progressive(section))
                    }
                }
            case .research:
                Section(le(AppMode.research.rbKey)) {
                    ForEach(ResearchSection.allCases) { section in
                        Text(le(section.rbKey)).tag(SidebarItem.research(section))
                    }
                }
            case .cycles:
                Section(le(AppMode.cycles.rbKey)) {
                    ForEach(CyclesSection.allCases) { section in
                        Text(le(section.rbKey)).tag(SidebarItem.cycles(section))
                    }
                }
            case .calculators:
                Section(le(AppMode.calculators.rbKey)) {
                    ForEach(CalculatorsSection.allCases) { section in
                        Text(le(section.rbKey)).tag(SidebarItem.calculators(section))
                    }
                }
            case .config:
                EmptyView()
            case .synastry:
                EmptyView()
            case .importExport:
                Section(le(AppMode.importExport.rbKey)) {
                    ForEach(ImportExportSection.allCases) { section in
                        Text(le(section.rbKey)).tag(SidebarItem.importExport(section))
                    }
                }
            }
        }
        .navigationTitle(nv(NavigationKeys.sidebarTitle))
    }

    private static let radixItems: [RadixInspector] = [.overview, .positions, .analysis, .search]

    // The selected row shows the current location: the sub-item of the active mode,
    // or the mode itself when that mode has no sub-items.
    private var selection: Binding<SidebarItem?> {
        Binding(
            get: { currentItem },
            set: { item in
                guard let item, item != currentItem else { return }
                select(item)
            }
        )
    }

    private var currentItem: SidebarItem {
        switch app.nav.mode {
        case .radix:
            let inspector = app.nav.radix.inspector
            if inspector.isAnalysisItem { return .radix(.analysis) }
            return .radix(Self.radixItems.contains(inspector) ? inspector : .overview)
        case .progressive:  return .progressive(app.nav.progressive.section)
        case .research:     return .research(app.nav.research.section)
        case .cycles:       return .cycles(app.nav.cycles.section)
        case .calculators:  return .calculators(app.nav.calculators.section)
        case .importExport: return .importExport(app.nav.importExport.section)
        case .config, .synastry: return .mode(app.nav.mode)
        }
    }

    private func select(_ item: SidebarItem) {
        switch item {
        case .mode(let mode):              unsavedChanges.perform { app.setMode(mode) }
        case .radix(let inspector):        radixNav.setInspector(inspector)
        case .progressive(let section):    progressiveNav.setSection(section)
        case .research(let section):       researchNav.setSection(section)
        case .cycles(let section):         cyclesNav.setSection(section)
        case .calculators(let section):    calculatorsNav.setSection(section)
        case .importExport(let section):   importExportNav.setSection(section)
        }
    }
}

/// A selectable row in the sidebar.
private enum SidebarItem: Hashable {
    case mode(AppMode)
    case radix(RadixInspector)
    case progressive(ProgressiveSection)
    case research(ResearchSection)
    case cycles(CyclesSection)
    case calculators(CalculatorsSection)
    case importExport(ImportExportSection)
}

private func nv(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Navigation", bundle: .main, comment: "")
}

private func le(_ key: String) -> String {
    NSLocalizedString(key, bundle: .main, comment: "")
}
