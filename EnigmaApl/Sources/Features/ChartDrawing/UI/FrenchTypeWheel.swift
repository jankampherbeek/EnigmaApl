// FrenchTypeWheel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct FrenchTypeWheel: View {
    let chart:        FullChart
    let chartVersion: UUID

    @StateObject private var model = FrenchTypeWheelModel()
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private var activeConfig: UserConfiguration? { activeConfigs.first }

    @State private var blackWhite  = false
    @State private var hideAspects = false
    @State private var hideTime    = false
    @State private var showExport  = false
    @State private var showHelp    = false

    var body: some View {
        VStack(spacing: 4) {
            FrenchTypeWheelCanvas(
                plotData:    effectiveData,
                theme:       currentTheme,
                showAspects: !hideAspects
            )

            HStack(spacing: 8) {
                Button(t(blackWhite  ? ChartWheelKeys.colorButton       : ChartWheelKeys.blackWhiteButton))  { blackWhite.toggle() }
                Button(t(hideAspects ? ChartWheelKeys.showAspectsButton : ChartWheelKeys.noAspectsButton))   { hideAspects.toggle() }
                Button(t(hideTime    ? ChartWheelKeys.withTimeButton    : ChartWheelKeys.noTimeButton))       { hideTime.toggle() }
                Button(t(ChartWheelKeys.exportButton))                                                        { showExport = true }
                Button(t(ChartWheelKeys.helpButton))                                                          { showHelp   = true }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .padding(.vertical, 8)
        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(
                wheelView: FrenchTypeWheelCanvas(
                    plotData:    effectiveData,
                    theme:       currentTheme,
                    showAspects: !hideAspects
                )
            )
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(ChartWheelKeys.frenchHelp))
        }
        .onAppear  { model.update(from: chart, config: activeConfig) }
        .onChange(of: chartVersion) { model.update(from: chart, config: activeConfig) }
    }

    // MARK: - Convenience

    private var currentTheme: WheelTheme {
        blackWhite ? .blackWhite : .color
    }

    private var effectiveData: WheelPlotData {
        guard hideTime else { return model.plotData }
        let d = model.plotData
        return WheelPlotData(
            ascendantLongitude: d.ascendantLongitude,
            mcLongitude:        d.mcLongitude,
            cuspLongitudes:     [],
            planetItems:        d.planetItems,
            hasTime:            false,
            aspectItems:        d.aspectItems
        )
    }

    // MARK: - i18n

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ChartWheel", bundle: .main, comment: "")
    }
}
