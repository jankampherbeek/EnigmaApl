// FrenchTypeWheelCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

// MARK: - Layout constants (fraction of outerRadius)

private let fAspectR:  Double = 0.36   // outer edge of aspect circle
private let fZodiacR:  Double = 0.60   // outer edge of zodiac sign ring
private let fDegreeR:  Double = 0.67   // outer edge of degree tick zone / inner edge of house ring
private let fHouseR:   Double = 0.78   // outer edge of house ring
private let fGlyphR:   Double = 0.83   // planet glyph radius
private let fTextR:    Double = 0.92   // planet position text radius (text extends ~0.10 outward)

private let fTick1:    Double = 0.018  // short (1°) tick length
private let fTick5:    Double = 0.040  // long  (5°) tick length

private let romanNumerals = ["I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII"]

// MARK: - Canvas

struct FrenchTypeWheelCanvas: View {
    let plotData:    WheelPlotData
    let theme:       WheelTheme
    let showAspects: Bool

    var body: some View {
        Canvas { ctx, size in
            let R      = Double(min(size.width, size.height)) / 2.0
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let asc    = plotData.ascendantLongitude

            drawFrenchCircles(&ctx, center: center, R: R, theme: theme)
            drawFrenchElementSectors(&ctx, center: center, R: R, ascLong: asc, theme: theme)
            drawFrenchSignSeparators(&ctx, center: center, R: R, ascLong: asc, theme: theme)
            drawFrenchSignGlyphs(&ctx, center: center, R: R, ascLong: asc, theme: theme)
            drawFrenchDegreeLines(&ctx, center: center, R: R, ascLong: asc, theme: theme)
            if plotData.hasTime {
                drawFrenchCuspLines(&ctx, center: center, R: R, data: plotData, theme: theme)
                drawFrenchHouseNumbers(&ctx, center: center, R: R, data: plotData, theme: theme)
                drawFrenchCardinalGlyphs(&ctx, center: center, R: R, data: plotData, theme: theme)
            }
            if showAspects {
                drawFrenchAspectLines(&ctx, center: center, R: R, data: plotData, theme: theme)
            }
            drawFrenchConnectLines(&ctx, center: center, R: R, data: plotData, theme: theme)
            drawFrenchPlanetGlyphs(&ctx, center: center, R: R, data: plotData, theme: theme)
            drawFrenchPlanetTexts(&ctx, center: center, R: R, data: plotData, theme: theme)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Circles

private func drawFrenchCircles(_ ctx: inout GraphicsContext, center: CGPoint,
                                R: Double, theme: WheelTheme) {
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: R)

    // Background fills: outer → inner (each inner fill paints on top)
    for (fraction, fill) in [
        (1.00,      theme.outerCircleBackground),
        (fHouseR,   theme.houseRingBackground),
        (fZodiacR,  theme.signRingBackground),
        (fAspectR,  theme.aspectCircleBackground)
    ] as [(Double, Color)] {
        let r    = CGFloat(R * fraction)
        let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        ctx.fill(Path(ellipseIn: rect), with: .color(fill))
    }

    // Strokes on the ring boundaries
    for fraction in [fHouseR, fDegreeR, fZodiacR, fAspectR] {
        let r    = CGFloat(R * fraction)
        let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        ctx.stroke(Path(ellipseIn: rect), with: .color(theme.circleStroke), lineWidth: stroke)
    }
}

// MARK: - Zodiac sign ring

private func drawFrenchElementSectors(_ ctx: inout GraphicsContext, center: CGPoint,
                                       R: Double, ascLong: Double, theme: WheelTheme) {
    let innerR       = R * fAspectR
    let outerR       = R * fZodiacR
    let offset       = signOffsetAsc(ascLong)
    let ascSignIndex = Int(ascLong / 30.0)

    for i in 0..<12 {
        let startAngle = Double(i) * 30.0 + offset + 90.0
        let endAngle   = startAngle + 30.0
        let signIndex  = (ascSignIndex + 1 + i) % 12
        let sign       = Signs(rawValue: signIndex + 1) ?? .Aries
        let color      = theme.signSectorColor(for: sign)
        let path = annularSectorPath(from: startAngle, to: endAngle,
                                     inner: innerR, outer: outerR, center: center)
        ctx.fill(path, with: .color(color))
    }
}

private func drawFrenchSignSeparators(_ ctx: inout GraphicsContext, center: CGPoint,
                                       R: Double, ascLong: Double, theme: WheelTheme) {
    let innerR = R * fAspectR
    let outerR = R * fZodiacR
    let offset = signOffsetAsc(ascLong)
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: R)

    for i in 0..<12 {
        let angle = Double(i) * 30.0 + offset + 90.0
        let p1    = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        let p2    = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        var path  = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.signSeparator), lineWidth: stroke)
    }
}

private func drawFrenchSignGlyphs(_ ctx: inout GraphicsContext, center: CGPoint,
                                   R: Double, ascLong: Double, theme: WheelTheme) {
    let glyphR       = R * ((fAspectR + fZodiacR) / 2.0)
    let fontSize     = WheelMetrics.fontSize(WheelMetrics.signGlyphFontFraction, outerRadius: R)
    let offset       = signOffsetAsc(ascLong)
    let ascSignIndex = Int(ascLong / 30.0)

    for i in 0..<12 {
        let midAngle  = Double(i) * 30.0 + offset + 90.0 + 15.0
        let pt        = WheelGeometry.point(angleDeg: midAngle, radius: glyphR, center: center)
        let signIndex = (ascSignIndex + 1 + i) % 12
        guard let sign = Signs(rawValue: signIndex + 1) else { continue }
        let glyph = GlyphSelector.getGlyphForSign(sign)
        let text  = Text(glyph)
            .font(.custom("EnigmaAstrology2", size: fontSize))
            .foregroundColor(theme.signGlyph)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - Degree ticks

private func drawFrenchDegreeLines(_ ctx: inout GraphicsContext, center: CGPoint,
                                    R: Double, ascLong: Double, theme: WheelTheme) {
    let baseR  = R * fZodiacR
    let offset = signOffsetAsc(ascLong)

    for i in 0..<360 {
        let angle   = Double(i) + offset + 90.0
        let tickLen = (i % 5 == 0) ? fTick5 : fTick1
        let tipR    = baseR + R * tickLen
        let p1      = WheelGeometry.point(angleDeg: angle, radius: baseR, center: center)
        let p2      = WheelGeometry.point(angleDeg: angle, radius: tipR,  center: center)
        var path    = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.degreeTickStroke), lineWidth: 1.0)
    }
}

// MARK: - House ring

private func drawFrenchCuspLines(_ ctx: inout GraphicsContext, center: CGPoint,
                                  R: Double, data: WheelPlotData, theme: WheelTheme) {
    let innerR  = R * fDegreeR
    let outerR  = R * fHouseR
    let thin    = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction,       outerRadius: R)
    let thick   = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 2.0, outerRadius: R)
    let ascLong = data.ascendantLongitude

    for (i, cuspLong) in data.cuspLongitudes.enumerated() {
        let angle = WheelGeometry.mundaneAngle(longitude: cuspLong, ascendantLongitude: ascLong)
        let lw    = (i % 3 == 0) ? thick : thin
        let p1    = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        let p2    = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        var path  = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.cuspLine.opacity(WheelMetrics.cuspLineOpacity)),
                   lineWidth: lw)
    }
}

private func drawFrenchHouseNumbers(_ ctx: inout GraphicsContext, center: CGPoint,
                                     R: Double, data: WheelPlotData, theme: WheelTheme) {
    guard data.cuspLongitudes.count >= 12 else { return }
    let r        = R * ((fDegreeR + fHouseR) / 2.0)
    let fontSize = WheelMetrics.fontSize(WheelMetrics.cardinalFontFraction, outerRadius: R)
    let ascLong  = data.ascendantLongitude

    for i in 0..<12 {
        let a1 = WheelGeometry.mundaneAngle(longitude: data.cuspLongitudes[i],
                                            ascendantLongitude: ascLong)
        var a2 = WheelGeometry.mundaneAngle(longitude: data.cuspLongitudes[(i + 1) % 12],
                                            ascendantLongitude: ascLong)
        if a2 <= a1 { a2 += 360.0 }
        let midAngle = WheelGeometry.normalise((a1 + a2) / 2.0)

        let pt   = WheelGeometry.point(angleDeg: midAngle, radius: r, center: center)
        let text = Text(romanNumerals[i])
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(theme.cuspText)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - ASC / MC glyphs in house ring

private func drawFrenchCardinalGlyphs(_ ctx: inout GraphicsContext, center: CGPoint,
                                       R: Double, data: WheelPlotData, theme: WheelTheme) {
    let r        = R * ((fDegreeR + fHouseR) / 2.0)
    let fontSize = WheelMetrics.fontSize(WheelMetrics.planetGlyphFontFraction, outerRadius: R)
    let ascLong  = data.ascendantLongitude

    let ascAngle = WheelGeometry.mundaneAngle(longitude: data.ascendantLongitude,
                                              ascendantLongitude: ascLong)   // = 90°
    let mcAngle  = WheelGeometry.mundaneAngle(longitude: data.mcLongitude,
                                              ascendantLongitude: ascLong)

    for (factor, angle) in [(Factors.ascendant, ascAngle), (Factors.mc, mcAngle)] {
        let pt    = WheelGeometry.point(angleDeg: angle, radius: r, center: center)
        let glyph = GlyphSelector.getGlyphForFactor(factor)
        let text  = Text(glyph)
            .font(.custom("EnigmaAstrology2", size: fontSize))
            .foregroundColor(theme.cardinalIndicator)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - Aspect lines

private func drawFrenchAspectLines(_ ctx: inout GraphicsContext, center: CGPoint,
                                    R: Double, data: WheelPlotData, theme: WheelTheme) {
    guard !data.aspectItems.isEmpty else { return }
    let r         = R * fAspectR
    let maxStroke = WheelMetrics.strokeWidth(WheelMetrics.aspectLineFraction, outerRadius: R)
    let minStroke = max(0.5, maxStroke * 0.15)

    for item in data.aspectItems {
        let p1        = WheelGeometry.point(angleDeg: item.angle1, radius: r, center: center)
        let p2        = WheelGeometry.point(angleDeg: item.angle2, radius: r, center: center)
        let lineWidth = minStroke + (maxStroke - minStroke) * CGFloat(item.exactness)
        let color     = theme.aspectLineColor(original: item.color)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(color.opacity(WheelMetrics.aspectOpacity)),
                   lineWidth: lineWidth)
    }
}

// MARK: - Planet glyphs, texts, connect lines

private func drawFrenchConnectLines(_ ctx: inout GraphicsContext, center: CGPoint,
                                     R: Double, data: WheelPlotData, theme: WheelTheme) {
    let glyphR = R * fGlyphR
    let zodR   = R * fZodiacR
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.connectLineFraction, outerRadius: R)

    for item in data.planetItems {
        let p1   = WheelGeometry.point(angleDeg: item.plotAngle,    radius: glyphR, center: center)
        let p2   = WheelGeometry.point(angleDeg: item.mundaneAngle, radius: zodR,   center: center)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path,
                   with: .color(theme.planetConnectLine.opacity(WheelMetrics.connectLineOpacity)),
                   lineWidth: stroke)
    }
}

private func drawFrenchPlanetGlyphs(_ ctx: inout GraphicsContext, center: CGPoint,
                                     R: Double, data: WheelPlotData, theme: WheelTheme) {
    let r        = R * fGlyphR
    let fontSize = WheelMetrics.fontSize(WheelMetrics.planetGlyphFontFraction, outerRadius: R)

    for item in data.planetItems {
        let pt   = WheelGeometry.point(angleDeg: item.plotAngle, radius: r, center: center)
        let text = Text(item.glyph)
            .font(.custom("EnigmaAstrology2", size: fontSize))
            .foregroundColor(theme.planetGlyph)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

private func drawFrenchPlanetTexts(_ ctx: inout GraphicsContext, center: CGPoint,
                                    R: Double, data: WheelPlotData, theme: WheelTheme) {
    let r        = R * fTextR
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction, outerRadius: R)

    for item in data.planetItems {
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
