// DualWheelCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// Draws the radix chart as a wheel of the configured drawing type, with an outer ring for a
/// second set of positions (transits, progressions, directions, a synastry partner).
/// The radix wheel is scaled down so that its outermost elements stay inside the ring; the scale
/// depends on the drawing type. Ring positions are mapped with the same angle convention as the
/// radix wheel, so they line up with it. Connect lines reach down to the outer edge of the radix wheel.
struct DualWheelCanvas: View {
    /// Plot data for the radix chart, built with `ChartWheelPlotDataBuilder` for `drawingType`.
    let radixData: WheelPlotData
    /// Ring positions. Only `eclipticLongitude`, glyph and text are used; angles are recalculated.
    let transitItems: [WheelPlotItem]
    let theme: WheelTheme
    let showAspects: Bool
    var drawingType: DrawingType = .signBased
    /// Mundane angles (relative to the radix ascendant) of the transit/ring chart's own
    /// house cusps. Empty by default — only synastry comparisons pass these, since transits
    /// and progressions are read against the radix houses.
    var transitCuspAngles: [Double] = []
    /// Mundane angle (relative to the radix ascendant) of the ring chart's own Ascendant.
    /// Nil by default — only synastry comparisons show ring cardinal labels.
    var transitAscAngle: Double? = nil
    /// Mundane angle (relative to the radix ascendant) of the ring chart's own Midheaven.
    var transitMcAngle: Double? = nil

    // Transit ring fractions of full outerRadius
    private let transitBackgroundFraction: Double = 0.864 // outer edge of yellow fill (~1 char wider than before)
    private let transitGlyphFraction:      Double = 0.76  // just above the radix wheel
    private let transitTextFraction:       Double = 0.786 // ~1 char closer to glyph
    private let transitConnectStart:       Double = 0.73  // connect line start (just inside glyph, like radix pattern)
    private let transitCardinalFraction:   Double = 0.92  // A/D/M/I labels, beyond the ring background edge

    /// Radix wheel radius as a fraction of the full radius; see `InnerWheelLayout`.
    private var radixScale: Double { 0.78 * InnerWheelLayout.scaleFactor(drawingType) }

    private var isDial: Bool { WheelAngleMapper.isDial(drawingType) }

    /// Maps a sign-based (mundane) angle of the ring chart to the angle on this wheel.
    private func ringAngle(fromMundane angle: Double) -> Double {
        InnerWheelLayout.angle(fromMundane: angle, data: radixData, drawingType: drawingType)
    }

    private func mapped(_ longitude: Double) -> Double {
        WheelAngleMapper.angle(longitude: longitude, drawingType: drawingType,
                               ascendantLongitude: radixData.ascendantLongitude,
                               cuspLongitudes: radixData.cuspLongitudes)
    }

    /// Ring items with angles for this drawing type, with glyph overlap resolved again.
    private var ringItems: [WheelPlotItem] {
        let items = transitItems.map { item in
            let angle = mapped(item.eclipticLongitude)
            return WheelPlotItem(factor: item.factor, glyph: item.glyph,
                                 eclipticLongitude: item.eclipticLongitude,
                                 mundaneAngle: angle, plotAngle: angle,
                                 positionText: item.positionText, speedType: item.speedType)
        }
        return GlyphOverlapResolver.resolve(items)
    }

    var body: some View {
        let items      = ringItems
        // Dials have no houses, and the ring chart's opposite angles coincide on the 90° and 45° dials.
        let cuspAngles = isDial ? [] : transitCuspAngles.map { ringAngle(fromMundane: $0) }
        let ascAngle   = isDial ? nil : transitAscAngle.map { ringAngle(fromMundane: $0) }
        let mcAngle    = isDial ? nil : transitMcAngle.map { ringAngle(fromMundane: $0) }

        Canvas { ctx, size in
            let fullRadius  = Double(min(size.width, size.height)) / 2.0
            let innerRadius = fullRadius * radixScale
            let anchorR     = innerRadius * InnerWheelLayout.contentFraction(drawingType)
            let center      = CGPoint(x: size.width / 2, y: size.height / 2)

            // Background fill extends to transitBackgroundFraction; radix wheel
            // draws on top, leaving only the transit ring annulus in this colour.
            InnerWheelLayout.drawRingBackground(&ctx, drawingType: drawingType, center: center,
                                                radius: fullRadius * transitBackgroundFraction, theme: theme)

            // Radix wheel (scaled)
            InnerWheelLayout.drawRadixWheel(&ctx, drawingType: drawingType, center: center,
                                            outerRadius: innerRadius, data: radixData, theme: theme,
                                            showAspects: showAspects)
            InnerWheelLayout.drawBoundaryIfNeeded(&ctx, drawingType: drawingType, center: center,
                                                  radius: anchorR, fullRadius: fullRadius, theme: theme)

            // Transit ring: cusp lines (if any), connect lines to the radix wheel, then glyphs and texts
            drawDualWheelCuspLines(&ctx, center: center, fullRadius: fullRadius, innerR: anchorR,
                                    outerFraction: transitBackgroundFraction, cuspAngles: cuspAngles, theme: theme)
            if let ascAngle, let mcAngle {
                drawDualWheelCardinalLabels(&ctx, center: center, fullRadius: fullRadius,
                                             radiusFraction: transitCardinalFraction,
                                             ascAngle: ascAngle, mcAngle: mcAngle, theme: theme)
            }
            drawDualWheelConnectLines(&ctx, center: center, fullRadius: fullRadius, endR: anchorR,
                                      connectStart: transitConnectStart, items: items, theme: theme)
            drawDualWheelGlyphs(&ctx, center: center, fullRadius: fullRadius, innerRadius: innerRadius,
                                 glyphFraction: transitGlyphFraction, items: items, theme: theme)
            drawDualWheelTexts(&ctx, center: center, fullRadius: fullRadius, innerRadius: innerRadius,
                                textFraction: transitTextFraction, items: items, theme: theme)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Transit ring free functions

/// Draws the ring chart's own house cusp lines, from the outer edge of the radix wheel
/// out to the ring's background edge. Angular cusps (1/4/7/10) are drawn thicker,
/// matching the radix cusp line convention.
private func drawDualWheelCuspLines(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    fullRadius: Double,
    innerR: Double,
    outerFraction: Double,
    cuspAngles: [Double],
    theme: WheelTheme
) {
    guard !cuspAngles.isEmpty else { return }

    let outerR = fullRadius * outerFraction
    let thin   = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction,       outerRadius: fullRadius)
    let thick  = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 2.0, outerRadius: fullRadius)

    for (i, angle) in cuspAngles.enumerated() {
        let lineWidth = (i % 3 == 0) ? thick : thin
        let p1 = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        let p2 = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        var path = Path()
        path.move(to: p1)
        path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.cuspLine.opacity(WheelMetrics.cuspLineOpacity)), lineWidth: lineWidth)
    }
}

/// Draws the ring chart's own Ascendant/Descendant/Midheaven/Imum Coeli labels ("A", "D",
/// "M", "I"), matching the inner chart's cardinal label style.
private func drawDualWheelCardinalLabels(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    fullRadius: Double,
    radiusFraction: Double,
    ascAngle: Double,
    mcAngle: Double,
    theme: WheelTheme
) {
    let r        = fullRadius * radiusFraction
    let fontSize = WheelMetrics.fontSize(WheelMetrics.cardinalFontFraction, outerRadius: fullRadius)
    let dscAngle = WheelGeometry.normalise(ascAngle + 180.0)
    let icAngle  = WheelGeometry.normalise(mcAngle + 180.0)

    let labels: [(String, Double)] = [
        ("A", ascAngle),
        ("D", dscAngle),
        ("M", mcAngle),
        ("I", icAngle),
    ]
    for (label, angle) in labels {
        let pt = WheelGeometry.point(angleDeg: angle, radius: r, center: center)
        let text = Text(label)
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(theme.cardinalIndicator)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

/// Connect lines run from just inside the transit glyph (connectStart × fullRadius, plotAngle)
/// down to the outer edge of the radix wheel (endR, mundaneAngle).
private func drawDualWheelConnectLines(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    fullRadius: Double,
    endR: Double,
    connectStart: Double,
    items: [WheelPlotItem],
    theme: WheelTheme
) {
    let startR       = fullRadius * connectStart
    let stroke       = WheelMetrics.strokeWidth(WheelMetrics.connectLineFraction, outerRadius: fullRadius)

    for item in items {
        let p1 = WheelGeometry.point(angleDeg: item.plotAngle,    radius: startR,       center: center)
        let p2 = WheelGeometry.point(angleDeg: item.mundaneAngle, radius: endR,         center: center)
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
            .font(.custom("EnigmaAstrology3", size: fontSize))
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
