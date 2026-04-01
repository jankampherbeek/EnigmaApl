// FrenchTypeWheel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct FrenchTypeWheel: View {
    let chart:        FullChart
    let chartVersion: UUID
    @Binding var blackWhite:  Bool
    @Binding var hideAspects: Bool
    @Binding var hideTime:    Bool
    @Binding var showExport:  Bool

    @StateObject private var model = FrenchTypeWheelModel()
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private var activeConfig: UserConfiguration? { activeConfigs.first }

    var body: some View {
        VStack(spacing: 4) {
            FrenchTypeWheelCanvas(
                plotData:    effectiveData,
                theme:       currentTheme,
                showAspects: !hideAspects
            )

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
}
