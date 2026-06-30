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

    var body: some View {
        List {
            Section("Werkmodi") {
                ForEach(AppMode.sidebarModes) { mode in
                    Button { app.setMode(mode) } label: {
                        row(mode.rawValue, app.nav.mode == mode, icon: mode.systemImage)
                    }
                    .buttonStyle(.plain)
                }
            }

            switch app.nav.mode {
            case .radix:
                Section("Radix") {
                    Button { radixNav.setInspector(.overview) } label: {
                        row(RadixInspector.overview.rawValue, app.nav.radix.inspector == .overview)
                    }.buttonStyle(.plain)
                    Button { radixNav.setInspector(.positions) } label: {
                        row(RadixInspector.positions.rawValue, app.nav.radix.inspector == .positions)
                    }.buttonStyle(.plain)
                    Button { radixNav.setInspector(.analysis) } label: {
                        row(RadixInspector.analysis.rawValue, app.nav.radix.inspector == .analysis)
                    }.buttonStyle(.plain)
                    Button { radixNav.setInspector(.search) } label: {
                        row(RadixInspector.search.rawValue, app.nav.radix.inspector == .search)
                    }.buttonStyle(.plain)
                }
            case .progressive:
                Section("Progressive") {
                    ForEach(ProgressiveSection.allCases) { section in
                        Button { progressiveNav.setSection(section) } label: {
                            row(section.rawValue, app.nav.progressive.section == section)
                        }
                        .buttonStyle(.plain)
                    }
                }
            case .research:
                Section("Research") {
                    Button { researchNav.setSection(.projects) } label: {
                        row(ResearchSection.projects.rawValue, app.nav.research.section == .projects)
                    }.buttonStyle(.plain)
                }
            case .cycles:
                Section("Cycli") {
                    Button { cyclesNav.setSection(.astronomicalCycles) } label: {
                        row(CyclesSection.astronomicalCycles.rawValue, app.nav.cycles.section == .astronomicalCycles)
                    }.buttonStyle(.plain)
                    Button { cyclesNav.setSection(.waves) } label: {
                        row(CyclesSection.waves.rawValue, app.nav.cycles.section == .waves)
                    }.buttonStyle(.plain)
                    Button { cyclesNav.setSection(.tablesGraphs) } label: {
                        row(CyclesSection.tablesGraphs.rawValue, app.nav.cycles.section == .tablesGraphs)
                    }.buttonStyle(.plain)
                    Button { cyclesNav.setSection(.ephemeris) } label: {
                        row(CyclesSection.ephemeris.rawValue, app.nav.cycles.section == .ephemeris)
                    }.buttonStyle(.plain)
                }
            case .fixstars:
                EmptyView()
            case .calculators:
                Section("Calculators") {
                    ForEach(CalculatorsSection.allCases) { section in
                        Button { calculatorsNav.setSection(section) } label: {
                            row(section.rawValue, app.nav.calculators.section == section)
                        }
                        .buttonStyle(.plain)
                    }
                }
            case .config:
                EmptyView()
            }
        }
        .navigationTitle("Navigatie")
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
