// HarmonicDrawingView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct HarmonicDrawingView: View {
    let harmonicNumber: Double
    @Binding var harmonicText: String

    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var blackWhite = false
    @State private var showExport = false

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "RadixAnalysis", bundle: .main, comment: "")
    }

    private func tw(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ChartWheel", bundle: .main, comment: "")
    }

    // MARK: - Derived data

    private var harmonicPositions: [HarmonicPosition] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return HarmonicsOrchestrator.harmonicPositions(
            chart: chart,
            factorConfig: config.factorConfig,
            harmonic: harmonicNumber
        )
    }

    private var plotData: WheelPlotData {
        HarmonicWheelPlotDataBuilder.build(harmonicPositions: harmonicPositions)
    }

    private var currentTheme: WheelTheme {
        blackWhite ? .blackWhite : .color
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(RadixAnalysisKeys.drawingTitle))
                    .font(.title2.weight(.semibold))

                harmonicInput

                HarmonicWheelCanvas(plotData: plotData, theme: currentTheme)
                    .frame(maxWidth: 600)

                HStack(spacing: 8) {
                    Button(tw(blackWhite ? ChartWheelKeys.colorButton : ChartWheelKeys.blackWhiteButton)) {
                        blackWhite.toggle()
                    }
                    Button(tw(ChartWheelKeys.exportButton)) {
                        showExport = true
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(
                wheelView: HarmonicWheelCanvas(plotData: plotData, theme: currentTheme)
            )
        }
    }

    // MARK: - Input field

    @ViewBuilder
    private var harmonicInput: some View {
        HStack(spacing: 8) {
            Text(t(RadixAnalysisKeys.inputLabel))
                .font(.callout)
            TextField("", text: $harmonicText)
                .textFieldStyle(.roundedBorder)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .frame(width: 80)
        }
    }
}
