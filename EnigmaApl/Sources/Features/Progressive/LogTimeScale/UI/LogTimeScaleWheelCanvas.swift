// LogTimeScaleWheelCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct LtsWheelMark {
    let label: String
    let mundaneAngle: Double
    let isMonth: Bool
}

/// Draws the radix chart with either:
/// - a single inward-pointing arrow (Positions for Event mode), or
/// - tick marks with labels in the outer ring for each month and age (Overview mode).
struct LogTimeScaleWheelCanvas: View {
    let radixData: WheelPlotData
    /// Mundane angle (0–360) of the calculated LogTimeScale position, or nil when unavailable.
    let ltsMundaneAngle: Double?
    /// Ecliptic longitude of the position, used to label the arrow. Must be non-nil when ltsMundaneAngle is non-nil.
    let ltsLongitude: Double?
    /// Overview tick marks. When set, draws marks instead of an arrow.
    let overviewItems: [LtsWheelMark]?
    let theme: WheelTheme
    let showAspects: Bool
    /// Drawing type of the radix wheel; see `WheelAngleMapper.specialisedType`.
    var drawingType: DrawingType = .signBased

    /// Radix wheel radius as a fraction of the full radius; see `InnerWheelLayout`.
    private var radixScale: Double { 0.78 * InnerWheelLayout.scaleFactor(drawingType) }
    private let outerFraction: Double = 0.864   // outer edge of transit ring background

    /// Angle on this wheel for a sign-based (mundane) angle.
    private func mapped(_ angle: Double) -> Double {
        InnerWheelLayout.angle(fromMundane: angle, data: radixData, drawingType: drawingType)
    }

    private func mapped(_ mark: LtsWheelMark) -> LtsWheelMark {
        LtsWheelMark(label: mark.label, mundaneAngle: mapped(mark.mundaneAngle), isMonth: mark.isMonth)
    }

    var body: some View {
        Canvas { ctx, size in
            let fullRadius  = Double(min(size.width, size.height)) / 2.0
            let innerRadius = fullRadius * radixScale
            let center      = CGPoint(x: size.width / 2, y: size.height / 2)

            let contentR    = innerRadius * InnerWheelLayout.contentFraction(drawingType)
            let ringStartR  = innerRadius * InnerWheelLayout.ringStartFraction(drawingType)

            // Outer ring background, then the radix wheel on top of it
            InnerWheelLayout.drawRingBackground(&ctx, drawingType: drawingType, center: center,
                                                radius: fullRadius * outerFraction, theme: theme)
            InnerWheelLayout.drawRadixWheel(&ctx, drawingType: drawingType, center: center,
                                            outerRadius: innerRadius, data: radixData, theme: theme,
                                            showAspects: showAspects)
            InnerWheelLayout.drawBoundaryIfNeeded(&ctx, drawingType: drawingType, center: center,
                                                  radius: contentR, fullRadius: fullRadius, theme: theme)

            if let items = overviewItems {
                drawOverviewMarks(&ctx, center: center, fullRadius: fullRadius, innerRadius: innerRadius,
                    contentR: contentR, ringStartR: ringStartR,
                    items: items.map(mapped), theme: theme)
            } else if let angle = ltsMundaneAngle, let longitude = ltsLongitude {
                drawLogTimeScaleArrow(&ctx, center: center, fullRadius: fullRadius,
                    innerRadius: innerRadius, contentR: contentR, mundaneAngle: mapped(angle),
                                      longitude: longitude, theme: theme)
            }
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Arrow drawing (Positions for Event)

private func drawLogTimeScaleArrow(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    fullRadius: Double,
    innerRadius: Double,
    contentR: Double,
    mundaneAngle: Double,
    longitude: Double,
    theme: WheelTheme
) {
    let color   = theme.planetGlyph
    let strokeW = WheelMetrics.strokeWidth(WheelMetrics.connectLineFraction * 3, outerRadius: fullRadius)

    // Shaft: from mid-transit-ring down to the outer circle of the zodiac ring.
    let tailR = fullRadius * 0.86
    let tipR  = contentR   // outer edge of the radix content
    let tail  = WheelGeometry.point(angleDeg: mundaneAngle, radius: tailR, center: center)
    let tip   = WheelGeometry.point(angleDeg: mundaneAngle, radius: tipR,  center: center)

    var shaft = Path()
    shaft.move(to: tail)
    shaft.addLine(to: tip)
    ctx.stroke(shaft, with: .color(color), lineWidth: strokeW)

    // Arrowhead: filled triangle with its apex (tip) pointing toward the center,
    // base wings spread outward at ±4° from the mundane angle.
    let headSize   = innerRadius * 0.02
    let headSpread = 4.0
    let wingL = WheelGeometry.point(angleDeg: mundaneAngle + headSpread, radius: tipR + headSize, center: center)
    let wingR = WheelGeometry.point(angleDeg: mundaneAngle - headSpread, radius: tipR + headSize, center: center)

    var head = Path()
    head.move(to: tip)
    head.addLine(to: wingL)
    head.addLine(to: wingR)
    head.closeSubpath()
    ctx.fill(head, with: .color(color))

    // Label alongside the shaft
    drawArrowLabel(&ctx, center: center, innerRadius: innerRadius,
                   tailR: tailR, tipR: tipR, mundaneAngle: mundaneAngle,
                   longitude: longitude, theme: theme)
}

private func drawArrowLabel(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    innerRadius: Double,
    tailR: Double,
    tipR: Double,
    mundaneAngle: Double,
    longitude: Double,
    theme: WheelTheme
) {
    let (dmsString, sign, valid) = PositionInDegreesConversion.DoubleToDmsSign(longitude)
    guard valid, let sign else { return }

    let fontSize  = WheelMetrics.fontSize(WheelMetrics.positionTextFraction * 1.1, outerRadius: innerRadius)
    let glyphSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction * 1.4, outerRadius: innerRadius)
    let midR      = (tailR + tipR) / 2.0 + innerRadius * 0.04

    // Mid-shaft point, then offset perpendicular to the arrow (tangential direction).
    let a_rad     = mundaneAngle * Double.pi / 180.0
    let perpDist  = innerRadius * 0.04
    let midPoint  = WheelGeometry.point(angleDeg: mundaneAngle, radius: midR, center: center)
    let textPoint = CGPoint(
        x: midPoint.x - CGFloat(cos(a_rad) * perpDist),
        y: midPoint.y + CGFloat(sin(a_rad) * perpDist)
    )

    // Rotate text to read along the shaft; flip for the left half to keep it right-side up.
    let rotDeg = mundaneAngle <= 180.0 ? (90.0 - mundaneAngle) : (270.0 - mundaneAngle)

    let label = Text(dmsString + " ").font(.system(size: fontSize)).foregroundColor(Color(theme.planetGlyph))
              + Text(GlyphSelector.getGlyphForSign(sign))
                    .font(.custom("EnigmaAstrology3", size: glyphSize))
                    .foregroundColor(Color(theme.planetGlyph))

    var labelCtx = ctx
    labelCtx.translateBy(x: textPoint.x, y: textPoint.y)
    labelCtx.rotate(by: .degrees(rotDeg))
    labelCtx.draw(label, at: .zero, anchor: .center)
}

// MARK: - Overview tick marks

private func drawOverviewMarks(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    fullRadius: Double,
    innerRadius: Double,
    contentR: Double,
    ringStartR: Double,
    items: [LtsWheelMark],
    theme: WheelTheme
) {
    let ringOuter  = fullRadius * 0.864
    let ringWidth  = ringOuter - ringStartR
    // Ticks run from the outer zodiac ring stroke (outerSign) upward through the blank
    // degree-ring gap into the transit ring. Labels sit clearly inside the transit ring.
    let zodiacOutR = contentR
    // Gap between the radix content and the ring; at least the sign-based gap so ticks stay visible.
    let degreeH    = max(ringStartR - zodiacOutR, innerRadius * (1.0 - WheelMetrics.outerSign))
    let monthTickH = degreeH * 0.25
    let yearTickH  = degreeH * 0.5
    let labelR     = ringStartR + ringWidth * 0.4
    let fontSize   = WheelMetrics.fontSize(WheelMetrics.positionTextFraction * 0.85, outerRadius: innerRadius)

    for item in items {
        let tickLen  = item.isMonth ? monthTickH : yearTickH
        let tickInR  = zodiacOutR
        let tickOutR = zodiacOutR + tickLen

        let innerPt = WheelGeometry.point(angleDeg: item.mundaneAngle, radius: tickInR,  center: center)
        let outerPt = WheelGeometry.point(angleDeg: item.mundaneAngle, radius: tickOutR, center: center)

        var tick = Path()
        tick.move(to: innerPt)
        tick.addLine(to: outerPt)
        ctx.stroke(tick, with: .color(theme.planetGlyph), lineWidth: 1.0)

        // Label in the transit ring — well above innerRadius so it never overlaps radix content.
        let labelPt = WheelGeometry.point(angleDeg: item.mundaneAngle, radius: labelR, center: center)
        let rotDeg  = item.mundaneAngle <= 180.0 ? (90.0 - item.mundaneAngle) : (270.0 - item.mundaneAngle)

        var labelCtx = ctx
        labelCtx.translateBy(x: labelPt.x, y: labelPt.y)
        labelCtx.rotate(by: .degrees(rotDeg))
        labelCtx.draw(
            Text(item.label).font(.system(size: fontSize)).foregroundColor(Color(theme.planetGlyph)),
            at: .zero,
            anchor: .center
        )
    }
}
