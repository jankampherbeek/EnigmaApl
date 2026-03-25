// Dial90TypeWheelCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
//
// Canvas for the Ebertin-style 90° dial wheel.
//
// Layout from centre outward:
//   1. Planet area    (0 … fHalfDegInner)          — glyphs, degree texts, centre cross
//   2. 0.5° ring      (fHalfDegInner … f1DegInner) — 180 ticks: short (0.5°), medium (1°),
//                                                     long (5°, extends inward past fHalfDegInner)
//   3. 1° ring        (f1DegInner … fLabelInner)   — 90 uniform ticks (one per dial degree)
//   4. Label ring     (fLabelInner … fLabelOuter)  — degree labels every 5° (0, 5, 10 … 85)
//
// Visual angle = (ecliptic longitude mod 90) × 4.
// No background colour; ASC / MC outside the label ring.

import SwiftUI

// MARK: - Layout constants (fraction of outerRadius)

private let dialOuterScale:   Double = 1.0

private let fLabelOuter:      Double = 0.99   // outer boundary of label ring
private let fLabelInner:      Double = 0.90   // inner boundary of label ring / outer of 1° ring
private let f1DegInner:       Double = 0.87   // inner boundary of 1° ring / outer of 0.5° ring
private let fHalfDegInner:    Double = 0.82   // inner boundary of 0.5° ring (planet area starts)

// Planets (same as Dial360)
private let fPlanetGlyph:     Double = 0.78
private let fPlanetText:      Double = 0.62

// Cross arm half-length
private let fCrossArm:        Double = 0.04

// Tick lengths in 0.5° ring (from f1DegInner, pointing inward)
private let fTickHalfDeg:     Double = 0.012   // 0.5° tick (half degree, non-integer)
private let fTickWholeDeg:    Double = 0.030   // 1° tick
private let fTick5Deg:        Double = 0.080   // 5° tick: spans ring (0.050) + extension inside (0.030)

// Degree label radius (midpoint of label ring)
private let fDegLabel:        Double = 0.945

// MARK: - Canvas

struct Dial90TypeWheelCanvas: View {
    let plotData: WheelPlotData
    let theme:    WheelTheme

    var body: some View {
        Canvas { ctx, size in
            let R      = Double(min(size.width, size.height)) / 2.0 * dialOuterScale
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            drawDial90Background   (&ctx, center: center, R: R, theme: theme)
            drawDial90RingStrokes  (&ctx, center: center, R: R, theme: theme)
            drawDial901DegTicks    (&ctx, center: center, R: R, theme: theme)
            drawDial90HalfDegTicks (&ctx, center: center, R: R, theme: theme)
            drawDial90DegreeLabels (&ctx, center: center, R: R, theme: theme)
            drawDial90CenterCross  (&ctx, center: center, R: R, theme: theme)
            drawDial90ConnectLines (&ctx, center: center, R: R, data: plotData, theme: theme)
            drawDial90PlanetGlyphs (&ctx, center: center, R: R, data: plotData, theme: theme)
            drawDial90PlanetTexts  (&ctx, center: center, R: R, data: plotData, theme: theme)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Background (white, no element colours)

private func drawDial90Background(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                   theme: WheelTheme) {
    // Label ring (fLabelInner…fLabelOuter): light blue (or white in b/w mode)
    let rOuter     = CGFloat(R * fLabelOuter)
    let outerRect  = CGRect(x: center.x - rOuter, y: center.y - rOuter,
                            width: rOuter * 2, height: rOuter * 2)
    ctx.fill(Path(ellipseIn: outerRect), with: .color(theme.signRingBackground))

    // Inner disc: standard background colour (or white in b/w mode)
    let rInner    = CGFloat(R * fLabelInner)
    let innerRect = CGRect(x: center.x - rInner, y: center.y - rInner,
                           width: rInner * 2, height: rInner * 2)
    ctx.fill(Path(ellipseIn: innerRect), with: .color(theme.outerCircleBackground))
}

// MARK: - Ring boundary circles

private func drawDial90RingStrokes(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                    theme: WheelTheme) {
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: R)
    for fraction in [fLabelOuter, fLabelInner, f1DegInner, fHalfDegInner] {
        let r    = CGFloat(R * fraction)
        let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        ctx.stroke(Path(ellipseIn: rect), with: .color(theme.circleStroke), lineWidth: stroke)
    }
}

// MARK: - 1° ring: 90 uniform ticks (one per dial degree, each spanning the full ring width)

private func drawDial901DegTicks(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                  theme: WheelTheme) {
    let outerR = R * fLabelInner
    let innerR = R * f1DegInner
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 0.8, outerRadius: R)

    for i in 0..<90 {
        let angle = Double(i) * 4.0   // 90 × 4° = 360°
        let p1    = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        let p2    = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        var path  = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.degreeTickStroke), lineWidth: stroke)
    }
}

// MARK: - 0.5° ring: 180 ticks with variable lengths; 5° ticks extend into planet area

private func drawDial90HalfDegTicks(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                     theme: WheelTheme) {
    let outerR = R * f1DegInner   // ticks start at outer edge of 0.5° ring

    for i in 0..<180 {
        let angle    = Double(i) * 2.0   // 180 × 2° = 360°
        let tickLen: Double
        if i % 10 == 0 {           // every 10 half-degrees = 5 dial degrees
            tickLen = fTick5Deg
        } else if i % 2 == 0 {    // every 2 half-degrees = 1 dial degree
            tickLen = fTickWholeDeg
        } else {
            tickLen = fTickHalfDeg
        }
        let innerR = outerR - R * tickLen
        let p1     = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        let p2     = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        var path   = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.degreeTickStroke), lineWidth: 1.0)
    }
}

// MARK: - Degree labels (0, 5, 10 … 85) in the label ring

private func drawDial90DegreeLabels(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                     theme: WheelTheme) {
    let labelR   = R * fDegLabel
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction * 1.3, outerRadius: R)

    for i in 0..<18 {
        let dialDeg = i * 5
        let angle   = Double(dialDeg) * 4.0   // dial degrees → visual angle
        let pt      = WheelGeometry.point(angleDeg: angle, radius: labelR, center: center)
        let text    = Text("\(dialDeg)")
            .font(.system(size: fontSize, weight: .medium))
            .foregroundColor(theme.planetText)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - Centre cross

private func drawDial90CenterCross(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                    theme: WheelTheme) {
    let arm    = CGFloat(R * fCrossArm)
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: R)

    var h = Path()
    h.move(to: CGPoint(x: center.x - arm, y: center.y))
    h.addLine(to: CGPoint(x: center.x + arm, y: center.y))
    var v = Path()
    v.move(to: CGPoint(x: center.x, y: center.y - arm))
    v.addLine(to: CGPoint(x: center.x, y: center.y + arm))

    ctx.stroke(h, with: .color(theme.circleStroke), lineWidth: stroke)
    ctx.stroke(v, with: .color(theme.circleStroke), lineWidth: stroke)
}

// MARK: - Planets

private func drawDial90ConnectLines(_ ctx: inout GraphicsContext, center: CGPoint,
                                     R: Double, data: WheelPlotData, theme: WheelTheme) {
    let glyphR = R * fPlanetGlyph
    let ringR  = R * fHalfDegInner
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.connectLineFraction, outerRadius: R)

    for item in data.planetItems {
        let p1   = WheelGeometry.point(angleDeg: item.plotAngle,    radius: glyphR, center: center)
        let p2   = WheelGeometry.point(angleDeg: item.mundaneAngle, radius: ringR,  center: center)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.planetConnectLine.opacity(WheelMetrics.connectLineOpacity)),
                   lineWidth: stroke)
    }
}

private func drawDial90PlanetGlyphs(_ ctx: inout GraphicsContext, center: CGPoint,
                                     R: Double, data: WheelPlotData, theme: WheelTheme) {
    let r        = R * fPlanetGlyph
    let fontSize = WheelMetrics.fontSize(WheelMetrics.planetGlyphFontFraction, outerRadius: R)

    for item in data.planetItems {
        let pt   = WheelGeometry.point(angleDeg: item.plotAngle, radius: r, center: center)
        let text = Text(item.glyph)
            .font(.custom("EnigmaAstrology2", size: fontSize))
            .foregroundColor(theme.planetGlyph)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

private func drawDial90PlanetTexts(_ ctx: inout GraphicsContext, center: CGPoint,
                                    R: Double, data: WheelPlotData, theme: WheelTheme) {
    let r        = R * fPlanetText
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction, outerRadius: R)

    for item in data.planetItems {
        let pt   = WheelGeometry.point(angleDeg: item.plotAngle, radius: r, center: center)
        let text = Text(item.positionText)
            .font(.system(size: fontSize))
            .foregroundColor(theme.planetText)
                 + Text(" " + signGlyph(for: item.eclipticLongitude))
            .font(.custom("EnigmaAstrology2", size: fontSize))
            .foregroundColor(theme.planetText)
        drawDial90RotatedText(&ctx, text: text, at: pt, angle: item.plotAngle)
    }
}

// MARK: - Helper

private func signGlyph(for longitude: Double) -> String {
    let signIndex = Int(longitude / 30.0) % 12
    let sign = Signs(rawValue: signIndex + 1) ?? .Aries
    return GlyphSelector.getGlyphForSign(sign)
}

private func drawDial90RotatedText(_ ctx: inout GraphicsContext, text: Text,
                                    at pt: CGPoint, angle: Double) {
    let rotDeg: Double
    let anchor: UnitPoint
    if angle < 180.0 {
        rotDeg = 90.0 - angle
        anchor = .trailing
    } else {
        rotDeg = 270.0 - angle
        anchor = .leading
    }
    ctx.drawLayer { layerCtx in
        layerCtx.translateBy(x: pt.x, y: pt.y)
        layerCtx.rotate(by: .degrees(rotDeg))
        layerCtx.draw(layerCtx.resolve(text), at: .zero, anchor: anchor)
    }
}
