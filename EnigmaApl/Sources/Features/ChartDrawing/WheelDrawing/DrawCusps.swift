// DrawCusps.swift
// EnigmaApl

import SwiftUI

func drawCuspLines(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double, data: WheelPlotData, theme: WheelTheme = .color) {
    let innerR  = outerRadius * WheelMetrics.outerAspect
    let outerR  = outerRadius * WheelMetrics.outerHouse
    let thin    = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction,       outerRadius: outerRadius)
    let thick   = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 2.0, outerRadius: outerRadius)
    let ascLong = data.ascendantLongitude

    for (i, cuspLong) in data.cuspLongitudes.enumerated() {
        let angle     = WheelGeometry.mundaneAngle(longitude: cuspLong, ascendantLongitude: ascLong)
        let lineWidth = (i % 3 == 0) ? thick : thin
        let p1 = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        let p2 = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.cuspLine.opacity(WheelMetrics.cuspLineOpacity)), lineWidth: lineWidth)
    }
}

func drawCardinalLines(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double, data: WheelPlotData, theme: WheelTheme = .color) {
    let innerR  = outerRadius * WheelMetrics.outerSign
    let outerR  = outerRadius * WheelMetrics.outerCircle
    let thick   = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 2.0, outerRadius: outerRadius)
    let ascLong = data.ascendantLongitude

    let ascAngle = 90.0
    let dscAngle = 270.0
    let mcAngle  = WheelGeometry.mundaneAngle(longitude: data.mcLongitude, ascendantLongitude: ascLong)
    let icAngle  = WheelGeometry.normalise(mcAngle + 180.0)

    for angle in [ascAngle, dscAngle, mcAngle, icAngle] {
        let p1 = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        let p2 = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.cuspLine.opacity(WheelMetrics.cuspLineOpacity)), lineWidth: thick)
    }
}

func drawCardinalLabels(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                         data: WheelPlotData, theme: WheelTheme = .color) {
    let r        = outerRadius * WheelMetrics.cardinalIndicator
    let fontSize = WheelMetrics.fontSize(WheelMetrics.cardinalFontFraction, outerRadius: outerRadius)
    let ascLong  = data.ascendantLongitude
    let mcAngle  = WheelGeometry.mundaneAngle(longitude: data.mcLongitude, ascendantLongitude: ascLong)

    let labels: [(String, Double)] = [
        ("A", 90.0),
        ("D", 270.0),
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

func drawCuspTexts(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                    data: WheelPlotData, theme: WheelTheme = .color) {
    let r        = outerRadius * WheelMetrics.cuspText
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction, outerRadius: outerRadius)
    let ascLong  = data.ascendantLongitude

    for cuspLong in data.cuspLongitudes {
        let angle  = WheelGeometry.mundaneAngle(longitude: cuspLong, ascendantLongitude: ascLong)
        let pt     = WheelGeometry.point(angleDeg: angle, radius: r, center: center)
        let rotDeg = cuspTextRotation(angle: angle)
        let text   = cuspPositionText(longitude: cuspLong)
        let styledText = Text(text)
            .font(.system(size: fontSize))
            .foregroundColor(theme.cuspText)

        ctx.drawLayer { layerCtx in
            layerCtx.translateBy(x: pt.x, y: pt.y)
            layerCtx.rotate(by: .degrees(rotDeg))
            let resolved = layerCtx.resolve(styledText)
            layerCtx.draw(resolved, at: .zero, anchor: .center)
        }
    }
}

// MARK: - Helpers

/// Rotation angle (degrees CW) so the cusp text reads along the cusp line.
func cuspTextRotation(angle: Double) -> Double {
    if angle <= 90.0 || angle > 270.0 {
        let r = angle - 90.0
        return 180.0 + (90.0 - r)
    } else {
        let r = angle - 270.0
        return 180.0 + (90.0 - r)
    }
}

/// "deg°min'" within the sign (e.g. "15°23'").
func cuspPositionText(longitude: Double) -> String {
    let inSign = longitude.truncatingRemainder(dividingBy: 30.0)
    let total  = Int(abs(inSign) * 60)
    return "\(total / 60)°\(String(format: "%02d", total % 60))'"
}
