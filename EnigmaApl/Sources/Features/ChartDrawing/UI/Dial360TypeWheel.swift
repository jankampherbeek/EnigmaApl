// Dial360TypeWheel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct Dial360TypeWheel: View {
    let chart:        FullChart
    let chartVersion: UUID
    @Binding var blackWhite: Bool
    @Binding var hideTime:   Bool
    @Binding var showExport: Bool

    @StateObject private var model = Dial360TypeWheelModel()

    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    var body: some View {
        ZStack {
            Dial360TypeWheelCanvas(
                plotData: effectiveData,
                theme:    currentTheme
            )
            DialMidpointOverlay(plotData: effectiveData, dialType: .dial360)
        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(
                wheelView: Dial360TypeWheelCanvas(
                    plotData: effectiveData,
                    theme:    currentTheme
                )
            )
        }
        .onAppear   { model.update(from: chart, config: activeConfigs.first) }
        .onChange(of: chartVersion) { model.update(from: chart, config: activeConfigs.first) }
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
            mcLongitude: d.mcLongitude,
            cuspLongitudes: [],
            planetItems: d.planetItems.filter { $0.factor != .ascendant && $0.factor != .mc },
            hasTime: false,
            aspectItems: []
        )
    }
}
