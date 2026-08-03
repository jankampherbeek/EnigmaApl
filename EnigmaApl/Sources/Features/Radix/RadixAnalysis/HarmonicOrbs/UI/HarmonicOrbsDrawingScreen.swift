// HarmonicOrbsDrawingScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

/// Shown in the detail column when .analysisHarmonicOrbs is active.
/// Draws the active chart in the usual way, but with aspects computed from the maximum orb and
/// aspect selection of HarmonicOrbsInputScreen instead of the active configuration's aspect/orb
/// settings. Only the selected factors from the active configuration are used, as usual.
struct HarmonicOrbsDrawingScreen: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var harmonicOrbsModel: HarmonicOrbsModel
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @StateObject private var wheelModel = ZodiacTypeWheelModel()
    @State private var showExport = false
    @State private var showHelp = false

    private var activeConfig: UserConfiguration? { activeConfigs.first }
    private var currentTheme: WheelTheme { app.ui.blackWhite ? .blackWhite : .color }

    /// The base plot data, with its aspect items replaced by the harmonic-orb aspects.
    private var plotData: WheelPlotData {
        let base = wheelModel.plotData
        guard let chart = chartSession.selectedChart, let config = activeConfig else {
            return WheelPlotData(
                ascendantLongitude: base.ascendantLongitude,
                mcLongitude: base.mcLongitude,
                cuspLongitudes: base.cuspLongitudes,
                planetItems: base.planetItems,
                hasTime: base.hasTime,
                aspectItems: []
            )
        }

        let found = HarmonicOrbsOrchestrator.calculate(
            chart: chart,
            factorConfig: config.factorConfig,
            settings: harmonicOrbsModel.settings,
            maxOrbDegrees: harmonicOrbsModel.maxOrbDegrees
        )

        let angleMap: [Factors: Double] = Dictionary(
            uniqueKeysWithValues: base.planetItems.map { ($0.factor, $0.mundaneAngle) }
        )
        let colorMap: [Aspects: Color] = Dictionary(
            uniqueKeysWithValues: config.aspectConfig.aspectSettings.map { ($0.aspect, Color($0.color)) }
        )
        let aspectItems: [WheelAspectItem] = found.compactMap { f in
            guard let angle1 = angleMap[f.factor1], let angle2 = angleMap[f.factor2] else { return nil }
            let exactness = f.maxOrb > 0 ? max(0, 1.0 - f.orb / f.maxOrb) : 1.0
            return WheelAspectItem(
                angle1: angle1, angle2: angle2,
                color: colorMap[f.aspect] ?? .gray,
                exactness: exactness,
                aspect: f.aspect
            )
        }

        return WheelPlotData(
            ascendantLongitude: base.ascendantLongitude,
            mcLongitude: base.mcLongitude,
            cuspLongitudes: base.cuspLongitudes,
            planetItems: base.planetItems,
            hasTime: base.hasTime,
            aspectItems: aspectItems
        )
    }

    var body: some View {
        Group {
            if chartSession.selectedChart == nil {
                ContentUnavailableView(
                    t(HarmonicOrbsKeys.navTitle),
                    systemImage: "circle.dashed",
                    description: Text(t(HarmonicOrbsKeys.drawingNoChart))
                )
            } else {
                ZodiacTypeWheelCanvas(plotData: plotData, theme: currentTheme, showAspects: true)
                    .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { app.ui.blackWhite.toggle() } label: {
                    Image(systemName: app.ui.blackWhite ? "circle.lefthalf.filled" : "paintpalette")
                }
                .accessibilityLabel(app.ui.blackWhite ? "Switch to color" : "Switch to black and white")
            }
            ToolbarItem(placement: .automatic) {
                Button { showExport = true } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Export")
                .disabled(chartSession.selectedChart == nil)
            }
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(
                wheelView: ZodiacTypeWheelCanvas(plotData: plotData, theme: currentTheme, showAspects: true)
            )
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(HarmonicOrbsKeys.helpDrawing))
        }
        .onAppear { refresh() }
        .onChange(of: chartSession.selected?.version) { refresh() }
    }

    // MARK: - Helpers

    private func refresh() {
        guard let chart = chartSession.selectedChart else { return }
        wheelModel.update(from: chart, config: activeConfig)
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "HarmonicOrbs", bundle: .main, comment: "")
    }
}
