//
//  ContentColumn.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

import SwiftUI
import SwiftData
import Combine

// The center part of the NavigationSplitView of the app.

struct ContentColumn: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private var preferTwoColumns: Bool { hSizeClass == .compact }
    private var isRadix: Bool { app.nav.mode == .radix }

    @State private var showHelp    = false

    private var drawingType: DrawingType {
        activeConfigs.first?.displayConfig.drawingType ?? .signBased
    }

    private var hasAspects: Bool {
        drawingType == .signBased || drawingType == .french || drawingType == .ring
    }

    private var isDial: Bool {
        drawingType == .dial360 || drawingType == .dial90 || drawingType == .dial45
    }

    private var isZodiacDivisions: Bool {
        app.nav.radix.inspector == .analysisZodiacDivisions
    }

    private var isAltZodiacStart: Bool {
        app.nav.radix.inspector == .analysisAltZodiacStart
    }

    private var isEnneagram: Bool {
        app.nav.radix.inspector == .analysisEnneagram
    }

    private var isVsp: Bool {
        app.nav.radix.inspector == .analysisVsp
    }

    private var isParans: Bool {
        app.nav.radix.inspector == .analysisParans
    }

    private var isHarmonicOrbs: Bool {
        app.nav.radix.inspector == .analysisHarmonicOrbs
    }

    private var isLots: Bool {
        app.nav.radix.inspector == .analysisLots
    }

    var body: some View {
        Group {
            switch app.nav.mode {
            case .radix:
                switch app.nav.radix.inspector {
                case .analysisZodiacDivisions:
                    ZodiacDivisionsInputView()
                case .analysisAltZodiacStart:
                    AltZodiacStartInputView()
                case .analysisEnneagram:
                    EnneagramOptionsView()
                case .analysisVsp:
                    VspDiagramView()
                case .analysisParans:
                    ParansInputView()
                case .analysisHarmonicOrbs:
                    HarmonicOrbsInputScreen()
                case .analysisLots:
                    LotsInputScreen()
                case .overview, .horoscope:
                    RadixOverviewScreen()
                case .analysis:
                    AnalysisScreen()
                case .search:
                    RadixSearchScreen()
                case .positions, .analysisAspects,
                     .analysisMidpoints, .analysisHarmonics, .analysisDeclinations,
                     .analysisBlaSchema, .analysisCountings,
                     .newChart, .editChart:
                    HoroscopeScreen(
                        blackWhite:  Binding(get: { app.ui.blackWhite },  set: { app.ui.blackWhite = $0 }),
                        hideAspects: Binding(get: { app.ui.hideAspects }, set: { app.ui.hideAspects = $0 }),
                        hideTime:    Binding(get: { app.ui.hideTime },    set: { app.ui.hideTime = $0 }),
                        showExport:  Binding(get: { app.ui.showExport },  set: { app.ui.showExport = $0 })
                    )
                }
            case .progressive:
                switch app.nav.progressive.section {
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
                case .primary:
                    PrimDirInputScreen()
                case .prenatal:
                    PreNatalInputScreen()
                case .progressiveCalendar:
                    ProgressiveCalendarInputScreen()
                default:
                    EmptyView()
                }
            case .fixstars:
                FixStarInputScreen()
            case .research:
                ResearchProjectsScreen()
            case .cycles:
                switch app.nav.cycles.section {
                case .astronomicalCycles:
                    AstronomicalCyclesScreen()
                case .waves:
                    WavesScreen()
                case .tablesGraphs:
                    EmptyView()
                case .ephemeris:
                    EphemerisInputScreen()
                case .longTimeEphemeris:
                    LongTimeEphemerisInputScreen()
                case .eclipses:
                    EclipsesInputScreen()
                }
            case .calculators:
                CalculatorsScreen()
            case .config:
                ConfigListScreen()
            case .synastry:
                SynastryInputScreen()
            case .importExport:
                ImportExportScreen()
            }
        }
        .navigationTitle(le(app.nav.mode.rbKey))
        .toolbar {
            if preferTwoColumns {
                ToolbarItem(placement: .automatic) {
                    Button { app.setInspectorSheet(true) } label: {
                        Label(nv(NavigationKeys.details), systemImage: "sidebar.right")
                    }
                }
            }
            if isRadix && !isZodiacDivisions && !isAltZodiacStart && !isEnneagram && !isVsp && !isParans && !isHarmonicOrbs && !isLots {
                ToolbarItem(placement: .automatic) {
                    Button { app.ui.blackWhite.toggle() } label: {
                        Image(systemName: app.ui.blackWhite ? "circle.lefthalf.filled" : "paintpalette")
                    }
                    .accessibilityLabel(nv(app.ui.blackWhite ? NavigationKeys.menuSwitchToColor : NavigationKeys.menuSwitchToBlackWhite))
                }
                if hasAspects {
                    ToolbarItem(placement: .automatic) {
                        Button { app.ui.hideAspects.toggle() } label: {
                            Image(systemName: "angle")
                                .foregroundStyle(app.ui.hideAspects ? .secondary : .primary)
                        }
                        .accessibilityLabel(nv(app.ui.hideAspects ? NavigationKeys.menuShowAspects : NavigationKeys.menuHideAspects))
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button { app.ui.hideTime.toggle() } label: {
                        Image(systemName: "clock")
                            .foregroundStyle(app.ui.hideTime ? .secondary : .primary)
                    }
                    .accessibilityLabel(nv(app.ui.hideTime ? NavigationKeys.menuShowTime : NavigationKeys.menuHideTime))
                }
                if isDial {
                    ToolbarItem(placement: .automatic) {
                        Picker("", selection: dialTypeBinding) {
                            Text(tw(ChartWheelKeys.dialType360)).tag(DrawingType.dial360)
                            Text(tw(ChartWheelKeys.dialType90)).tag(DrawingType.dial90)
                            Text(tw(ChartWheelKeys.dialType45)).tag(DrawingType.dial45)
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button { app.ui.showExport = true } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel(nv(NavigationKeys.export))
                }
            }
            if isRadix && !isZodiacDivisions && !isAltZodiacStart && !isEnneagram && !isVsp && !isParans && !isHarmonicOrbs && !isLots {
                ToolbarItem(placement: .automatic) {
                    Button { showHelp = true } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .accessibilityLabel(nv(NavigationKeys.help))
                }
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: helpText)
        }
    }

    // MARK: - Helpers

    private var helpText: String {
        switch drawingType {
        case .signBased: return tw(ChartWheelKeys.zodiacHelp)
        case .houseBased: return tw(ChartWheelKeys.houseHelp)
        case .french:     return tw(ChartWheelKeys.frenchHelp)
        case .ring:       return tw(ChartWheelKeys.ringHelp)
        case .dial360:    return tw(ChartWheelKeys.dial360Help)
        case .dial90:     return tw(ChartWheelKeys.dial90Help)
        case .dial45:     return tw(ChartWheelKeys.dial45Help)
        }
    }

    private var dialTypeBinding: Binding<DrawingType> {
        Binding(
            get: { activeConfigs.first?.displayConfig.drawingType ?? .dial360 },
            set: { newType in
                guard let config = activeConfigs.first else { return }
                config.displayConfig = DisplayConfig(
                    drawingType: newType,
                    signColors:  config.displayConfig.signColors
                )
            }
        )
    }

    private func tw(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ChartWheel", bundle: .main, comment: "")
    }
}

private func nv(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Navigation", bundle: .main, comment: "")
}

private func le(_ key: String) -> String {
    NSLocalizedString(key, bundle: .main, comment: "")
}
