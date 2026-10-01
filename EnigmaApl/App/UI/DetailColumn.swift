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
                return le(RadixInspector.horoscope.rbKey)
            case .newChart:
                return ri("view.radixinputscreen.title")
            case .positions:
                return le(RadixInspector.positions.rbKey)
            case .analysis:
                return le(RadixInspector.horoscope.rbKey)
            case .analysisAspects:
                return le(RadixInspector.analysisAspects.rbKey)
            case .analysisMidpoints:
                return le(RadixInspector.analysisMidpoints.rbKey)
            case .analysisHarmonics:
                return le(RadixInspector.analysisHarmonics.rbKey)
            case .analysisDeclinations:
                return le(RadixInspector.analysisDeclinations.rbKey)
            case .analysisZodiacDivisions:
                return le(RadixInspector.analysisZodiacDivisions.rbKey)
            case .analysisAltZodiacStart:
                return NSLocalizedString(AltZodiacStartKeys.navTitle, tableName: "AltZodiacStart", bundle: .main, comment: "")
            case .analysisEnneagram:
                return le(RadixInspector.analysisEnneagram.rbKey)
            case .analysisVsp:
                return le(RadixInspector.analysisVsp.rbKey)
            case .analysisParans:
                return le(RadixInspector.analysisParans.rbKey)
            case .analysisHarmonicOrbs:
                return NSLocalizedString(HarmonicOrbsKeys.navTitle, tableName: "HarmonicOrbs", bundle: .main, comment: "")
            case .analysisLots:
                return NSLocalizedString(LotsKeys.navTitle, tableName: "Lots", bundle: .main, comment: "")
            case .analysisBlaSchema:
                return NSLocalizedString(BlaSchemaKeys.title, tableName: "BlaSchema", bundle: .main, comment: "")
            case .analysisCountings:
                return NSLocalizedString(CountingsKeys.title, tableName: "Countings", bundle: .main, comment: "")
            case .horoscope:
                return le(RadixInspector.horoscope.rbKey)
            case .search:
                return le(RadixInspector.horoscope.rbKey)
            case .editChart:
                return le(RadixInspector.editChart.rbKey)
            }
        case .progressive:
            return le(app.nav.progressive.section.rbKey)
        case .fixstars:
            return le(AppMode.fixstars.rbKey)
        case .research:
            return ""
        case .cycles:
            return nv(NavigationKeys.detail)
        case .calculators:
            return le(app.nav.calculators.section.rbKey)
        case .config:
            return configNav.selectedConfig?.name ?? le(AppMode.config.rbKey)
        case .synastry:
            return le(AppMode.synastry.rbKey)
        case .importExport:
            return le(app.nav.importExport.section.rbKey)
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
                        case .overview, .horoscope, .analysis, .search:
                            HoroscopeScreen(
                                blackWhite:  Binding(get: { app.ui.blackWhite },  set: { app.ui.blackWhite = $0 }),
                                hideAspects: Binding(get: { app.ui.hideAspects }, set: { app.ui.hideAspects = $0 }),
                                hideTime:    Binding(get: { app.ui.hideTime },    set: { app.ui.hideTime = $0 }),
                                showExport:  Binding(get: { app.ui.showExport },  set: { app.ui.showExport = $0 })
                            )
                        case .newChart:
                            RadixInputScreen()
                        case .positions:
                            PositionsScreen()
                        case .analysisAspects:
                            AspectsScreen()
                        case .analysisMidpoints:
                            MidpointsScreen()
                        case .analysisHarmonics:
                            HarmonicsScreen()
                        case .analysisDeclinations:
                            DeclinationsScreen()
                        case .analysisZodiacDivisions:
                            ZodiacDivisionsResultsView()
                        case .analysisAltZodiacStart:
                            AltZodiacStartResultsView()
                        case .analysisEnneagram:
                            EnneagramResultsScreen()
                        case .analysisVsp:
                            VspScreen()
                        case .analysisParans:
                            ParansResultsScreen()
                        case .analysisHarmonicOrbs:
                            HarmonicOrbsDrawingScreen()
                        case .analysisLots:
                            LotsResultsScreen()
                        case .analysisBlaSchema:
                            BlaSchemaScreen()
                        case .analysisCountings:
                            CountingsScreen()
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
                            TransitResults()
                        case .secondary:
                            SecondaryResults()
                        case .symbolic:
                            SymbolicResults()
                        case .logarithmicTimescale:
                            LogTimeScaleResultsScreen()
                        case .agePoint:
                            AgePointResultsScreen()
                        case .solar:
                            SolarResultsScreen()
                        case .primary:
                            PrimDirResultsScreen()
                        case .prenatal:
                            PreNatalResultsScreen()
                        case .progressiveCalendar:
                            ProgressiveCalendarResultsScreen()
                        default:
                            EmptyView()
                        }
                    case .fixstars:
                        FixStarResultsScreen()
                    case .research:
                        EmptyView()
                    case .cycles:
                        switch app.nav.cycles.section {
                        case .astronomicalCycles:
                            CyclesChartView()
                        case .waves:
                            WavesChartView()
                        case .tablesGraphs:
                            TablesGraphsScreen()
                        case .ephemeris:
                            EphemerisResultsView()
                        case .longTimeEphemeris:
                            LongTimeEphemerisResultsView()
                        case .eclipses:
                            EclipsesResultsScreen()
                        }
                    case .calculators:
                        switch app.nav.calculators.section {
                        case .julianDay:
                            JulianDayView()
                        case .obliquity:
                            ObliquityView()
                        }
                    case .config:
                        EmptyView()
                    case .synastry:
                        if app.nav.synastry.resultType == nil {
                            EmptyView()
                        } else {
                            SynastryResultsDetailScreen()
                        }
                    case .importExport:
                        ImportExportDetailScreen(section: app.nav.importExport.section)
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

private func nv(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Navigation", bundle: .main, comment: "")
}

private func le(_ key: String) -> String {
    NSLocalizedString(key, bundle: .main, comment: "")
}
