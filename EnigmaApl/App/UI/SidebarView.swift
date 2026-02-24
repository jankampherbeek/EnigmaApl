//
//  SidebarView.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import Combine


struct SidebarView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var radixNav: RadixNavigator
    @EnvironmentObject private var researchNav: ResearchNavigator
    @EnvironmentObject private var cyclesNav: CyclesNavigator

    var body: some View {
        List {
            Section("Werkmodi") {
                ForEach(AppMode.allCases) { mode in
                    Button { app.setMode(mode) } label: {
                        row(mode.rawValue, app.nav.mode == mode, icon: mode.systemImage)
                    }
                    .buttonStyle(.plain)
                }
            }

            switch app.nav.mode {
            case .radix:
                Section("Radix") {
                    ForEach(app.radixItems) { item in
                        Button { radixNav.select(item.id) } label: {
                            row(item.title, app.nav.radix.selectedID == item.id)
                        }.buttonStyle(.plain)
                    }
                }
            case .research:
                Section("Projecten") {
                    ForEach(app.projects) { project in
                        Button { researchNav.select(project.id) } label: {
                            row(project.title, app.nav.research.selectedID == project.id)
                        }.buttonStyle(.plain)
                    }
                }
            case .cycles:
                Section("Cycli") {
                    ForEach(app.profiles) { profile in
                        Button { cyclesNav.select(profile.id) } label: {
                            row(profile.title, app.nav.cycles.selectedID == profile.id)
                        }.buttonStyle(.plain)
                    }
                }
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
