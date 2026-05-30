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
        }
        .onChange(of: activeConfigs.first?.persistentModelID) {
            if let active = activeConfigs.first {
                GlyphSelector.configure(with: active.glyphsConfig)
                SignColorSelector.configure(with: active.displayConfig)
                FactorDisplaySelector.configure(with: active.factorConfig)
                let factors = active.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor }
                composition.chartSession.recalculateAll(factorsToUse: factors)
            }
        }
        .onChange(of: activeConfigs.first?.factorConfigData) { _, _ in
            if let active = activeConfigs.first {
                FactorDisplaySelector.configure(with: active.factorConfig)
                let factors = active.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor }
                composition.chartSession.recalculateAll(factorsToUse: factors)
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
}
