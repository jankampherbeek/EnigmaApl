// DrawAscMc.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// Draws a cardinal indicator line for a single ecliptic longitude on a zodiac wheel
/// where `wheelAscLongitude` is placed at the left.
private func drawCardinalLine(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    outerRadius: Double,
    longitude: Double,
    wheelAscLongitude: Double,
    theme: WheelTheme
) {
    let innerR = outerRadius * WheelMetrics.outerSign
    let outerR = outerRadius * WheelMetrics.outerCircle
    let thick  = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 2.0, outerRadius: outerRadius)
    let angle  = WheelGeometry.mundaneAngle(longitude: longitude, ascendantLongitude: wheelAscLongitude)
    let p1 = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
    let p2 = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
    var path = Path()
    path.move(to: p1)
    path.addLine(to: p2)
    ctx.stroke(path, with: .color(theme.cuspLine.opacity(WheelMetrics.cuspLineOpacity)), lineWidth: thick)
}

/// Draws a cardinal label ("A" or "M") for a single ecliptic longitude on a zodiac wheel
/// where `wheelAscLongitude` is placed at the left.
private func drawCardinalLabel(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    outerRadius: Double,
    longitude: Double,
    label: String,
    wheelAscLongitude: Double,
    theme: WheelTheme
) {
    let r        = outerRadius * WheelMetrics.cardinalIndicator
    let fontSize = WheelMetrics.fontSize(WheelMetrics.cardinalFontFraction, outerRadius: outerRadius)
    let angle    = WheelGeometry.mundaneAngle(longitude: longitude, ascendantLongitude: wheelAscLongitude)
    let pt       = WheelGeometry.point(angleDeg: angle, radius: r, center: center)
    let text     = Text(label)
        .font(.system(size: fontSize, weight: .bold))
        .foregroundColor(theme.cardinalIndicator)
    ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
}

/// Draws indicator lines for the Ascendant and/or MC at their given ecliptic longitudes.
/// Pass `nil` for either to skip drawing it. `wheelAscLongitude` is the longitude placed at the left.
func drawAscMcLines(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    outerRadius: Double,
    ascLongitude: Double?,
    mcLongitude: Double?,
    wheelAscLongitude: Double = 0,
    theme: WheelTheme = .color
) {
    if let asc = ascLongitude {
        drawCardinalLine(&ctx, center: center, outerRadius: outerRadius, longitude: asc,
                         wheelAscLongitude: wheelAscLongitude, theme: theme)
    }
    if let mc = mcLongitude {
        drawCardinalLine(&ctx, center: center, outerRadius: outerRadius, longitude: mc,
                         wheelAscLongitude: wheelAscLongitude, theme: theme)
    }
}

/// Draws "A" and/or "M" labels for the Ascendant and MC at their given ecliptic longitudes.
/// Pass `nil` for either to skip drawing it. `wheelAscLongitude` is the longitude placed at the left.
func drawAscMcLabels(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    outerRadius: Double,
    ascLongitude: Double?,
    mcLongitude: Double?,
    wheelAscLongitude: Double = 0,
    theme: WheelTheme = .color
) {
    if let asc = ascLongitude {
        drawCardinalLabel(&ctx, center: center, outerRadius: outerRadius,
                          longitude: asc, label: "A",
                          wheelAscLongitude: wheelAscLongitude, theme: theme)
    }
    if let mc = mcLongitude {
        drawCardinalLabel(&ctx, center: center, outerRadius: outerRadius,
                          longitude: mc, label: "M",
                          wheelAscLongitude: wheelAscLongitude, theme: theme)
    }
}
