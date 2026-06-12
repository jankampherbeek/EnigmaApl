//
//  DetailColumn.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import SwiftData
import Combine

// The detail screen in the right part of the NavigationSplitView of the app.

// MARK: - Minimal placeholder views (keep your existing implementations)


struct DetailColumn: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var radixNav: RadixNavigator
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var configNav: ConfigNavigator

    /// Controlled path for the config NavigationStack.
    /// Reset to empty whenever a different config is selected,
    /// so any open section editor is dismissed automatically.
    @State private var configNavPath = NavigationPath()

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
                return "Analyse"
            case .analysisAspects:
                return "Aspecten"
            case .analysisMidpoints:
                return "Midpunten"
            case .analysisHarmonics:
                return "Harmonischen"
            case .analysisDeclinations:
                return "Declinaties"
            case .analysisZodiacDivisions:
                return "Zodiacal Divisions"
            case .analysisEnneagram:
                return "Enneagram"
            case .analysisVsp:
                return "Venus Star Point"
            case .horoscope:
                return "Overzicht"
            case .search:
                return "Zoek horoscoop"
            case .editChart:
                return "Wijzig horoscoop"
            }
        case .progressive:
            return app.nav.progressive.section.rawValue
        case .research:
            return ""
        case .cycles:
            return "Detail"
        case .calculators:
            return app.nav.calculators.section.rawValue
        case .config:
            return configNav.selectedConfig?.name ?? "Configuratie"
        }
    }

    var body: some View {
        // Config gets its own NavigationStack so section editors can push/pop correctly.
        // All other modes use the split view's built-in navigation title.
        Group {
            if app.nav.mode == .config {
                NavigationStack(path: $configNavPath) {
                    if let config = configNav.selectedConfig {
                        ConfigEditScreen(config: config)
                            .id(config.persistentModelID)  // fresh view + state on config switch
                    } else {
                        ConfigEmptyState()
                    }
                }
            } else {
                Group {
                    switch app.nav.mode {
                    case .radix:
                        switch app.nav.radix.inspector {
                        case .overview:
                            RadixOverviewScreen()
                        case .horoscope:
                            RadixOverviewScreen()
                        case .newChart:
                            RadixInputScreen()
                        case .positions:
                            PositionsScreen()
                        case .analysis:
                            AnalysisScreen()
                        case .analysisAspects:
                            AspectsScreen()
                        case .analysisMidpoints:
                            MidpointsScreen()
                        case .analysisHarmonics:
                            HarmonicsScreen()
                        case .analysisDeclinations:
                            DeclinationsScreen()
                        case .analysisZodiacDivisions:
                            ZodiacDivisionsInputView()
                        case .analysisEnneagram:
                            EnneagramOptionsView()
                        case .analysisVsp:
                            VspScreen()
                        case .search:
                            RadixSearchScreen()
                        case .editChart:
                            if let horoscope = chartSession.editingHoroscope {
                                RadixEditScreen(horoscope: horoscope)
                            } else {
                                RadixOverviewScreen()
                            }
                        }
                    case .progressive:
                        switch app.nav.progressive.section {
                        case .events:
                            EventsOverviewScreen()
                        case .transit:
                            TransitScreen()
                        case .secondary:
                            SecondaryScreen()
                        case .symbolic:
                            SymbolicScreen()
                        case .logarithmicTimescale:
                            LogTimeScaleInputScreen()
                        case .agePoint:
                            AgePointInputScreen()
                        case .solar:
                            SolarInputScreen()
                        default:
                            EmptyView()
                        }
                    case .research:
                        EmptyView()
                    case .cycles:
                        switch app.nav.cycles.section {
                        case .astronomicalCycles:
                            AstronomicalCyclesScreen()
                        case .waves:
                            WavesScreen()
                        case .tablesGraphs:
                            TablesGraphsScreen()
                        }
                    case .calculators:
                        switch app.nav.calculators.section {
                        case .julianDay:
                            JulianDayView()
                        case .obliquity:
                            ObliquityView()
                        case .siderealTime:
                            EmptyView()
                        }
                    case .config:
                        EmptyView()
                    }
                }
                .navigationTitle(detailTitle)
            }
        }
        .onChange(of: configNav.selectedConfig) {
            configNavPath = NavigationPath()  // pop back to ConfigEditScreen on selection change
        }
        .onChange(of: app.nav.mode) {
            if app.nav.mode != .config {
                configNavPath = NavigationPath()  // clear pushed editors when leaving Config
            }
        }
    }
}
