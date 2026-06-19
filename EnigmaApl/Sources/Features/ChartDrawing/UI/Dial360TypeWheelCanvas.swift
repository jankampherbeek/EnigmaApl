// Dial360TypeWheelCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
//
// Canvas for the Ebertin-style 360° dial wheel.
//
// Layout from centre outward:
//   1. Planet area          (0 … fTickInner)      — glyphs + degree texts + centre cross
//   2. 1° degree ring       (fTickInner … fDeg10Inner)  — 360 ticks, varying length
//   3. 10° ring             (fDeg10Inner … fSignInner)  — 36 ticks spanning full ring width
//   4. Sign ring            (fSignInner … fSignOuter)   — element colours, sign glyphs, degree labels
//
// Angle convention: 0° = top, counter-clockwise.
// Dial angle = ecliptic longitude (Aries at top, fixed ring — no ascendant rotation).
//
// When plotData.hasTime == false: ASC and MC are hidden.

import SwiftUI

// MARK: - Layout constants (fraction of outerRadius)

private let dialOuterScale:   Double = 1.0

private let fSignOuter:       Double = 0.99   // outer boundary of sign ring
private let fSignInner:       Double = 0.90   // inner boundary of sign ring
private let fDeg10Inner:      Double = 0.87   // inner boundary of 10° ring
private let fTickInner:       Double = 0.82   // inner boundary of 1° ring (planet area starts here)

// Planets
private let fPlanetGlyph:     Double = 0.78   // planet glyph radius
private let fPlanetText:      Double = 0.59   // planet degree text radius

// Cross arm half-length
private let fCrossArm:        Double = 0.04

// Tick lengths (fraction of outerRadius, pointing inward from fDeg10Inner)
private let fTick1:           Double = 0.010
private let fTick5:           Double = 0.025
private let fTick10deg:       Double = 0.042

// Degree labels (0, 30 … 330): centered horizontally in the sign ring, 5° into each sector
private let fDegLabel:        Double = 0.945   // midpoint of sign ring (0.90 … 0.99)
private let fDegLabelOffset:  Double = 5.0     // degrees past sign boundary

// MARK: - Canvas

struct Dial360TypeWheelCanvas: View {
    let plotData: WheelPlotData
    let theme:    WheelTheme

    var body: some View {
        Canvas { ctx, size in
            let R      = Double(min(size.width, size.height)) / 2.0 * dialOuterScale
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            drawDialBackground    (&ctx, center: center, R: R, theme: theme)
            drawDialSignSectors   (&ctx, center: center, R: R, theme: theme)
            drawDialSignGlyphs    (&ctx, center: center, R: R, theme: theme)
            drawDialSignSeparators(&ctx, center: center, R: R, theme: theme)
            drawDialDegreeBoundaryLabels(&ctx, center: center, R: R, theme: theme)
            drawDial10DegTicks    (&ctx, center: center, R: R, theme: theme)
            drawDialDegTicks      (&ctx, center: center, R: R, theme: theme)
            drawDialRingStrokes   (&ctx, center: center, R: R, theme: theme)
            drawDialCenterCross   (&ctx, center: center, R: R, theme: theme)
            drawDialConnectLines  (&ctx, center: center, R: R, data: plotData, theme: theme)
            drawDialPlanetGlyphs  (&ctx, center: center, R: R, data: plotData, theme: theme)
            drawDialPlanetTexts   (&ctx, center: center, R: R, data: plotData, theme: theme)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Background

private func drawDialBackground(_ ctx: inout GraphicsContext, center: CGPoint,
                                 R: Double, theme: WheelTheme) {
    let r    = CGFloat(R * fSignOuter)
    let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
    ctx.fill(Path(ellipseIn: rect), with: .color(theme.outerCircleBackground))
}

// MARK: - Ring strokes

private func drawDialRingStrokes(_ ctx: inout GraphicsContext, center: CGPoint,
                                  R: Double, theme: WheelTheme) {
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: R)
    for fraction in [fSignOuter, fSignInner, fDeg10Inner, fTickInner] {
        let r    = CGFloat(R * fraction)
        let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        ctx.stroke(Path(ellipseIn: rect), with: .color(theme.circleStroke), lineWidth: stroke)
    }
}

// MARK: - Sign ring

private func drawDialSignSectors(_ ctx: inout GraphicsContext, center: CGPoint,
                                  R: Double, theme: WheelTheme) {
    let innerR = R * fSignInner
    let outerR = R * fSignOuter

    for i in 0..<12 {
        let startAngle = Double(i) * 30.0
        let endAngle   = startAngle + 30.0
        let sign       = Signs(rawValue: i + 1) ?? .Aries
        let color      = theme.signSectorColor(for: sign)
        let path = annularSectorPath(from: startAngle, to: endAngle,
                                     inner: innerR, outer: outerR, center: center)
        ctx.fill(path, with: .color(color))
    }
}

private func drawDialSignGlyphs(_ ctx: inout GraphicsContext, center: CGPoint,
                                 R: Double, theme: WheelTheme) {
    let glyphR   = R * ((fSignInner + fSignOuter) / 2.0)
    let fontSize = WheelMetrics.fontSize(WheelMetrics.signGlyphFontFraction, outerRadius: R)

    for i in 0..<12 {
        let midAngle  = Double(i) * 30.0 + 15.0
        let sign      = Signs(rawValue: i + 1) ?? .Aries
        let glyph     = GlyphSelector.getGlyphForSign(sign)
        let pt        = WheelGeometry.point(angleDeg: midAngle, radius: glyphR, center: center)
        let text      = Text(glyph)
            .font(.custom("EnigmaAstrology3", size: fontSize))
            .foregroundColor(theme.signGlyph)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

private func drawDialSignSeparators(_ ctx: inout GraphicsContext, center: CGPoint,
                                     R: Double, theme: WheelTheme) {
    let innerR = R * fSignInner
    let outerR = R * fSignOuter
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: R)

    for i in 0..<12 {
        let angle = Double(i) * 30.0
        let p1    = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        let p2    = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        var path  = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.signSeparator), lineWidth: stroke)
    }
}

/// Draws the ecliptic degree number (0, 30, 60 … 330) at each sign boundary.
private func drawDialDegreeBoundaryLabels(_ ctx: inout GraphicsContext, center: CGPoint,
                                           R: Double, theme: WheelTheme) {
    let labelR   = R * fDegLabel
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction * 1.3, outerRadius: R)

    for i in 0..<12 {
        // 5° into the sign so the label sits clearly inside the sector, not on the separator line
        let angle  = Double(i) * 30.0 + fDegLabelOffset
        let degree = i * 30
        let pt     = WheelGeometry.point(angleDeg: angle, radius: labelR, center: center)
        let text   = Text("\(degree)")
            .font(.system(size: fontSize, weight: .medium))
            .foregroundColor(theme.planetText)
        // Draw horizontally centred — avoids radial extension clipping the ring boundaries
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - Tick rings

/// Draws one tick per 10° spanning the full width of the 10° ring.
private func drawDial10DegTicks(_ ctx: inout GraphicsContext, center: CGPoint,
                                 R: Double, theme: WheelTheme) {
    let outerR = R * fSignInner    // = fDeg10Outer
    let innerR = R * fDeg10Inner
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 0.8, outerRadius: R)

    for i in 0..<36 {
        let angle = Double(i) * 10.0
        let p1    = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        let p2    = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        var path  = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.degreeTickStroke), lineWidth: stroke)
    }
}

/// Draws 360 ticks pointing inward from the outer edge of the 1° ring.
/// Length: short (1°), medium (5°), long (10°).
private func drawDialDegTicks(_ ctx: inout GraphicsContext, center: CGPoint,
                               R: Double, theme: WheelTheme) {
    let outerR = R * fDeg10Inner   // outer edge of 1° ring = inner edge of 10° ring
    let stroke = CGFloat(1.0)

    for i in 0..<360 {
        let angle   = Double(i)
        let tickLen: Double
        if i % 10 == 0 {
            tickLen = fTick10deg
        } else if i % 5 == 0 {
            tickLen = fTick5
        } else {
            tickLen = fTick1
        }
        let innerR = outerR - R * tickLen
        let p1     = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        let p2     = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        var path   = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.degreeTickStroke), lineWidth: stroke)
    }
}

// MARK: - Centre cross

private func drawDialCenterCross(_ ctx: inout GraphicsContext, center: CGPoint,
                                  R: Double, theme: WheelTheme) {
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

private func drawDialConnectLines(_ ctx: inout GraphicsContext, center: CGPoint,
                                   R: Double, data: WheelPlotData, theme: WheelTheme) {
    let glyphR = R * fPlanetGlyph
    let ringR  = R * fTickInner
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.connectLineFraction, outerRadius: R)

    for item in data.planetItems {
        let p1   = WheelGeometry.point(angleDeg: item.plotAngle,    radius: glyphR, center: center)
        let p2   = WheelGeometry.point(angleDeg: item.mundaneAngle, radius: ringR,  center: center)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path,
                   with: .color(theme.planetConnectLine.opacity(WheelMetrics.connectLineOpacity)),
                   lineWidth: stroke)
    }
}

private func drawDialPlanetGlyphs(_ ctx: inout GraphicsContext, center: CGPoint,
                                   R: Double, data: WheelPlotData, theme: WheelTheme) {
    let r        = R * fPlanetGlyph
    let fontSize = WheelMetrics.fontSize(WheelMetrics.planetGlyphFontFraction, outerRadius: R)

    for item in data.planetItems {
        let pt   = WheelGeometry.point(angleDeg: item.plotAngle, radius: r, center: center)
        let text = Text(item.glyph)
            .font(.custom("EnigmaAstrology3", size: fontSize))
            .foregroundColor(theme.planetGlyph)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

private func drawDialPlanetTexts(_ ctx: inout GraphicsContext, center: CGPoint,
                                  R: Double, data: WheelPlotData, theme: WheelTheme) {
    let r        = R * fPlanetText
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction, outerRadius: R)

    for item in data.planetItems {
        let pt   = WheelGeometry.point(angleDeg: item.plotAngle, radius: r, center: center)
        let text = Text(item.positionText)
            .font(.system(size: fontSize))
            .foregroundColor(theme.planetText)
        drawRotatedText(&ctx, text: text, at: pt, angle: item.plotAngle)
    }
}

// MARK: - Helpers

/// Draws text rotated radially at the given wheel angle.
private func drawRotatedText(_ ctx: inout GraphicsContext, text: Text,
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
        let resolved = layerCtx.resolve(text)
        layerCtx.draw(resolved, at: .zero, anchor: anchor)
    }
}
