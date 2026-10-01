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
        List {
            Section(nv(NavigationKeys.sidebarModes)) {
                ForEach(AppMode.sidebarModes) { mode in
                    Button { unsavedChanges.perform { app.setMode(mode) } } label: {
                        row(le(mode.rbKey), app.nav.mode == mode, icon: mode.systemImage)
                    }
                    .buttonStyle(.plain)
                }
            }

            switch app.nav.mode {
            case .radix:
                Section(le(AppMode.radix.rbKey)) {
                    Button { radixNav.setInspector(.overview) } label: {
                        row(le(RadixInspector.overview.rbKey), app.nav.radix.inspector == .overview)
                    }.buttonStyle(.plain)
                    Button { radixNav.setInspector(.positions) } label: {
                        row(le(RadixInspector.positions.rbKey), app.nav.radix.inspector == .positions)
                    }.buttonStyle(.plain)
                    Button { radixNav.setInspector(.analysis) } label: {
                        row(le(RadixInspector.analysis.rbKey), app.nav.radix.inspector == .analysis)
                    }.buttonStyle(.plain)
                    Button { radixNav.setInspector(.search) } label: {
                        row(le(RadixInspector.search.rbKey), app.nav.radix.inspector == .search)
                    }.buttonStyle(.plain)
                }
            case .progressive:
                Section(le(AppMode.progressive.rbKey)) {
                    ForEach(ProgressiveSection.allCases) { section in
                        Button { progressiveNav.setSection(section) } label: {
                            row(le(section.rbKey), app.nav.progressive.section == section)
                        }
                        .buttonStyle(.plain)
                    }
                }
            case .research:
                Section(le(AppMode.research.rbKey)) {
                    Button { researchNav.setSection(.projects) } label: {
                        row(le(ResearchSection.projects.rbKey), app.nav.research.section == .projects)
                    }.buttonStyle(.plain)
                }
            case .cycles:
                Section(le(AppMode.cycles.rbKey)) {
                    Button { cyclesNav.setSection(.astronomicalCycles) } label: {
                        row(le(CyclesSection.astronomicalCycles.rbKey), app.nav.cycles.section == .astronomicalCycles)
                    }.buttonStyle(.plain)
                    Button { cyclesNav.setSection(.waves) } label: {
                        row(le(CyclesSection.waves.rbKey), app.nav.cycles.section == .waves)
                    }.buttonStyle(.plain)
                    Button { cyclesNav.setSection(.tablesGraphs) } label: {
                        row(le(CyclesSection.tablesGraphs.rbKey), app.nav.cycles.section == .tablesGraphs)
                    }.buttonStyle(.plain)
                    Button { cyclesNav.setSection(.ephemeris) } label: {
                        row(le(CyclesSection.ephemeris.rbKey), app.nav.cycles.section == .ephemeris)
                    }.buttonStyle(.plain)
                    Button { cyclesNav.setSection(.longTimeEphemeris) } label: {
                        row(le(CyclesSection.longTimeEphemeris.rbKey), app.nav.cycles.section == .longTimeEphemeris)
                    }.buttonStyle(.plain)
                    Button { cyclesNav.setSection(.eclipses) } label: {
                        row(le(CyclesSection.eclipses.rbKey), app.nav.cycles.section == .eclipses)
                    }.buttonStyle(.plain)
                }
            case .fixstars:
                EmptyView()
            case .calculators:
                Section(le(AppMode.calculators.rbKey)) {
                    ForEach(CalculatorsSection.allCases) { section in
                        Button { calculatorsNav.setSection(section) } label: {
                            row(le(section.rbKey), app.nav.calculators.section == section)
                        }
                        .buttonStyle(.plain)
                    }
                }
            case .config:
                EmptyView()
            case .synastry:
                EmptyView()
            case .importExport:
                Section(le(AppMode.importExport.rbKey)) {
                    ForEach(ImportExportSection.allCases) { section in
                        Button { importExportNav.setSection(section) } label: {
                            row(le(section.rbKey), app.nav.importExport.section == section)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle(nv(NavigationKeys.sidebarTitle))
    }

    private func row(_ title: String, _ selected: Bool) -> some View {
        HStack {
            Text(title)
            Spacer()
            if selected { Image(systemName: "checkmark").foregroundStyle(.secondary) }
        }
    }

    private func row(_ title: String, _ selected: Bool, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            if selected { Image(systemName: "checkmark").foregroundStyle(.secondary) }
        }
    }
}

private func nv(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Navigation", bundle: .main, comment: "")
}

private func le(_ key: String) -> String {
    NSLocalizedString(key, bundle: .main, comment: "")
}
