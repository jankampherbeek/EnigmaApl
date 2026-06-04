// ZodiacDivisionsWheelCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// One mark in the outer ring: the mundane angle and the four division glyphs for a single factor.
struct ZodiacDivisionMark {
    let mundaneAngle: Double
    let signGlyph:    String
    let decanGlyph:   String
    let dodecatGlyph: String
    let boundGlyph:   String
}

/// Draws the radix chart wheel with an outer ring showing zodiac division results for each factor.
/// The outer ring displays four stacked glyphs per factor (sign, decan, dodecatemoria, bound),
/// arranged from outer to inner at the factor's mundane angle.
struct ZodiacDivisionsWheelCanvas: View {
    let radixData: WheelPlotData
    let marks:     [ZodiacDivisionMark]
    let theme:     WheelTheme
    let showAspects: Bool

    // Main wheel is slightly smaller to leave room for the division ring
    private let radixScale:    Double = 0.70
    private let outerFraction: Double = 0.96

    var body: some View {
        Canvas { ctx, size in
            let fullRadius  = Double(min(size.width, size.height)) / 2.0
            let innerRadius = fullRadius * radixScale
            let center      = CGPoint(x: size.width / 2, y: size.height / 2)
            let asc         = radixData.ascendantLongitude

            // Outer division-ring background
            let bgR    = CGFloat(fullRadius * outerFraction)
            let bgRect = CGRect(x: center.x - bgR, y: center.y - bgR, width: bgR * 2, height: bgR * 2)
            ctx.fill(Path(ellipseIn: bgRect), with: .color(theme.outerCircleBackground))

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

            drawDivisionMarks(&ctx, center: center, fullRadius: fullRadius,
                              innerRadius: innerRadius, marks: marks, theme: theme)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Division ring drawing

private func drawDivisionMarks(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    fullRadius: Double,
    innerRadius: Double,
    marks: [ZodiacDivisionMark],
    theme: WheelTheme
) {
    let ringOuter  = fullRadius * 0.96
    let ringWidth  = ringOuter - innerRadius
    let glyphSize  = CGFloat(ringWidth * 0.16)          // each glyph gets ~16% of ring height
    let strokeW    = WheelMetrics.strokeWidth(WheelMetrics.connectLineFraction, outerRadius: fullRadius)

    // Radii at which the four glyphs are centred (inner → outer: bound, dodecat, decan, sign)
    let rBound   = innerRadius + ringWidth * 0.12
    let rDodecat = innerRadius + ringWidth * 0.37
    let rDecan   = innerRadius + ringWidth * 0.62
    let rSign    = innerRadius + ringWidth * 0.87

    for mark in marks {
        let angle = mark.mundaneAngle
        let rotDeg = angle <= 180.0 ? (90.0 - angle) : (270.0 - angle)

        // Tick mark from inner boundary outward
        let tickInPt  = WheelGeometry.point(angleDeg: angle, radius: innerRadius * WheelMetrics.outerSign, center: center)
        let tickOutPt = WheelGeometry.point(angleDeg: angle, radius: innerRadius, center: center)
        var tick = Path()
        tick.move(to: tickInPt)
        tick.addLine(to: tickOutPt)
        ctx.stroke(tick, with: .color(theme.planetGlyph), lineWidth: strokeW * 1.5)

        // Sign glyph (outermost)
        drawDivisionGlyph(&ctx, glyph: mark.signGlyph,
                          angle: angle, radius: rSign, center: center,
                          rotDeg: rotDeg, size: glyphSize, theme: theme)

        // Decan glyph
        drawDivisionGlyph(&ctx, glyph: mark.decanGlyph,
                          angle: angle, radius: rDecan, center: center,
                          rotDeg: rotDeg, size: glyphSize, theme: theme)

        // Dodecatemoria glyph
        drawDivisionGlyph(&ctx, glyph: mark.dodecatGlyph,
                          angle: angle, radius: rDodecat, center: center,
                          rotDeg: rotDeg, size: glyphSize, theme: theme)

        // Bound glyph (innermost)
        drawDivisionGlyph(&ctx, glyph: mark.boundGlyph,
                          angle: angle, radius: rBound, center: center,
                          rotDeg: rotDeg, size: glyphSize, theme: theme)
    }
}

private func drawDivisionGlyph(
    _ ctx: inout GraphicsContext,
    glyph: String,
    angle: Double,
    radius: Double,
    center: CGPoint,
    rotDeg: Double,
    size: CGFloat,
    theme: WheelTheme
) {
    let pt   = WheelGeometry.point(angleDeg: angle, radius: radius, center: center)
    let label = Text(glyph)
        .font(.custom("EnigmaAstrology2", size: size))
        .foregroundColor(Color(theme.planetGlyph))

    var labelCtx = ctx
    labelCtx.translateBy(x: pt.x, y: pt.y)
    labelCtx.rotate(by: .degrees(rotDeg))
    labelCtx.draw(label, at: .zero, anchor: .center)
}
