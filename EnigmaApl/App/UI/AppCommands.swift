// AppCommands.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct AppCommands: Commands {
    @ObservedObject var app: AppState
    @ObservedObject var radixNav: RadixNavigator
    @ObservedObject var researchNav: ResearchNavigator
    @ObservedObject var cyclesNav: CyclesNavigator
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button(NSLocalizedString("about.menu.item", tableName: "About", bundle: .main, comment: "")) {
                openWindow(id: "about")
            }
        }
        CommandMenu("Radix") {
            Button("Activeer Radix") { app.setMode(.radix) }
                .keyboardShortcut("1", modifiers: [.command, .shift])
            Divider()
            Button("Overzicht")  { app.setMode(.radix); radixNav.setInspector(.overview) }
                .keyboardShortcut("1", modifiers: [.command, .option])
            Button("Positions")  { app.setMode(.radix); radixNav.setInspector(.positions) }
                .keyboardShortcut("2", modifiers: [.command, .option])
            Button("Analysis")   { app.setMode(.radix); radixNav.setInspector(.analysis) }
                .keyboardShortcut("3", modifiers: [.command, .option])
            Button("Declinations") { app.setMode(.radix); radixNav.setInspector(.analysisDeclinations) }
            Button("Zoek")       { app.setMode(.radix); radixNav.setInspector(.search) }
                .keyboardShortcut("4", modifiers: [.command, .option])
        }

        CommandMenu("Research") {
            Button("Activeer Research") { app.setMode(.research) }
                .keyboardShortcut("2", modifiers: [.command, .shift])
            Divider()
            Button("Datafiles") { app.setMode(.research); researchNav.setSection(.datafiles) }
                .keyboardShortcut("5", modifiers: [.command, .option])
            Button("Projects")  { app.setMode(.research); researchNav.setSection(.projects) }
                .keyboardShortcut("6", modifiers: [.command, .option])
        }

        CommandMenu("Cycles") {
            Button("Activeer Cycles") { app.setMode(.cycles) }
                .keyboardShortcut("3", modifiers: [.command, .shift])
            Divider()
            Button("Astronomical Cycles") { app.setMode(.cycles); cyclesNav.setSection(.astronomicalCycles) }
                .keyboardShortcut("7", modifiers: [.command, .option])
            Button("Waves")               { app.setMode(.cycles); cyclesNav.setSection(.waves) }
                .keyboardShortcut("8", modifiers: [.command, .option])
            Button("Tables/Graphs")        { app.setMode(.cycles); cyclesNav.setSection(.tablesGraphs) }
                .keyboardShortcut("9", modifiers: [.command, .option])
        }

        CommandMenu("Configuratie") {
            Button("Activeer Configuratie") { app.setMode(.config) }
                .keyboardShortcut("4", modifiers: [.command, .shift])
        }

        CommandMenu("Weergave") {
            Button(app.ui.blackWhite ? "Switch to Color" : "Switch to Black & White") {
                app.ui.blackWhite.toggle()
            }
            .keyboardShortcut("b", modifiers: [.command, .shift])

            Button(app.ui.hideAspects ? "Show Aspects" : "Hide Aspects") {
                app.ui.hideAspects.toggle()
            }
            .keyboardShortcut("a", modifiers: [.command, .shift])

            Button(app.ui.hideTime ? "Show Time" : "Hide Time") {
                app.ui.hideTime.toggle()
            }
            .keyboardShortcut("t", modifiers: [.command, .shift])
        }
    }
}
