// VspDiagramView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

/// Shown in the center column when .analysisVsp is active.
/// Renders a full horoscope chart wheel (no aspects) with the five VSP positions
/// drawn at the inner VSP ring, connected by pentagram lines.
/// The wheel is rotated so that the Head point (seq 3) sits at the Ascendant position.
struct VspDiagramView: View {
    @EnvironmentObject private var app:          AppState
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var vspModel:     VspModel

    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @StateObject private var wheelModel = ZodiacTypeWheelModel()
    @State private var showExport = false
    @State private var showHelp   = false

    private var activeConfig: UserConfiguration? { activeConfigs.first }
    private var currentTheme: WheelTheme { app.ui.blackWhite ? .blackWhite : .color }

    // MARK: - Computed chart data

    /// The ecliptic longitude of the Head (seq 3) — used as the rotation anchor.
    private var vspAnchor: Double {
        guard vspModel.positions.count >= 3 else { return wheelModel.plotData.ascendantLongitude }
        // +90° shifts point 3 from the ASC position (9 o'clock) to the top (12 o'clock)
        let raw = vspModel.positions[2].longitude + 90.0
        return raw >= 360.0 ? raw - 360.0 : raw
    }

    /// Chart wheel data remapped so the Head point sits at the top of the wheel.
    private var chartPlotData: WheelPlotData {
        remapped(wheelModel.plotData, toAnchor: vspAnchor)
    }

    /// VSP positions projected onto the rotated wheel.
    private var vspWheelItems: [VspWheelItem] {
        vspModel.positions.map { pos in
            let angle = WheelGeometry.mundaneAngle(longitude: pos.longitude,
                                                    ascendantLongitude: vspAnchor)
            return VspWheelItem(
                sequenceId:   pos.sequenceId,
                mundaneAngle: angle,
                dmsText:      positionDms(pos.longitude)
            )
        }
    }

    // MARK: - Body

    var body: some View {
        Group {
            if chartSession.selectedChart == nil {
                ContentUnavailableView(
                    t(VspKeys.title),
                    systemImage: "star.circle",
                    description: Text(t(VspKeys.noChart))
                )
            } else {
                VspWheelCanvas(
                    plotData:             chartPlotData,
                    vspItems:             vspWheelItems,
                    theme:                currentTheme,
                    originalAscLongitude: wheelModel.plotData.ascendantLongitude
                )
                .aspectRatio(1, contentMode: .fit)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { app.ui.blackWhite.toggle() } label: {
                    Image(systemName: app.ui.blackWhite ? "circle.lefthalf.filled" : "paintpalette")
                }
                .accessibilityLabel(app.ui.blackWhite ? "Switch to color" : "Switch to black and white")
                .disabled(chartSession.selectedChart == nil)
            }
            ToolbarItem(placement: .automatic) {
                Button { showExport = true } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Export")
                .disabled(vspModel.positions.isEmpty)
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
                wheelView: VspWheelCanvas(
                    plotData:             chartPlotData,
                    vspItems:             vspWheelItems,
                    theme:                currentTheme,
                    originalAscLongitude: wheelModel.plotData.ascendantLongitude
                )
            )
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(VspKeys.help))
        }
        .onAppear { refresh() }
        .onChange(of: chartSession.selectedChart?.JulianDay) { refresh() }
    }

    // MARK: - Helpers

    private func refresh() {
        let chart = chartSession.selectedChart
        if let chart { wheelModel.update(from: chart, config: activeConfig) }
        vspModel.refresh(chart: chart)
    }

    /// Remaps all planet mundane angles to a new anchor longitude and strips aspects.
    private func remapped(_ data: WheelPlotData, toAnchor anchor: Double) -> WheelPlotData {
        var planets = data.planetItems.map { item -> WheelPlotItem in
            let angle = WheelGeometry.mundaneAngle(longitude: item.eclipticLongitude,
                                                    ascendantLongitude: anchor)
            return WheelPlotItem(
                factor: item.factor,
                glyph: item.glyph,
                eclipticLongitude: item.eclipticLongitude,
                mundaneAngle: angle,
                plotAngle: angle,
                positionText: item.positionText,
                speedType: item.speedType
            )
        }
        planets = GlyphOverlapResolver.resolve(planets)
        return WheelPlotData(
            ascendantLongitude: anchor,
            mcLongitude:        data.mcLongitude,
            cuspLongitudes:     data.cuspLongitudes,
            planetItems:        planets,
            hasTime:            data.hasTime,
            aspectItems:        []
        )
    }

    /// Degrees and minutes within the current sign: "15°23'".
    private func positionDms(_ longitude: Double) -> String {
        let inSign   = longitude.truncatingRemainder(dividingBy: 30.0)
        let totalMin = Int(abs(inSign) * 60)
        let deg      = totalMin / 60
        let min      = totalMin % 60
        return "\(deg)°\(String(format: "%02d", min))'"
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Vsp", bundle: .main, comment: "")
    }
}
