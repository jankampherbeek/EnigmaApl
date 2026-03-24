// DrawSigns.swift
// EnigmaApl

import SwiftUI

/// Offset in degrees from the ascendant to the first sign boundary (CCW).
func signOffsetAsc(_ ascLong: Double) -> Double {
    30.0 - ascLong.truncatingRemainder(dividingBy: 30.0)
}

func drawElementSectors(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                         ascLong: Double, theme: WheelTheme = .color) {
    let innerR = outerRadius * WheelMetrics.outerHouse
    let outerR = outerRadius * WheelMetrics.outerSign
    let offset = signOffsetAsc(ascLong)
    let ascSignIndex = Int(ascLong / 30.0)

    for i in 0..<12 {
        let startAngle = Double(i) * 30.0 + offset + 90.0
        let endAngle   = startAngle + 30.0
        let signIndex  = (ascSignIndex + 1 + i) % 12
        let sign       = Signs(rawValue: signIndex + 1) ?? .Aries
        let color      = theme.signSectorColor(for: sign)
        let path = annularSectorPath(from: startAngle, to: endAngle, inner: innerR, outer: outerR, center: center)
        ctx.fill(path, with: .color(color))
    }
}

func drawSignSeparators(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                         ascLong: Double, theme: WheelTheme = .color) {
    let innerR = outerRadius * WheelMetrics.outerHouse
    let outerR = outerRadius * WheelMetrics.outerSign
    let offset = signOffsetAsc(ascLong)
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: outerRadius)

    for i in 0..<12 {
        let angle = Double(i) * 30.0 + offset + 90.0
        let p1 = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        let p2 = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.signSeparator), lineWidth: stroke)
    }
}

func drawSignGlyphs(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                     ascLong: Double, theme: WheelTheme = .color) {
    let glyphRadius = outerRadius * WheelMetrics.signGlyph
    let fontSize = WheelMetrics.fontSize(WheelMetrics.signGlyphFontFraction, outerRadius: outerRadius)
    let offset = signOffsetAsc(ascLong)
    let ascSignIndex = Int(ascLong / 30.0)

    for i in 0..<12 {
        let midAngle = Double(i) * 30.0 + offset + 90.0 + 15.0
        let pt = WheelGeometry.point(angleDeg: midAngle, radius: glyphRadius, center: center)
        let signIndex = (ascSignIndex + 1 + i) % 12
        guard let sign = Signs(rawValue: signIndex + 1) else { continue }
        let glyph = GlyphSelector.getGlyphForSign(sign)
        let text = Text(glyph)
            .font(.custom("EnigmaAstrology2", size: fontSize))
            .foregroundColor(theme.signGlyph)
        let resolved = ctx.resolve(text)
        ctx.draw(resolved, at: pt, anchor: .center)
    }
}

func drawDegreeLines(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                      ascLong: Double, theme: WheelTheme = .color) {
    let startR = outerRadius * WheelMetrics.outerHouse
    let shortR = outerRadius * WheelMetrics.degrees
    let longR  = outerRadius * WheelMetrics.degrees5
    let offset = signOffsetAsc(ascLong)
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

// MARK: - Geometry helper

/// Path for an annular sector between two radii and two angles (wheel convention).
func annularSectorPath(from startAngle: Double, to endAngle: Double,
                       inner innerR: Double, outer outerR: Double,
                       center: CGPoint) -> Path {
    let steps = 10
    var path = Path()

    for i in 0...steps {
        let frac  = Double(i) / Double(steps)
        let angle = startAngle + (endAngle - startAngle) * frac
        let pt    = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
    }
    for i in 0...steps {
        let frac  = Double(steps - i) / Double(steps)
        let angle = startAngle + (endAngle - startAngle) * frac
        let pt    = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        path.addLine(to: pt)
    }
    path.closeSubpath()
    return path
}
