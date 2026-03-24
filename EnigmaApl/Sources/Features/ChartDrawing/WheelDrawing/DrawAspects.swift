// DrawAspects.swift
// EnigmaApl

import SwiftUI

func drawAspectLines(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double, data: WheelPlotData) {
    guard !data.aspectItems.isEmpty else { return }
    let r          = outerRadius * WheelMetrics.outerAspect
    let maxStroke  = WheelMetrics.strokeWidth(WheelMetrics.aspectLineFraction, outerRadius: outerRadius)
    let minStroke  = max(0.5, maxStroke * 0.15)

    for item in data.aspectItems {
        let p1        = WheelGeometry.point(angleDeg: item.angle1, radius: r, center: center)
        let p2        = WheelGeometry.point(angleDeg: item.angle2, radius: r, center: center)
        let lineWidth = minStroke + (maxStroke - minStroke) * CGFloat(item.exactness)
        var path = Path()
        path.move(to: p1)
        path.addLine(to: p2)
        ctx.stroke(path,
                   with: .color(item.color.opacity(WheelMetrics.aspectOpacity)),
                   lineWidth: lineWidth)
    }
}
