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

    @State private var showExport  = false
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

    var body: some View {
        Group {
            switch app.nav.mode {
            case .radix:
                switch app.nav.radix.inspector {
                case .overview, .horoscope, .positions, .analysis, .analysisAspects,
                     .analysisMidpoints, .analysisHarmonics, .analysisDeclinations, .newChart, .search, .editChart:
                    HoroscopeScreen(
                        blackWhite:  Binding(get: { app.ui.blackWhite },  set: { app.ui.blackWhite = $0 }),
                        hideAspects: Binding(get: { app.ui.hideAspects }, set: { app.ui.hideAspects = $0 }),
                        hideTime:    Binding(get: { app.ui.hideTime },    set: { app.ui.hideTime = $0 }),
                        showExport:  $showExport
                    )
                }
            case .progressive:
                switch app.nav.progressive.section {
                case .transit:
                    TransitResults()
                case .secondary:
                    SecondaryResults()
                case .symbolic:
                    SymbolicResults()
                default:
                    EmptyView()
                }
            case .research:
                ResearchProjectsScreen()
            case .cycles:
                switch app.nav.cycles.section {
                case .astronomicalCycles:
                    CyclesChartView()
                case .waves:
                    WavesChartView()
                case .tablesGraphs:
                    EmptyView()
                }
            case .config:
                ConfigListScreen()
            }
        }
        .navigationTitle(app.nav.mode.rawValue)
        .toolbar {
            if preferTwoColumns {
                ToolbarItem(placement: .automatic) {
                    Button { app.setInspectorSheet(true) } label: {
                        Label("Details", systemImage: "sidebar.right")
                    }
                }
            }
            if isRadix {
                ToolbarItem(placement: .automatic) {
                    Button { app.ui.blackWhite.toggle() } label: {
                        Image(systemName: app.ui.blackWhite ? "circle.lefthalf.filled" : "paintpalette")
                    }
                    .accessibilityLabel(app.ui.blackWhite ? "Switch to color" : "Switch to black and white")
                }
                if hasAspects {
                    ToolbarItem(placement: .automatic) {
                        Button { app.ui.hideAspects.toggle() } label: {
                            Image(systemName: "angle")
                                .foregroundStyle(app.ui.hideAspects ? .secondary : .primary)
                        }
                        .accessibilityLabel(app.ui.hideAspects ? "Show aspects" : "Hide aspects")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button { app.ui.hideTime.toggle() } label: {
                        Image(systemName: "clock")
                            .foregroundStyle(app.ui.hideTime ? .secondary : .primary)
                    }
                    .accessibilityLabel(app.ui.hideTime ? "Show time" : "Hide time")
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
                    Button { showExport = true } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Export")
                }
                ToolbarItem(placement: .automatic) {
                    Button { showHelp = true } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .accessibilityLabel("Help")
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
