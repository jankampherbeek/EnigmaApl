//
//  DetailColumn.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import Combine


// MARK: - Minimal placeholder views (keep your existing implementations)


struct DetailColumn: View {
    @EnvironmentObject private var app: AppState
    var body: some View {
        Group {
            switch app.nav.mode {
            case .radix:
                switch app.nav.radix.inspector {
                case .horoscope:
                    Text("Detail (Radix)")
                case .positions:
                    PositionsScreen()
                case .analysis:
                    AnalysisScreen()
                }
            case .research:
                switch app.nav.research.section {
                case .datafiles:
                    DatafilesScreen()
                case .projects:
                    ProjectsScreen()
                }
            case .cycles:
                switch app.nav.cycles.section {
                case .astronomicalCycles:
                    AstronomicalCyclesScreen()
                case .waves:
                    WavesScreen()
                case .tablesGraphs:
                    TablesGraphsScreen()
                }
            }
        }
        .navigationTitle("Detail")
    }
}
