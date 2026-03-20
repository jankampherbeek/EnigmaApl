//
//  DetailColumn.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import Combine

// The detail screen in the right part of the NavigationSplitView of the app.

// MARK: - Minimal placeholder views (keep your existing implementations)


struct DetailColumn: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var radixNav: RadixNavigator
    @EnvironmentObject private var chartSession: ChartSession

    private var detailTitle: String {
        switch app.nav.mode {
        case .radix:
            switch app.nav.radix.inspector {
            case .overview:
                return "Overzicht"
            case .newChart:
                return "Data for a new chart"
            case .positions:
                return "Positions"
            case .analysis:
                return "Analysis"
            case .horoscope:
                return "Detail (Radix)"
            case .search:
                return "Zoek horoscoop"
            case .editChart:
                return "Wijzig horoscoop"
            }
        case .research:
            return "Detail"
        case .cycles:
            return "Detail"
        }
    }

    var body: some View {
        Group {
            switch app.nav.mode {
            case .radix:
                switch app.nav.radix.inspector {
                case .overview:
                    RadixOverviewScreen()
                case .horoscope:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detail (Radix)")
                        Button("New Chart") {
                            radixNav.setInspector(.newChart)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
                case .newChart:
                    RadixInputScreen()
                case .positions:
                    PositionsScreen()
                case .analysis:
                    AnalysisScreen()
                case .search:
                    RadixSearchScreen()
                case .editChart:
                    if let horoscope = chartSession.editingHoroscope {
                        RadixEditScreen(horoscope: horoscope)
                    } else {
                        RadixOverviewScreen()
                    }
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
        .navigationTitle(detailTitle)
    }
}
