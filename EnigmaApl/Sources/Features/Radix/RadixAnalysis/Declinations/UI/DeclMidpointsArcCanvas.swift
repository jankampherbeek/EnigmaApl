// DeclMidpointsArcCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
//
// Canvas for the declination midpoints arc diagram.
//
// The canvas shows a circle with the bottom 120° clipped away, leaving a 240° arc.
// Declination is mapped to visual angle: visualAngle = -declination * 4.
//   d = 0  → angle   0° (top, 12 o'clock)
//   d = +30 → angle 240° (bottom-left, north end)
//   d = -30 → angle 120° (bottom-right, south end)
//
// Layout from centre outward (same fractions as Dial90TypeWheelCanvas):
//   1. Planet area    (0 … fHalfDegInner)          — glyphs, centre cross, arrow
//   2. 0.5° ring      (fHalfDegInner … f1DegInner) — 120 ticks (±30° × 2 half-steps/degree)
//   3. 1° ring        (f1DegInner … fLabelInner)   — 60 uniform 1° ticks
//   4. Label ring     (fLabelInner … fLabelOuter)  — degree labels at ±5°, ±10°…±30°
//
// N (north) label at bottom-left, S (south) label at bottom-right.

import SwiftUI

// MARK: - Data model

/// A single factor plotted on the declination arc.
struct DeclMidpointsArcItem {
    let factor: Factors
    let glyph: String
    let declination: Double     // degrees, positive = north, negative = south
    /// Visual angle on the arc: normalise(-declination * 4.0)
    var visualAngle: Double
}

// MARK: - Layout constants (fraction of outer radius R)
// Namespaced to avoid collisions with same-named private constants in Dial*Canvas files.

enum ArcLayout {
    static let fLabelOuter:        Double = 0.99
    static let fLabelInner:        Double = 0.91
    static let f1DegInner:         Double = 0.87
    static let fHalfDegInner:      Double = 0.82
    static let fPlanetGlyph:       Double = 0.74
    static let fCrossArm:          Double = 0.035
    static let arcHalfAngle:       Double = 120.0  // hidden segment starts at ±this from top
    static let arcAspectRatio:     Double = 1.238
}

private let fTickHalfDeg:  Double = 0.012
private let fTickWholeDeg: Double = 0.030
private let fTick5Deg:     Double = 0.080

private let fDegLabel:     Double = 0.949

// MARK: - Canvas

struct DeclMidpointsArcCanvas: View {
    let items:      [DeclMidpointsArcItem]
    let northLabel: String   // localised "N"
    let southLabel: String   // localised "S"
    let theme:      WheelTheme

    var body: some View {
        Canvas { ctx, size in
            let geo    = ArcCanvasGeometry(size: size)
            let center = geo.center
            let R      = geo.R

            drawArcBackground   (&ctx, center: center, R: R, theme: theme)
            drawArcRingStrokes  (&ctx, center: center, R: R, theme: theme)
            drawArc1DegTicks    (&ctx, center: center, R: R, theme: theme)
            drawArcHalfDegTicks (&ctx, center: center, R: R, theme: theme)
            drawArcDegreeLabels (&ctx, center: center, R: R, theme: theme)
            drawArcCenterCross  (&ctx, center: center, R: R, theme: theme)
            drawArcArrow        (&ctx, center: center, R: R, theme: theme)
            drawArcConnectLines (&ctx, center: center, R: R, items: items, theme: theme)
            drawArcGlyphs       (&ctx, center: center, R: R, items: items, theme: theme)
            drawNSLabels        (&ctx, center: center, R: R,
                                 northLabel: northLabel, southLabel: southLabel, theme: theme)
        }
        .background(Color.white)
        .aspectRatio(ArcLayout.arcAspectRatio, contentMode: .fit)
    }
}

// MARK: - Geometry helper

/// Computes the circle center and outer radius from the canvas size.
/// The circle center is placed so the top of the arc is near the top of the canvas,
/// and the two arc endpoints (at ±120°) are just above the canvas bottom.
struct ArcCanvasGeometry {
    let center: CGPoint
    let R: Double

    init(size: CGSize) {
        let W = Double(size.width)
        // sin(120°) = √3/2 ≈ 0.8660; arc width = 2 * R * sin120
        let sin120 = sin(ArcLayout.arcHalfAngle * .pi / 180.0)
        let mSide  = W * 0.08
        R = (W - 2.0 * mSide) / (2.0 * sin120)
        let mTop = W * 0.04
        center = CGPoint(x: size.width / 2.0, y: CGFloat(mTop + R))
    }
}

// MARK: - Declination → visual angle

/// Maps declination (−30…+30) to visual angle on the arc (clockwise from top = 0).
private func visualAngle(_ decl: Double) -> Double {
    WheelGeometry.normalise(-decl * 4.0)
}

// MARK: - Background

private func drawArcBackground(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                theme: WheelTheme) {
    // Label ring (outer annulus): light blue background
    drawArcAnnulus(&ctx, center: center, outerR: R * ArcLayout.fLabelOuter, innerR: R * ArcLayout.fLabelInner,
                   color: theme.signRingBackground)
    // Inner disc
    drawArcDisc(&ctx, center: center, R: R * ArcLayout.fLabelInner, color: theme.outerCircleBackground)
}

private func drawArcDisc(_ ctx: inout GraphicsContext, center: CGPoint, R: Double, color: Color) {
    ctx.fill(arcPath(center: center, outerR: R, innerR: 0), with: .color(color))
}

private func drawArcAnnulus(_ ctx: inout GraphicsContext, center: CGPoint,
                             outerR: Double, innerR: Double, color: Color) {
    ctx.fill(arcPath(center: center, outerR: outerR, innerR: innerR), with: .color(color))
}

/// Builds a filled pie/annulus path for the visible 240° arc (south-right → top → north-left).
private func arcPath(center: CGPoint, outerR: Double, innerR: Double) -> Path {
    let outerPts = arcPoints(center: center, R: outerR)
    var path = Path()
    if innerR <= 0 {
        path.move(to: center)
        path.addLine(to: outerPts[0])
        for pt in outerPts.dropFirst() { path.addLine(to: pt) }
        path.addLine(to: center)
    } else {
        let innerPts = arcPoints(center: center, R: innerR)
        path.move(to: outerPts[0])
        for pt in outerPts.dropFirst() { path.addLine(to: pt) }
        for pt in innerPts.reversed() { path.addLine(to: pt) }
        path.closeSubpath()
    }
    return path
}

/// Returns 241 points along the visible arc, counter-clockwise from 120° (south-right)
/// through 0° (top) to 240° (north-left), at 1° resolution.
private func arcPoints(center: CGPoint, R: Double) -> [CGPoint] {
    return (0...240).map { i in
        let angle = WheelGeometry.normalise(ArcLayout.arcHalfAngle - Double(i))
        return WheelGeometry.point(angleDeg: angle, radius: R, center: center)
    }
}

// MARK: - Ring boundary strokes

private func drawArcRingStrokes(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                 theme: WheelTheme) {
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: R)
    for fraction in [ArcLayout.fLabelOuter, ArcLayout.fLabelInner, ArcLayout.f1DegInner, ArcLayout.fHalfDegInner] {
        strokeArcBoundary(&ctx, center: center, R: R * fraction, theme: theme, stroke: stroke)
    }
}

private func strokeArcBoundary(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                theme: WheelTheme, stroke: CGFloat) {
    let pts = arcPoints(center: center, R: R)
    var path = Path()
    if let first = pts.first {
        path.move(to: first)
        for pt in pts.dropFirst() { path.addLine(to: pt) }
    }
    ctx.stroke(path, with: .color(theme.circleStroke), lineWidth: stroke)
}

// MARK: - 1° ring: 60 ticks (one per declination degree, spanning the full 1° ring)

private func drawArc1DegTicks(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                               theme: WheelTheme) {
    let outerR = R * ArcLayout.fLabelInner
    let innerR = R * ArcLayout.f1DegInner
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 0.8, outerRadius: R)
    // Each declination degree: decl = -30…+30 → 61 positions
    for i in -30...30 {
        let decl  = Double(i)
        let angle = visualAngle(decl)
        let p1 = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        let p2 = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        var path = Path()
        path.move(to: p1)
        path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.degreeTickStroke), lineWidth: stroke)
    }
}

// MARK: - 0.5° ring: 120 ticks with variable lengths

private func drawArcHalfDegTicks(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                  theme: WheelTheme) {
    let outerR = R * ArcLayout.f1DegInner
    // half-degree steps: i from -60 to +60 (60 blocks × 2 half-steps)
    for i in -60...60 {
        let decl  = Double(i) * 0.5
        let angle = visualAngle(decl)
        let tickLen: Double
        if i % 10 == 0 {         // 5° boundary
            tickLen = fTick5Deg
        } else if i % 2 == 0 {  // 1° boundary
            tickLen = fTickWholeDeg
        } else {                 // 0.5° midpoint
            tickLen = fTickHalfDeg
        }
        let innerR = outerR - R * tickLen
        let p1 = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        let p2 = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        var path = Path()
        path.move(to: p1)
        path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.degreeTickStroke), lineWidth: 1.0)
    }
}

// MARK: - Degree labels: 0, ±5, ±10, ±15, ±20, ±25, ±30 in the label ring

private func drawArcDegreeLabels(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                  theme: WheelTheme) {
    let labelR   = R * fDegLabel
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction * 1.3, outerRadius: R)
    // Labels at every 5°
    let labelValues = stride(from: -30, through: 30, by: 5).map { Int($0) }
    for decl in labelValues {
        let angle = visualAngle(Double(decl))
        let pt    = WheelGeometry.point(angleDeg: angle, radius: labelR, center: center)
        let text  = Text("\(abs(decl))")
            .font(.system(size: fontSize, weight: .medium))
            .foregroundColor(theme.planetText)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - Centre cross

private func drawArcCenterCross(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                 theme: WheelTheme) {
    let arm    = CGFloat(R * ArcLayout.fCrossArm)
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

// MARK: - Arrow from cross to 0° (top)

private func drawArcArrow(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                           theme: WheelTheme) {
    let tailR  = R * ArcLayout.fCrossArm * 2.5     // just above the cross
    let tipR   = R * ArcLayout.fHalfDegInner - 2   // just inside the tick ring
    let tail   = WheelGeometry.point(angleDeg: 0, radius: tailR,  center: center)
    let tip    = WheelGeometry.point(angleDeg: 0, radius: tipR, center: center)
    let stroke = max(2.0, CGFloat(R * 0.012))

    // Shaft
    var shaft = Path()
    shaft.move(to: tail)
    shaft.addLine(to: tip)
    ctx.stroke(shaft, with: .color(theme.circleStroke), lineWidth: stroke)

    // Arrowhead: two wing points perpendicular to the direction (0° points upward = negative y)
    let wingSize = R * 0.04
    let wingLeft  = CGPoint(x: tip.x - CGFloat(wingSize), y: tip.y + CGFloat(wingSize))
    let wingRight = CGPoint(x: tip.x + CGFloat(wingSize), y: tip.y + CGFloat(wingSize))
    var head = Path()
    head.move(to: tip)
    head.addLine(to: wingLeft)
    head.move(to: tip)
    head.addLine(to: wingRight)
    ctx.stroke(head, with: .color(theme.circleStroke), lineWidth: stroke)
}

// MARK: - Connect lines (glyph to tick ring)

private func drawArcConnectLines(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                                  items: [DeclMidpointsArcItem], theme: WheelTheme) {
    let glyphR = R * ArcLayout.fPlanetGlyph
    let ringR  = R * ArcLayout.fHalfDegInner
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.connectLineFraction, outerRadius: R)
    for item in items {
        let p1 = WheelGeometry.point(angleDeg: item.visualAngle, radius: glyphR, center: center)
        let p2 = WheelGeometry.point(angleDeg: visualAngle(item.declination), radius: ringR, center: center)
        var path = Path()
        path.move(to: p1)
        path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.planetConnectLine.opacity(WheelMetrics.connectLineOpacity)),
                   lineWidth: stroke)
    }
}

// MARK: - Planet glyphs

private func drawArcGlyphs(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                             items: [DeclMidpointsArcItem], theme: WheelTheme) {
    let r        = R * ArcLayout.fPlanetGlyph
    let fontSize = WheelMetrics.fontSize(WheelMetrics.planetGlyphFontFraction, outerRadius: R)
    for item in items {
        let pt   = WheelGeometry.point(angleDeg: item.visualAngle, radius: r, center: center)
        let text = Text(item.glyph)
            .font(.custom("EnigmaAstrology2", size: fontSize))
            .foregroundColor(theme.planetGlyph)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - N / S labels

private func drawNSLabels(_ ctx: inout GraphicsContext, center: CGPoint, R: Double,
                           northLabel: String, southLabel: String, theme: WheelTheme) {
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction * 6.0, outerRadius: R)
    let font     = Font.system(size: fontSize, weight: .bold)
    let color    = theme.planetText.opacity(0.25)

    // North label: placed at the left arc endpoint (angle 120° = bottom-left in screen coords)
    // sin(120°) ≈ +0.866 → x = cx - 0.866*R → left side
    let northPt = WheelGeometry.point(angleDeg: 120.0, radius: R * ArcLayout.fPlanetGlyph * 0.65,
                                      center: center)
    ctx.draw(Text(northLabel).font(font).foregroundColor(color),
             at: northPt, anchor: .center)

    // South label: placed at the right arc endpoint (angle 240° = bottom-right in screen coords)
    // sin(240°) ≈ -0.866 → x = cx + 0.866*R → right side
    let southPt = WheelGeometry.point(angleDeg: 240.0, radius: R * ArcLayout.fPlanetGlyph * 0.65,
                                      center: center)
    ctx.draw(Text(southLabel).font(font).foregroundColor(color),
             at: southPt, anchor: .center)
}
