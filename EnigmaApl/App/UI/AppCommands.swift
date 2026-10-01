// AppCommands.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct AppCommands: Commands {
    @ObservedObject var app: AppState
    @ObservedObject var radixNav: RadixNavigator
    @ObservedObject var progressiveNav: ProgressiveNavigator
    @ObservedObject var researchNav: ResearchNavigator
    @ObservedObject var cyclesNav: CyclesNavigator
    @ObservedObject var importExportNav: ImportExportNavigator
    @ObservedObject var unsavedChanges: UnsavedChangesGuard
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button(NSLocalizedString("about.menu.item", tableName: "About", bundle: .main, comment: "")) {
                openWindow(id: "about")
            }
        }
        CommandGroup(after: .help) {
            Button(NSLocalizedString(GlyphOverviewKeys.menuItem, tableName: "GlyphOverview", bundle: .main, comment: "")) {
                app.ui.showGlyphOverview = true
            }
        }
        CommandMenu(le(AppMode.radix.rbKey)) {
            Button(activate(.radix)) { unsavedChanges.perform { app.setMode(.radix) } }
                .keyboardShortcut("1", modifiers: [.command, .shift])
            Divider()
            Button(le(RadixInspector.overview.rbKey))  { unsavedChanges.perform { app.setMode(.radix); radixNav.setInspector(.overview) } }
                .keyboardShortcut("1", modifiers: [.command, .option])
            Button(le(RadixInspector.positions.rbKey)) { unsavedChanges.perform { app.setMode(.radix); radixNav.setInspector(.positions) } }
                .keyboardShortcut("2", modifiers: [.command, .option])
            Button(le(RadixInspector.analysis.rbKey))  { unsavedChanges.perform { app.setMode(.radix); radixNav.setInspector(.analysis) } }
                .keyboardShortcut("3", modifiers: [.command, .option])
            Button(le(RadixInspector.analysisDeclinations.rbKey)) { unsavedChanges.perform { app.setMode(.radix); radixNav.setInspector(.analysisDeclinations) } }
            Button(le(RadixInspector.analysisLots.rbKey)) { unsavedChanges.perform { app.setMode(.radix); radixNav.setInspector(.analysisLots) } }
            Button(le(RadixInspector.search.rbKey))    { unsavedChanges.perform { app.setMode(.radix); radixNav.setInspector(.search) } }
                .keyboardShortcut("4", modifiers: [.command, .option])
        }

        CommandMenu(le(AppMode.progressive.rbKey)) {
            Button(activate(.progressive)) { unsavedChanges.perform { app.setMode(.progressive) } }
                .keyboardShortcut("2", modifiers: [.command, .shift])
            Divider()
            ForEach(ProgressiveSection.allCases) { section in
                Button(le(section.rbKey)) { unsavedChanges.perform { app.setMode(.progressive); progressiveNav.setSection(section) } }
            }
        }

        CommandMenu(le(AppMode.research.rbKey)) {
            Button(le(ResearchSection.projects.rbKey)) { unsavedChanges.perform { app.setMode(.research); researchNav.setSection(.projects) } }
                .keyboardShortcut("5", modifiers: [.command, .option])
        }

        CommandMenu(le(AppMode.cycles.rbKey)) {
            Button(activate(.cycles)) { unsavedChanges.perform { app.setMode(.cycles) } }
                .keyboardShortcut("3", modifiers: [.command, .shift])
            Divider()
            Button(le(CyclesSection.astronomicalCycles.rbKey)) { unsavedChanges.perform { app.setMode(.cycles); cyclesNav.setSection(.astronomicalCycles) } }
                .keyboardShortcut("7", modifiers: [.command, .option])
            Button(le(CyclesSection.waves.rbKey))              { unsavedChanges.perform { app.setMode(.cycles); cyclesNav.setSection(.waves) } }
                .keyboardShortcut("8", modifiers: [.command, .option])
            Button(le(CyclesSection.tablesGraphs.rbKey))       { unsavedChanges.perform { app.setMode(.cycles); cyclesNav.setSection(.tablesGraphs) } }
                .keyboardShortcut("9", modifiers: [.command, .option])
            Button(le(CyclesSection.ephemeris.rbKey))          { unsavedChanges.perform { app.setMode(.cycles); cyclesNav.setSection(.ephemeris) } }
            Button(le(CyclesSection.longTimeEphemeris.rbKey))  { unsavedChanges.perform { app.setMode(.cycles); cyclesNav.setSection(.longTimeEphemeris) } }
            Button(le(CyclesSection.eclipses.rbKey))           { unsavedChanges.perform { app.setMode(.cycles); cyclesNav.setSection(.eclipses) } }
        }

        CommandMenu(le(AppMode.config.rbKey)) {
            Button(activate(.config)) { unsavedChanges.perform { app.setMode(.config) } }
                .keyboardShortcut("4", modifiers: [.command, .shift])
        }

        CommandGroup(after: .importExport) {
            Button(activate(.importExport)) { unsavedChanges.perform { app.setMode(.importExport) } }
            ForEach(ImportExportSection.allCases) { section in
                Button(le(section.rbKey)) { unsavedChanges.perform { app.setMode(.importExport); importExportNav.setSection(section) } }
            }
        }

        CommandMenu(nv(NavigationKeys.menuDisplay)) {
            Button(nv(app.ui.blackWhite ? NavigationKeys.menuSwitchToColor : NavigationKeys.menuSwitchToBlackWhite)) {
                app.ui.blackWhite.toggle()
            }
            .keyboardShortcut("b", modifiers: [.command, .shift])

            Button(nv(app.ui.hideAspects ? NavigationKeys.menuShowAspects : NavigationKeys.menuHideAspects)) {
                app.ui.hideAspects.toggle()
            }
            .keyboardShortcut("a", modifiers: [.command, .shift])

            Button(nv(app.ui.hideTime ? NavigationKeys.menuShowTime : NavigationKeys.menuHideTime)) {
                app.ui.hideTime.toggle()
            }
            .keyboardShortcut("t", modifiers: [.command, .shift])
        }
    }

    /// Menu item text for activating a work mode, e.g. "Activate Radix".
    private func activate(_ mode: AppMode) -> String {
        String(format: nv(NavigationKeys.menuActivate), le(mode.rbKey))
    }
}

private func nv(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Navigation", bundle: .main, comment: "")
}

private func le(_ key: String) -> String {
    NSLocalizedString(key, bundle: .main, comment: "")
}
