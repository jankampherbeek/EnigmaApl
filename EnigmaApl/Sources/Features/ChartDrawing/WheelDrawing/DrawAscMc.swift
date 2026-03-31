// DrawAscMc.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// Draws a cardinal indicator line for a single ecliptic longitude on a zodiac wheel
/// where 0° Aries is fixed at the left (ascendantLongitude = 0).
private func drawCardinalLine(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    outerRadius: Double,
    longitude: Double,
    theme: WheelTheme
) {
    let innerR = outerRadius * WheelMetrics.outerSign
    let outerR = outerRadius * WheelMetrics.outerCircle
    let thick  = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 2.0, outerRadius: outerRadius)
    let angle  = WheelGeometry.mundaneAngle(longitude: longitude, ascendantLongitude: 0)
    let p1 = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
    let p2 = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
    var path = Path()
    path.move(to: p1)
    path.addLine(to: p2)
    ctx.stroke(path, with: .color(theme.cuspLine.opacity(WheelMetrics.cuspLineOpacity)), lineWidth: thick)
}

/// Draws a cardinal label ("A" or "M") for a single ecliptic longitude on a zodiac wheel
/// where 0° Aries is fixed at the left (ascendantLongitude = 0).
private func drawCardinalLabel(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    outerRadius: Double,
    longitude: Double,
    label: String,
    theme: WheelTheme
) {
    let r        = outerRadius * WheelMetrics.cardinalIndicator
    let fontSize = WheelMetrics.fontSize(WheelMetrics.cardinalFontFraction, outerRadius: outerRadius)
    let angle    = WheelGeometry.mundaneAngle(longitude: longitude, ascendantLongitude: 0)
    let pt       = WheelGeometry.point(angleDeg: angle, radius: r, center: center)
    let text     = Text(label)
        .font(.system(size: fontSize, weight: .bold))
        .foregroundColor(theme.cardinalIndicator)
    ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
}

/// Draws indicator lines for the Ascendant and/or MC at their given ecliptic longitudes.
/// Pass `nil` for either to skip drawing it.
func drawAscMcLines(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    outerRadius: Double,
    ascLongitude: Double?,
    mcLongitude: Double?,
    theme: WheelTheme = .color
) {
    if let asc = ascLongitude {
        drawCardinalLine(&ctx, center: center, outerRadius: outerRadius, longitude: asc, theme: theme)
    }
    if let mc = mcLongitude {
        drawCardinalLine(&ctx, center: center, outerRadius: outerRadius, longitude: mc, theme: theme)
    }
}

/// Draws "A" and/or "M" labels for the Ascendant and MC at their given ecliptic longitudes.
/// Pass `nil` for either to skip drawing it.
func drawAscMcLabels(
    _ ctx: inout GraphicsContext,
    center: CGPoint,
    outerRadius: Double,
    ascLongitude: Double?,
    mcLongitude: Double?,
    theme: WheelTheme = .color
) {
    if let asc = ascLongitude {
        drawCardinalLabel(&ctx, center: center, outerRadius: outerRadius,
                          longitude: asc, label: "A", theme: theme)
    }
    if let mc = mcLongitude {
        drawCardinalLabel(&ctx, center: center, outerRadius: outerRadius,
                          longitude: mc, label: "M", theme: theme)
    }
}
