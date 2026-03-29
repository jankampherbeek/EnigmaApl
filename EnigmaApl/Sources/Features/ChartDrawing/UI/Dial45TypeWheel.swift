// Dial45TypeWheel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct Dial45TypeWheel: View {
    let chart:        FullChart
    let chartVersion: UUID

    @StateObject private var model = Dial45TypeWheelModel()

    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var blackWhite = false
    @State private var hideTime   = false
    @State private var showExport = false
    @State private var showHelp   = false

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Dial45TypeWheelCanvas(plotData: effectiveData, theme: currentTheme)
                DialMidpointOverlay(plotData: effectiveData, dialType: .dial45)
            }

            HStack(spacing: 8) {
                Picker("", selection: dialTypeBinding) {
                    Text(t(ChartWheelKeys.dialType360)).tag(DrawingType.dial360)
                    Text(t(ChartWheelKeys.dialType90)).tag(DrawingType.dial90)
                    Text(t(ChartWheelKeys.dialType45)).tag(DrawingType.dial45)
                }
                .pickerStyle(.segmented)
                .fixedSize()

                Button(t(blackWhite ? ChartWheelKeys.colorButton : ChartWheelKeys.blackWhiteButton)) { blackWhite.toggle() }
                Button(t(hideTime ? ChartWheelKeys.withTimeButton : ChartWheelKeys.noTimeButton)) { hideTime.toggle() }
                Button(t(ChartWheelKeys.exportButton)) { showExport = true }
                Button(t(ChartWheelKeys.helpButton))   { showHelp   = true }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .padding(.vertical, 8)
        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(wheelView: Dial45TypeWheelCanvas(plotData: effectiveData, theme: currentTheme))
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(ChartWheelKeys.dial45Help))
        }
        .onAppear   { model.update(from: chart, config: activeConfigs.first) }
        .onChange(of: chartVersion) { model.update(from: chart, config: activeConfigs.first) }
    }

    // MARK: - Convenience

    private var currentTheme: WheelTheme { blackWhite ? .blackWhite : .color }

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

    // MARK: - Dial type picker

    private var dialTypeBinding: Binding<DrawingType> {
        Binding(
            get: { activeConfigs.first?.displayConfig.drawingType ?? .dial45 },
            set: { newType in
                guard let config = activeConfigs.first else { return }
                config.displayConfig = DisplayConfig(
                    drawingType: newType,
                    signColors:  config.displayConfig.signColors
                )
            }
        )
    }

    // MARK: - i18n

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ChartWheel", bundle: .main, comment: "")
    }
}
