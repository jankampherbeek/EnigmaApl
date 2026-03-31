// HarmonicWheelCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// A chart wheel canvas tailored for harmonic drawings:
/// - 0° Aries is fixed at the left (the zodiac ring always rotates with ascendantLongitude = 0).
/// - ASC and MC indicator lines and labels are drawn at their harmonic ecliptic longitudes,
///   extracted from the plot data's planet items.
/// - No house cusp lines, no cusp position texts.
/// - No aspect lines.
struct HarmonicWheelCanvas: View {
    let plotData: WheelPlotData
    let theme: WheelTheme

    var body: some View {
        Canvas { ctx, size in
            let outerRadius = Double(min(size.width, size.height)) / 2.0
            let center      = CGPoint(x: size.width / 2, y: size.height / 2)

            // Zodiac ring is always anchored at 0° Aries on the left.
            let zodiacAsc: Double = 0

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
            drawAscMcLines(&ctx, center: center, outerRadius: outerRadius,
                           ascLongitude: harmonicAscLong, mcLongitude: harmonicMcLong, theme: theme)
            drawAscMcLabels(&ctx, center: center, outerRadius: outerRadius,
                            ascLongitude: harmonicAscLong, mcLongitude: harmonicMcLong, theme: theme)
            drawPlanetConnectLines(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            drawPlanetGlyphs(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            drawPlanetTexts(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}
