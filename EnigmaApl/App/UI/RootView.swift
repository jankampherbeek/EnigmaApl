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
        .environmentObject(composition.altZodiacStartModel)
        .environmentObject(composition.enneagramModel)
        .environmentObject(composition.vspModel)
        .environmentObject(composition.solarReturnModel)
        .environmentObject(composition.primDirModel)
        .environmentObject(composition.preNatalModel)
        .environmentObject(composition.progressiveCalendarModel)
        .environmentObject(composition.eclipsesModel)
        .environmentObject(composition.ephemerisModel)
        .environmentObject(composition.longTimeEphemerisModel)
        .environmentObject(composition.fixStarModel)
        .environmentObject(composition.paranModel)
        .environmentObject(composition.harmonicOrbsModel)
        .environmentObject(composition.lotsModel)
        .environmentObject(composition.calculatorsNav)
        .environmentObject(composition.synastryNav)
        .environmentObject(composition.synastryModel)
        .environmentObject(composition.configNav)
        .environmentObject(composition.unsavedChanges)
        .unsavedChangesAlert(composition.unsavedChanges)
        .environmentObject(composition.importExportNav)
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
                    .navigationTitle(nv(NavigationKeys.details))
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(nv(NavigationKeys.close)) { app.setInspectorSheet(false) }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: Binding(
            get: { app.ui.showGlyphOverview },
            set: { app.ui.showGlyphOverview = $0 }
        )) {
            GlyphOverviewScreen()
        }
    }

    private func buildStartupChart(config: UserConfiguration?) async {
        guard !AppEnvironment.skipsStartupChart else { return }
        if await composition.startupChartModel.addIfNeeded(to: composition.chartSession, config: config) {
            app.nav.radix.inspector = .positions
        }
    }
}

private func nv(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Navigation", bundle: .main, comment: "")
}

