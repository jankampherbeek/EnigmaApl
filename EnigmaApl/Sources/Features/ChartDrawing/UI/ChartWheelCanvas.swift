// ChartWheelCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// Draws prepared plot data as a single wheel of the given drawing type.
/// Build the plot data with `ChartWheelPlotDataBuilder` for the same drawing type.
struct ChartWheelCanvas: View {
    let plotData: WheelPlotData
    let drawingType: DrawingType
    let theme: WheelTheme
    let showAspects: Bool

    var body: some View {
        switch drawingType {
        case .signBased:  ZodiacTypeWheelCanvas(plotData: plotData, theme: theme, showAspects: showAspects)
        case .houseBased: HouseTypeWheelCanvas(plotData: plotData, theme: theme, showAspects: showAspects)
        case .french:     FrenchTypeWheelCanvas(plotData: plotData, theme: theme, showAspects: showAspects)
        case .ring:       RingTypeWheelCanvas(plotData: plotData, theme: theme, showAspects: showAspects)
        case .dial360:    Dial360TypeWheelCanvas(plotData: plotData, theme: theme, showAspects: showAspects)
        case .dial90:     Dial90TypeWheelCanvas(plotData: plotData, theme: theme)
        case .dial45:     Dial45TypeWheelCanvas(plotData: plotData, theme: theme)
        }
    }
}
