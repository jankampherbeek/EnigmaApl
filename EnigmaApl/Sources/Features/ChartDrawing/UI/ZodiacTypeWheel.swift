// ZodiacTypeWheel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct ZodiacTypeWheel: View {
    let chart: FullChart
    let chartVersion: UUID

    @StateObject private var viewModel = ZodiacTypeWheelModel()
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
            ZodiacTypeWheelCanvas(
                plotData:    currentPlotData,
                theme:       currentTheme,
                showAspects: !hideAspects
            )

            HStack(spacing: 8) {
                Button(t(blackWhite  ? ChartWheelKeys.colorButton       : ChartWheelKeys.blackWhiteButton))  { blackWhite.toggle() }
                Button(t(hideAspects ? ChartWheelKeys.showAspectsButton : ChartWheelKeys.noAspectsButton))   { hideAspects.toggle() }
                Button(t(hideTime    ? ChartWheelKeys.withTimeButton    : ChartWheelKeys.noTimeButton))      { hideTime.toggle() }
                Button(t(ChartWheelKeys.exportButton))                                                       { showExport = true }
                Button(t(ChartWheelKeys.helpButton))                                                         { showHelp   = true }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .padding(.vertical, 8)
        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(
                wheelView: ZodiacTypeWheelCanvas(
                    plotData:    currentPlotData,
                    theme:       currentTheme,
                    showAspects: !hideAspects
                )
            )
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(ChartWheelKeys.zodiacHelp))
        }
        .onAppear { viewModel.update(from: chart, config: activeConfig) }
        .onChange(of: chartVersion) { viewModel.update(from: chart, config: activeConfig) }
    }

    // MARK: - Convenience

    private var currentTheme: WheelTheme {
        blackWhite ? .blackWhite : .color
    }

    private var currentPlotData: WheelPlotData {
        effectiveData(from: viewModel.plotData)
    }

    // MARK: - i18n

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ChartWheel", bundle: .main, comment: "")
    }

    // MARK: - Effective data

    /// When hideTime is active: resets ascendantLongitude to 0 so that 0° Aries sits at
    /// 9 o'clock, remaps all planet and aspect angles accordingly, and sets hasTime = false.
    private func effectiveData(from data: WheelPlotData) -> WheelPlotData {
        guard hideTime else { return data }
        let ascLong = data.ascendantLongitude

        var remappedPlanets = data.planetItems.map { item -> WheelPlotItem in
            let angle = WheelGeometry.mundaneAngle(longitude: item.eclipticLongitude,
                                                   ascendantLongitude: 0)
            return WheelPlotItem(factor: item.factor, glyph: item.glyph,
                                 eclipticLongitude: item.eclipticLongitude,
                                 mundaneAngle: angle, plotAngle: angle,
                                 positionText: item.positionText)
        }
        remappedPlanets = GlyphOverlapResolver.resolve(remappedPlanets)

        let remappedAspects = data.aspectItems.map { item in
            WheelAspectItem(
                angle1:    WheelGeometry.normalise(item.angle1 + ascLong),
                angle2:    WheelGeometry.normalise(item.angle2 + ascLong),
                color:     item.color,
                exactness: item.exactness,
                aspect:    item.aspect
            )
        }

        return WheelPlotData(
            ascendantLongitude: 0,
            mcLongitude:        data.mcLongitude,
            cuspLongitudes:     data.cuspLongitudes,
            planetItems:        remappedPlanets,
            hasTime:            false,
            aspectItems:        remappedAspects
        )
    }
}
