// AltZodiacStartWheelCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// Draws the radix chart wheel with the 12-sign zodiac ring re-anchored so that its
/// first slice (traditionally Aries 0°) starts at the ecliptic longitude of a
/// user-chosen factor, instead of at the real vernal equinox point.
///
/// House cusps, the ascendant/MC, planet positions and aspects are all drawn exactly as
/// in the normal radix wheel (they don't depend on the zodiac's starting point) — only
/// the sign ring (sectors, separators, glyphs, degree ticks) is redrawn, plus a marker
/// showing exactly where the chosen factor (and therefore the new zodiac's 0°) sits.
struct AltZodiacStartWheelCanvas: View {
    let radixData: WheelPlotData
    let zodiacStartLongitude: Double
    let theme: WheelTheme
    let showAspects: Bool

    var body: some View {
        Canvas { ctx, size in
            let outerRadius = Double(min(size.width, size.height)) / 2.0
            let center      = CGPoint(x: size.width / 2, y: size.height / 2)
            let asc         = radixData.ascendantLongitude

            drawCircles(&ctx, center: center, outerRadius: outerRadius, theme: theme)
            drawAltZodiacSectors(&ctx, center: center, outerRadius: outerRadius,
                                 zodiacStart: zodiacStartLongitude, ascLong: asc, theme: theme)
            drawAltZodiacSeparators(&ctx, center: center, outerRadius: outerRadius,
                                    zodiacStart: zodiacStartLongitude, ascLong: asc, theme: theme)
            drawAltZodiacGlyphs(&ctx, center: center, outerRadius: outerRadius,
                                zodiacStart: zodiacStartLongitude, ascLong: asc, theme: theme)
            drawAltZodiacDegreeLines(&ctx, center: center, outerRadius: outerRadius,
                                     zodiacStart: zodiacStartLongitude, ascLong: asc, theme: theme)
            if radixData.hasTime {
                drawCuspLines(&ctx, center: center, outerRadius: outerRadius, data: radixData, theme: theme)
                drawCardinalLines(&ctx, center: center, outerRadius: outerRadius, data: radixData, theme: theme)
                drawCardinalLabels(&ctx, center: center, outerRadius: outerRadius, data: radixData, theme: theme)
                drawCuspTexts(&ctx, center: center, outerRadius: outerRadius, data: radixData, theme: theme)
            }
            if showAspects {
                drawAspectLines(&ctx, center: center, outerRadius: outerRadius, data: radixData, theme: theme)
            }
            drawPlanetConnectLines(&ctx, center: center, outerRadius: outerRadius, data: radixData, theme: theme)
            drawPlanetGlyphs(&ctx, center: center, outerRadius: outerRadius, data: radixData, theme: theme)
            drawPlanetTexts(&ctx, center: center, outerRadius: outerRadius, data: radixData, theme: theme)
            drawZodiacStartMarker(&ctx, center: center, outerRadius: outerRadius,
                                  zodiacStart: zodiacStartLongitude, ascLong: asc, theme: theme)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Shifted zodiac ring

/// Angular offset (in the `i*30 + offset + 90` convention used by the shared sign-ring
/// drawing functions) that places slice 0 exactly at the chosen factor's true mundane angle.
private func altZodiacOffset(zodiacStart: Double, ascLong: Double) -> Double {
    WheelGeometry.mundaneAngle(longitude: zodiacStart, ascendantLongitude: ascLong) - 90.0
}

private func drawAltZodiacSectors(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                                  zodiacStart: Double, ascLong: Double, theme: WheelTheme) {
    let innerR = outerRadius * WheelMetrics.outerHouse
    let outerR = outerRadius * WheelMetrics.outerSign
    let offset = altZodiacOffset(zodiacStart: zodiacStart, ascLong: ascLong)

    for i in 0..<12 {
        let startAngle = Double(i) * 30.0 + offset + 90.0
        let endAngle   = startAngle + 30.0
        let sign       = Signs(rawValue: i + 1) ?? .Aries
        let color      = theme.signSectorColor(for: sign)
        let path = annularSectorPath(from: startAngle, to: endAngle, inner: innerR, outer: outerR, center: center)
        ctx.fill(path, with: .color(color))
    }
}

private func drawAltZodiacSeparators(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                                     zodiacStart: Double, ascLong: Double, theme: WheelTheme) {
    let innerR = outerRadius * WheelMetrics.outerHouse
    let outerR = outerRadius * WheelMetrics.outerSign
    let offset = altZodiacOffset(zodiacStart: zodiacStart, ascLong: ascLong)
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: outerRadius)

    for i in 0..<12 {
        let angle = Double(i) * 30.0 + offset + 90.0
        let p1 = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        let p2 = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.signSeparator), lineWidth: stroke)
    }
}

private func drawAltZodiacGlyphs(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                                 zodiacStart: Double, ascLong: Double, theme: WheelTheme) {
    let glyphRadius = outerRadius * WheelMetrics.signGlyph
    let fontSize = WheelMetrics.fontSize(WheelMetrics.signGlyphFontFraction, outerRadius: outerRadius)
    let offset = altZodiacOffset(zodiacStart: zodiacStart, ascLong: ascLong)

    for i in 0..<12 {
        let midAngle = Double(i) * 30.0 + offset + 90.0 + 15.0
        let pt = WheelGeometry.point(angleDeg: midAngle, radius: glyphRadius, center: center)
        guard let sign = Signs(rawValue: i + 1) else { continue }
        let glyph = GlyphSelector.getGlyphForSign(sign)
        let text = Text(glyph)
            .font(.custom("EnigmaAstrology3", size: fontSize))
            .foregroundColor(theme.signGlyph)
        let resolved = ctx.resolve(text)
        ctx.draw(resolved, at: pt, anchor: .center)
    }
}

private func drawAltZodiacDegreeLines(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                                      zodiacStart: Double, ascLong: Double, theme: WheelTheme) {
    let startR = outerRadius * WheelMetrics.outerHouse
    let shortR = outerRadius * WheelMetrics.degrees
    let longR  = outerRadius * WheelMetrics.degrees5
    let offset = altZodiacOffset(zodiacStart: zodiacStart, ascLong: ascLong)
    let thin   = CGFloat(1.0)

    for i in 0..<360 {
        let angle = Double(i) + offset + 90.0
        let endR  = (i % 5 == 0) ? longR : shortR
        let p1 = WheelGeometry.point(angleDeg: angle, radius: endR,   center: center)
        let p2 = WheelGeometry.point(angleDeg: angle, radius: startR, center: center)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.degreeTickStroke), lineWidth: thin)
    }
}

// MARK: - Start-factor marker

/// Radial tick spanning the outer rings at the exact point that defines the new zodiac's 0°.
private func drawZodiacStartMarker(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                                   zodiacStart: Double, ascLong: Double, theme: WheelTheme) {
    let angle  = WheelGeometry.mundaneAngle(longitude: zodiacStart, ascendantLongitude: ascLong)
    let innerR = outerRadius * WheelMetrics.outerHouse
    let outerR = outerRadius * WheelMetrics.outerCircle
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: outerRadius) * 1.5

    let p1 = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
    let p2 = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
    var path = Path(); path.move(to: p1); path.addLine(to: p2)
    ctx.stroke(path, with: .color(theme.cardinalIndicator), lineWidth: stroke)
}
