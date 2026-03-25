// FrenchTypeWheel.swift
// EnigmaApl

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
    @State private var showExport  = false

    var body: some View {
        VStack(spacing: 4) {
            FrenchTypeWheelCanvas(
                plotData:    model.plotData,
                theme:       currentTheme,
                showAspects: !hideAspects
            )

            HStack(spacing: 8) {
                Button(t(blackWhite  ? ChartWheelKeys.colorButton       : ChartWheelKeys.blackWhiteButton))  { blackWhite.toggle() }
                Button(t(hideAspects ? ChartWheelKeys.showAspectsButton : ChartWheelKeys.noAspectsButton))   { hideAspects.toggle() }
                Button(t(ChartWheelKeys.exportButton))                                                        { showExport = true }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .padding(.bottom, 4)
        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(
                wheelView: FrenchTypeWheelCanvas(
                    plotData:    model.plotData,
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

    // MARK: - i18n

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ChartWheel", bundle: .main, comment: "")
    }
}
