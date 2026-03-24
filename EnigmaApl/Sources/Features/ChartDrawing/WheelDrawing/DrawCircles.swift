// DrawCircles.swift
// EnigmaApl

import SwiftUI

func drawCircles(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double) {
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: outerRadius)
    let layers: [(Double, Color, Bool)] = [
        (WheelMetrics.outerCircle,  WheelColors.outerCircleBackground,  false),
        (WheelMetrics.outerSign,    WheelColors.signRingBackground,      true),
        (WheelMetrics.outerHouse,   WheelColors.houseRingBackground,     true),
        (WheelMetrics.outerAspect,  WheelColors.aspectCircleBackground,  true),
    ]
    for (fraction, fill, drawStroke) in layers {
        let r = CGFloat(outerRadius * fraction)
        let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        ctx.fill(Path(ellipseIn: rect), with: .color(fill))
        if drawStroke {
            ctx.stroke(Path(ellipseIn: rect), with: .color(WheelColors.circleStroke), lineWidth: stroke)
        }
    }
}
