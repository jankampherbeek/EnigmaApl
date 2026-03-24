// ZodiacTypeWheelCanvas.swift
// EnigmaApl
//
// Pure drawing canvas for the zodiac wheel — no buttons, no model, no SwiftData.
// Used both as the live display inside ZodiacTypeWheel and as the render source
// for WheelExportSheet (via ImageRenderer).

import SwiftUI

struct ZodiacTypeWheelCanvas: View {
    let plotData: WheelPlotData
    let theme: WheelTheme
    let showAspects: Bool

    var body: some View {
        Canvas { ctx, size in
            let outerRadius = Double(min(size.width, size.height)) / 2.0
            let center      = CGPoint(x: size.width / 2, y: size.height / 2)
            let asc         = plotData.ascendantLongitude

            drawCircles(&ctx, center: center, outerRadius: outerRadius, theme: theme)
            drawElementSectors(&ctx, center: center, outerRadius: outerRadius, ascLong: asc, theme: theme)
            drawSignSeparators(&ctx, center: center, outerRadius: outerRadius, ascLong: asc, theme: theme)
            drawSignGlyphs(&ctx, center: center, outerRadius: outerRadius, ascLong: asc, theme: theme)
            drawDegreeLines(&ctx, center: center, outerRadius: outerRadius, ascLong: asc, theme: theme)
            if plotData.hasTime {
                drawCuspLines(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
                drawCardinalLines(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
                drawCardinalLabels(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
                drawCuspTexts(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            }
            if showAspects {
                drawAspectLines(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            }
            drawPlanetConnectLines(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            drawPlanetGlyphs(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            drawPlanetTexts(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
