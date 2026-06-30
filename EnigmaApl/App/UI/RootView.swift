//
//  RootView.swift
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 24/02/2026.
//

// App container, builds a NavigationSplitView with 3 column:
// SidebarView (left navigation), ContentColumn (middle) and DetailColumn (right)

import SwiftUI
import SwiftData
import Combine
import CoreLocation


struct RootView: View {
    @EnvironmentObject private var composition: AppComposition
    @EnvironmentObject private var app: AppState
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private var preferTwoColumns: Bool { hSizeClass == .compact }

    private var usesTwoColumnDetail: Bool {
        app.nav.mode == .research
    }

    var body: some View {
        // Main layout: two-column for Research (no detail pane), three-column for all other modes
        Group {
            if usesTwoColumnDetail {
                NavigationSplitView {
                    SidebarView()
                } detail: {
                    ContentColumn()
                }
            } else {
                NavigationSplitView {
                    SidebarView()
                } content: {
                    ContentColumn()
                } detail: {
                    if preferTwoColumns {
                        TwoColumnDetailPlaceholder()
                    } else {
                        DetailColumn()
                    }
                }
            }
        }
        // Inject the actual singletons so that they can be used by lower views
        .environmentObject(app)
        .environmentObject(composition.chartSession)
        .environmentObject(composition.radixNav)
        .environmentObject(composition.progressiveNav)
        .environmentObject(composition.researchNav)
        .environmentObject(composition.cyclesNav)
        .environmentObject(composition.cyclesModel)
        .environmentObject(composition.wavesModel)
        .environmentObject(composition.progressiveSession)
        .environmentObject(composition.transitModel)
        .environmentObject(composition.secondaryModel)
        .environmentObject(composition.symbolicModel)
        .environmentObject(composition.logTimeScaleModel)
        .environmentObject(composition.agePointModel)
        .environmentObject(composition.zodiacDivisionsModel)
        .environmentObject(composition.enneagramModel)
        .environmentObject(composition.vspModel)
        .environmentObject(composition.solarReturnModel)
        .environmentObject(composition.primDirModel)
        .environmentObject(composition.preNatalModel)
        .environmentObject(composition.ephemerisModel)
        .environmentObject(composition.fixStarModel)
        .environmentObject(composition.calculatorsNav)
        .environmentObject(composition.configNav)
        .onAppear {
            DispatchQueue.main.async {
                app.ensureDefaultSelection()
            }
            if let active = activeConfigs.first {
                GlyphSelector.configure(with: active.glyphsConfig)
                SignColorSelector.configure(with: active.displayConfig)
                FactorDisplaySelector.configure(with: active.factorConfig)
            }
            Task {
                await buildStartupChart(config: activeConfigs.first)
            }
        }
        .onChange(of: activeConfigs.first?.persistentModelID) {
            if let active = activeConfigs.first {
                GlyphSelector.configure(with: active.glyphsConfig)
                SignColorSelector.configure(with: active.displayConfig)
                FactorDisplaySelector.configure(with: active.factorConfig)
                let factors = active.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor }
                composition.chartSession.recalculateAll(factorsToUse: factors, calculationConfig: active.calculationConfig)
            }
        }
        .onChange(of: activeConfigs.first?.factorConfigData) { _, _ in
            if let active = activeConfigs.first {
                FactorDisplaySelector.configure(with: active.factorConfig)
                let factors = active.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor }
                composition.chartSession.recalculateAll(factorsToUse: factors, calculationConfig: active.calculationConfig)
            }
        }
        .onChange(of: activeConfigs.first?.calculationConfigData) { _, _ in
            if let active = activeConfigs.first {
                let factors = active.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor }
                composition.chartSession.recalculateAll(factorsToUse: factors, calculationConfig: active.calculationConfig)
            }
        }
        .onChange(of: activeConfigs.first?.displayConfigData) { _, _ in
            if let active = activeConfigs.first {
                SignColorSelector.configure(with: active.displayConfig)
            }
        }
        // when using compact layouts
        .sheet(isPresented: Binding(
            get: { preferTwoColumns && app.ui.showInspectorSheet },
            set: { app.setInspectorSheet($0) }
        )) {
            NavigationStack {
                DetailColumn()
                    .navigationTitle("Details")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Sluiten") { app.setInspectorSheet(false) }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func buildStartupChart(config: UserConfiguration?) async {
        guard composition.chartSession.charts.isEmpty else { return }

        let coord = await composition.locationService.fetchCurrentLocation()

        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!
        let comps = utcCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())

        let astroDate = AstronomicalDate(
            Year: comps.year ?? 2000,
            Month: comps.month ?? 1,
            Day: comps.day ?? 1,
            Gregorian: true
        )
        let astroTime = AstronomicalTime(
            Hour: comps.hour ?? 0,
            Minute: comps.minute ?? 0,
            Second: comps.second ?? 0
        )

        let calcConfig = config?.calculationConfig ?? CalculationConfig()
        let factors: [Factors]
        if let config {
            factors = config.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor }
        } else {
            factors = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto]
        }

        let seWrapper = SEWrapper()
        let jd = seWrapper.julianDay(date: astroDate, time: astroTime)

        let request = CalcRequest(
            JulianDay: jd,
            FactorsToUse: factors,
            HouseSystem: Int(calcConfig.houseSystem.seId.asciiValue ?? 80),
            Latitude: coord?.latitude ?? 0.0,
            Longitude: coord?.longitude ?? 0.0,
            Height: 0.0,
            calculationConfig: calcConfig
        )

        let chart = AstronCalcOrchestrator.PerformCalculation(request, seWrapper: seWrapper)
        let chartName = NSLocalizedString(StartupChartKeys.chartName, tableName: "StartupChart", bundle: .main, comment: "")
        composition.chartSession.add(name: chartName, chart: chart, baseRequest: request)
        app.nav.radix.inspector = .positions
    }
}
