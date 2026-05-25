// DualWheelCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// Draws a zodiac-type wheel for the radix chart with an outer transit ring.
/// The radix wheel is scaled to ~78% of the available radius. Transit glyphs
/// sit just outside the zodiac sign ring; connect lines reach down to its outer
/// boundary. The background extends slightly beyond the radix outer circle (which
/// is overlapped by the transit ring) — no separate transit border circles are drawn.
struct DualWheelCanvas: View {
    let radixData: WheelPlotData
    let transitItems: [WheelPlotItem]
    let theme: WheelTheme
    let showAspects: Bool

    private let radixScale: Double = 0.78

    // Transit ring fractions of full outerRadius
    private let transitBackgroundFraction: Double = 0.864 // outer edge of yellow fill (~1 char wider than before)
    private let transitGlyphFraction:      Double = 0.76  // just above the zodiac sign ring
    private let transitTextFraction:       Double = 0.786 // ~1 char closer to glyph
    private let transitConnectStart:       Double = 0.73  // connect line start (just inside glyph, like radix pattern)

    var body: some View {
        Canvas { ctx, size in
            let fullRadius  = Double(min(size.width, size.height)) / 2.0
            let innerRadius = fullRadius * radixScale
            let center      = CGPoint(x: size.width / 2, y: size.height / 2)
            let asc         = radixData.ascendantLongitude

            // Background fill extends to transitBackgroundFraction; radix wheel
            // draws on top, leaving only the transit ring annulus in this colour.
            drawTransitBackground(&ctx, center: center, fullRadius: fullRadius,
                                   outerFraction: transitBackgroundFraction, theme: theme)

            // Radix wheel (scaled)
            drawCircles(&ctx, center: center, outerRadius: innerRadius, theme: theme)
            drawElementSectors(&ctx, center: center, outerRadius: innerRadius, ascLong: asc, theme: theme)
            drawSignSeparators(&ctx, center: center, outerRadius: innerRadius, ascLong: asc, theme: theme)
            drawSignGlyphs(&ctx, center: center, outerRadius: innerRadius, ascLong: asc, theme: theme)
            drawDegreeLines(&ctx, center: center, outerRadius: innerRadius, ascLong: asc, theme: theme)
            if radixData.hasTime {
                drawCuspLines(&ctx, center: center, outerRadius: innerRadius, data: radixData, theme: theme)
                drawCardinalLines(&ctx, center: center, outerRadius: innerRadius, data: radixData, theme: theme)
                drawCardinalLabels(&ctx, center: center, outerRadius: innerRadius, data: radixData, theme: theme)
                drawCuspTexts(&ctx, center: center, outerRadius: innerRadius, data: radixData, theme: theme)
            }
            if showAspects {
                drawAspectLines(&ctx, center: center, outerRadius: innerRadius, data: radixData, theme: theme)
            }
            drawPlanetConnectLines(&ctx, center: center, outerRadius: innerRadius, data: radixData, theme: theme)
            drawPlanetGlyphs(&ctx, center: center, outerRadius: innerRadius, data: radixData, theme: theme)
            drawPlanetTexts(&ctx, center: center, outerRadius: innerRadius, data: radixData, theme: theme)

            // Transit ring: connect lines to zodiac sign circle, then glyphs and texts
            drawDualWheelConnectLines(&ctx, center: center, fullRadius: fullRadius, innerRadius: innerRadius,
                                      connectStart: transitConnectStart, items: transitItems, theme: theme)
            drawDualWheelGlyphs(&ctx, center: center, fullRadius: fullRadius, innerRadius: innerRadius,
                                 glyphFraction: transitGlyphFraction, items: transitItems, theme: theme)
            drawDualWheelTexts(&ctx, center: center, fullRadius: fullRadius, innerRadius: innerRadius,
                                textFraction: transitTextFraction, items: transitItems, theme: theme)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Transit ring free functions

private func drawTransitBackground(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    fullRadius: Double,
    outerFraction: Double,
    theme: WheelTheme
) {
    let r    = CGFloat(fullRadius * outerFraction)
    let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
    ctx.fill(Path(ellipseIn: rect), with: .color(theme.outerCircleBackground))
}

/// Connect lines run from just inside the transit glyph (connectStart × fullRadius, plotAngle)
/// down to the outer edge of the zodiac sign ring (outerSign × innerRadius, mundaneAngle).
private func drawDualWheelConnectLines(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    fullRadius: Double,
    innerRadius: Double,
    connectStart: Double,
    items: [WheelPlotItem],
    theme: WheelTheme
) {
    let startR       = fullRadius * connectStart
    let signRingOutR = innerRadius * WheelMetrics.outerSign  // outer edge of zodiac sign ring
    let stroke       = WheelMetrics.strokeWidth(WheelMetrics.connectLineFraction, outerRadius: fullRadius)

    for item in items {
        let p1 = WheelGeometry.point(angleDeg: item.plotAngle,    radius: startR,       center: center)
        let p2 = WheelGeometry.point(angleDeg: item.mundaneAngle, radius: signRingOutR, center: center)
        var path = Path()
        path.move(to: p1)
        path.addLine(to: p2)
        ctx.stroke(path,
                   with: .color(theme.planetConnectLine.opacity(WheelMetrics.connectLineOpacity)),
                   lineWidth: stroke)
    }
}

/// Transit glyphs sized to match radix planet glyphs (innerRadius-scaled font).
private func drawDualWheelGlyphs(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    fullRadius: Double,
    innerRadius: Double,
    glyphFraction: Double,
    items: [WheelPlotItem],
    theme: WheelTheme
) {
    let r        = fullRadius * glyphFraction
    let fontSize = WheelMetrics.fontSize(WheelMetrics.planetGlyphFontFraction, outerRadius: innerRadius)

    for item in items {
        let pt   = WheelGeometry.point(angleDeg: item.plotAngle, radius: r, center: center)
        let text = Text(item.glyph)
            .font(.custom("EnigmaAstrology2", size: fontSize))
            .foregroundColor(theme.planetGlyph)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

/// Transit position texts rotated tangentially, sized to match radix planet texts.
private func drawDualWheelTexts(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    fullRadius: Double,
    innerRadius: Double,
    textFraction: Double,
    items: [WheelPlotItem],
    theme: WheelTheme
) {
    let r        = fullRadius * textFraction
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction, outerRadius: innerRadius)

    for item in items {
        guard !item.positionText.isEmpty else { continue }
        let pa   = item.plotAngle
        let pt   = WheelGeometry.point(angleDeg: pa, radius: r, center: center)
        let text = Text(item.positionText)
            .font(.system(size: fontSize))
            .foregroundColor(theme.planetText)

        let rotDeg: Double
        let anchor: UnitPoint
        if pa < 180.0 {
            rotDeg = 90.0 - pa
            anchor = .trailing
        } else {
            rotDeg = 270.0 - pa
            anchor = .leading
        }

        ctx.drawLayer { layerCtx in
            layerCtx.translateBy(x: pt.x, y: pt.y)
            layerCtx.rotate(by: .degrees(rotDeg))
            let resolved = layerCtx.resolve(text)
            layerCtx.draw(resolved, at: .zero, anchor: anchor)
        }
    }
}
