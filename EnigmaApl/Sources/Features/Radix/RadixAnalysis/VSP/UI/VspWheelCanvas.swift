// VspWheelCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

// MARK: - Data

/// A single VSP position projected onto the chart wheel.
struct VspWheelItem {
    let sequenceId:   Int
    let mundaneAngle: Double   // position on the wheel (0° = top, CW)
    let dmsText:      String   // "deg°min'" within sign
    var isHead: Bool { sequenceId == 3 }
}

// MARK: - Canvas

/// Full horoscope wheel (no aspects) with Venus Star Point overlay.
/// The wheel is rotated to a custom anchor (VSP Head at 12 o'clock), so
/// ASC/DSC/MC/IC must be drawn from their original ecliptic longitudes — not
/// from the hardcoded 90°/270° that the standard cardinal helpers use.
struct VspWheelCanvas: View {
    let plotData:             WheelPlotData
    let vspItems:             [VspWheelItem]
    let theme:                WheelTheme
    /// Ecliptic longitude of the real Ascendant, before the VSP rotation was applied.
    let originalAscLongitude: Double

    var body: some View {
        Canvas { ctx, size in
            let outerRadius = Double(min(size.width, size.height)) / 2.0
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let asc = plotData.ascendantLongitude   // this is the VSP anchor

            // Standard wheel layers (no aspect lines)
            drawCircles(&ctx, center: center, outerRadius: outerRadius, theme: theme)
            drawElementSectors(&ctx, center: center, outerRadius: outerRadius, ascLong: asc, theme: theme)
            drawSignSeparators(&ctx, center: center, outerRadius: outerRadius, ascLong: asc, theme: theme)
            drawSignGlyphs(&ctx, center: center, outerRadius: outerRadius, ascLong: asc, theme: theme)
            drawDegreeLines(&ctx, center: center, outerRadius: outerRadius, ascLong: asc, theme: theme)
            if plotData.hasTime {
                drawCuspLines(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
                // Use custom cardinal drawing so ASC/DSC follow their real zodiacal position
                drawVspCardinalLines(&ctx, center: center, outerRadius: outerRadius,
                                     data: plotData, originalAscLong: originalAscLongitude, theme: theme)
                drawVspCardinalLabels(&ctx, center: center, outerRadius: outerRadius,
                                      data: plotData, originalAscLong: originalAscLongitude, theme: theme)
                drawCuspTexts(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            }
            drawPlanetConnectLines(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            drawPlanetGlyphs(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            drawPlanetTexts(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)

            // VSP overlay
            if vspItems.count >= 5 {
                drawVspLines(&ctx, center: center, outerRadius: outerRadius, items: vspItems, theme: theme)
                drawVspPoints(&ctx, center: center, outerRadius: outerRadius, items: vspItems, theme: theme)
            }
            // House numbers on top of VSP circles
            if plotData.hasTime {
                drawHouseNumbers(&ctx, center: center, outerRadius: outerRadius, data: plotData, theme: theme)
            }
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Cardinal lines/labels (VSP-aware)

/// Replaces drawCardinalLines: computes ASC/DSC from the real ASC longitude
/// so they track their zodiacal position after the VSP rotation.
private func drawVspCardinalLines(_ ctx: inout GraphicsContext,
                                   center: CGPoint, outerRadius: Double,
                                   data: WheelPlotData, originalAscLong: Double,
                                   theme: WheelTheme) {
    let innerR  = outerRadius * WheelMetrics.outerSign
    let outerR  = outerRadius * WheelMetrics.outerCircle
    let thick   = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 2.0, outerRadius: outerRadius)
    let anchor  = data.ascendantLongitude   // VSP anchor

    let ascAngle = WheelGeometry.mundaneAngle(longitude: originalAscLong, ascendantLongitude: anchor)
    let dscAngle = WheelGeometry.normalise(ascAngle + 180.0)
    let mcAngle  = WheelGeometry.mundaneAngle(longitude: data.mcLongitude, ascendantLongitude: anchor)
    let icAngle  = WheelGeometry.normalise(mcAngle + 180.0)

    for angle in [ascAngle, dscAngle, mcAngle, icAngle] {
        let p1 = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        let p2 = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.cuspLine.opacity(WheelMetrics.cuspLineOpacity)), lineWidth: thick)
    }
}

/// Replaces drawCardinalLabels: same angle computation as above.
private func drawVspCardinalLabels(_ ctx: inout GraphicsContext,
                                    center: CGPoint, outerRadius: Double,
                                    data: WheelPlotData, originalAscLong: Double,
                                    theme: WheelTheme) {
    let r        = outerRadius * WheelMetrics.cardinalIndicator
    let fontSize = WheelMetrics.fontSize(WheelMetrics.cardinalFontFraction, outerRadius: outerRadius)
    let anchor   = data.ascendantLongitude

    let ascAngle = WheelGeometry.mundaneAngle(longitude: originalAscLong, ascendantLongitude: anchor)
    let mcAngle  = WheelGeometry.mundaneAngle(longitude: data.mcLongitude, ascendantLongitude: anchor)

    let labels: [(String, Double)] = [
        ("A", ascAngle),
        ("D", WheelGeometry.normalise(ascAngle + 180.0)),
        ("M", mcAngle),
        ("I", WheelGeometry.normalise(mcAngle + 180.0)),
    ]
    for (label, angle) in labels {
        let pt = WheelGeometry.point(angleDeg: angle, radius: r, center: center)
        let text = Text(label)
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(theme.cardinalIndicator)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - House numbers (Roman numerals)

private func drawHouseNumbers(_ ctx: inout GraphicsContext,
                               center: CGPoint, outerRadius: Double,
                               data: WheelPlotData, theme: WheelTheme) {
    guard data.cuspLongitudes.count >= 12 else { return }

    let r        = outerRadius * 0.40      // just inside the inner circle (0.44)
    let fontSize = WheelMetrics.fontSize(0.034, outerRadius: outerRadius)
    let anchor   = data.ascendantLongitude

    let roman = ["I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII"]

    for i in 0..<12 {
        let startLong = data.cuspLongitudes[i]
        let endLong   = data.cuspLongitudes[(i + 1) % 12]

        // Midpoint longitude — handle 0°/360° wraparound
        var span = endLong - startLong
        if span <= 0 { span += 360 }
        var midLong = (startLong + span / 2).truncatingRemainder(dividingBy: 360)
        if midLong < 0 { midLong += 360 }

        let angle = WheelGeometry.mundaneAngle(longitude: midLong, ascendantLongitude: anchor)
        let pt    = WheelGeometry.point(angleDeg: angle, radius: r, center: center)

        let text = Text(roman[i])
            .font(.system(size: fontSize, weight: .light))
            .foregroundColor(theme.cuspText)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - VSP pentagram lines

private func drawVspLines(_ ctx: inout GraphicsContext,
                           center: CGPoint, outerRadius: Double,
                           items: [VspWheelItem], theme: WheelTheme) {
    let r     = outerRadius * WheelMetrics.vsp
    let lw    = CGFloat(outerRadius * 0.013)
    let color = theme.isBlackWhite
        ? Color.gray.opacity(0.6)
        : Color(red: 0.68, green: 0.85, blue: 0.90).opacity(0.85)

    // Star order 1→3→5→2→4→1, 0-based indices [0,2,4,1,3,0]
    let order = [0, 2, 4, 1, 3, 0]
    var path  = Path()
    path.move(to: WheelGeometry.point(angleDeg: items[order[0]].mundaneAngle, radius: r, center: center))
    for i in 1..<order.count {
        path.addLine(to: WheelGeometry.point(angleDeg: items[order[i]].mundaneAngle, radius: r, center: center))
    }
    ctx.stroke(path, with: .color(color), lineWidth: lw)
}

// MARK: - VSP point circles

private func drawVspPoints(_ ctx: inout GraphicsContext,
                            center: CGPoint, outerRadius: Double,
                            items: [VspWheelItem], theme: WheelTheme) {
    let r       = outerRadius * WheelMetrics.vsp
    let circleR = outerRadius * 0.045
    let numFS   = CGFloat(outerRadius * 0.038)
    let bw      = theme.isBlackWhite

    for item in items {
        let pt = WheelGeometry.point(angleDeg: item.mundaneAngle, radius: r, center: center)

        let fillColor: Color = bw
            ? Color.gray.opacity(0.4)
            : (item.isHead
                ? Color(red: 1.0, green: 0.6,  blue: 0.6)
                : Color(red: 0.68, green: 0.85, blue: 0.90))

        let d    = circleR * 2
        let rect = CGRect(x: pt.x - circleR, y: pt.y - circleR, width: d, height: d)
        ctx.fill(Path(ellipseIn: rect), with: .color(fillColor))

        let numColor: Color = bw ? .primary : (item.isHead ? .blue : .red)
        let numText = Text("\(item.sequenceId)")
            .font(.system(size: numFS, weight: .bold, design: .rounded))
            .foregroundColor(numColor)
        ctx.draw(ctx.resolve(numText), at: pt, anchor: .center)
    }
}
