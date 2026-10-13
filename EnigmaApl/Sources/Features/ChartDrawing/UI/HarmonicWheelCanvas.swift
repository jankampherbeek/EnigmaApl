// HarmonicWheelCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// A chart wheel canvas tailored for harmonic drawings:
/// - The harmonic ASC is placed at the left, as in the other charts; without a harmonic ASC
///   (not configured, or hidden), 0° Aries is placed at the left.
/// - Equal house cusps (each a multiple of 30° from the harmonic ASC) with their position texts.
/// - ASC and MC indicator lines and labels are drawn at their harmonic ecliptic longitudes,
///   extracted from the plot data's planet items; the MC can fall anywhere.
/// - Aspect lines between the harmonic positions, if showAspects is true.
struct HarmonicWheelCanvas: View {
    let plotData: WheelPlotData
    let theme: WheelTheme
    var showAspects = true

    var body: some View {
        Canvas { ctx, size in
            let outerRadius = Double(min(size.width, size.height)) / 2.0
            let center      = CGPoint(x: size.width / 2, y: size.height / 2)

            // Harmonic ASC at the left, or 0° Aries if there is no harmonic ASC.
            let zodiacAsc = plotData.ascendantLongitude

            // Harmonic longitudes of ASC and MC (nil if not in config / not calculated).
            let harmonicAscLong = plotData.planetItems
                .first(where: { $0.factor == .ascendant })?.eclipticLongitude
            let harmonicMcLong  = plotData.planetItems
                .first(where: { $0.factor == .mc })?.eclipticLongitude

            drawCircles(&ctx, center: center, outerRadius: outerRadius, theme: theme)
            drawElementSectors(&ctx, center: center, outerRadius: outerRadius, ascLong: zodiacAsc, theme: theme)
            drawSignSeparators(&ctx, center: center, outerRadius: outerRadius, ascLong: zodiacAsc, theme: theme)
            drawSignGlyphs(&ctx, center: center, outerRadius: outerRadius, ascLong: zodiacAsc, theme: theme)
            drawDegreeLines(&ctx, center: center, outerRadius: outerRadius, ascLong: zodiacAsc, theme: theme)
            if plotData.hasTime {
                drawCuspLines(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
                drawCuspTexts(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            }
            drawAscMcLines(&ctx, center: center, outerRadius: outerRadius,
                           ascLongitude: harmonicAscLong, mcLongitude: harmonicMcLong,
                           wheelAscLongitude: zodiacAsc, theme: theme)
            drawAscMcLabels(&ctx, center: center, outerRadius: outerRadius,
                            ascLongitude: harmonicAscLong, mcLongitude: harmonicMcLong,
                            wheelAscLongitude: zodiacAsc, theme: theme)
            if showAspects {
                drawAspectLines(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            }
            drawPlanetConnectLines(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            drawPlanetGlyphs(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            drawPlanetTexts(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}
