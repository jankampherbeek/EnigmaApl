// DrawCircles.swift
// EnigmaApl

import SwiftUI

func drawCircles(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                 theme: WheelTheme = .color) {
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: outerRadius)
    let layers: [(Double, Color, Bool)] = [
        (WheelMetrics.outerCircle, theme.outerCircleBackground,  false),
        (WheelMetrics.outerSign,   theme.signRingBackground,     true),
        (WheelMetrics.outerHouse,  theme.houseRingBackground,    true),
        (WheelMetrics.outerAspect, theme.aspectCircleBackground, true),
    ]
    for (fraction, fill, drawStroke) in layers {
        let r = CGFloat(outerRadius * fraction)
        let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        ctx.fill(Path(ellipseIn: rect), with: .color(fill))
        if drawStroke {
            ctx.stroke(Path(ellipseIn: rect), with: .color(theme.circleStroke), lineWidth: stroke)
        }
    }
}
