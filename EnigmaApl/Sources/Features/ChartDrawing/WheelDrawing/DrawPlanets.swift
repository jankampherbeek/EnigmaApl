// DrawPlanets.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

func drawPlanetConnectLines(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                             data: WheelPlotData, theme: WheelTheme = .color) {
    let outerR = outerRadius * WheelMetrics.outerConnection
    let innerR = outerRadius * WheelMetrics.outerAspect
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.connectLineFraction, outerRadius: outerRadius)

    for item in data.planetItems {
        let p1 = WheelGeometry.point(angleDeg: item.plotAngle,    radius: outerR, center: center)
        let p2 = WheelGeometry.point(angleDeg: item.mundaneAngle, radius: innerR, center: center)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path,
                   with: .color(theme.planetConnectLine.opacity(WheelMetrics.connectLineOpacity)),
                   lineWidth: stroke)
    }
}

func drawPlanetGlyphs(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                       data: WheelPlotData, theme: WheelTheme = .color) {
    let r        = outerRadius * WheelMetrics.planetGlyph
    let fontSize = WheelMetrics.fontSize(WheelMetrics.planetGlyphFontFraction, outerRadius: outerRadius)

    for item in data.planetItems {
        let pt   = WheelGeometry.point(angleDeg: item.plotAngle, radius: r, center: center)
        let text = Text(item.glyph)
            .font(.custom("EnigmaAstrology2", size: fontSize))
            .foregroundColor(theme.planetGlyph)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

func drawPlanetTexts(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double,
                      data: WheelPlotData, theme: WheelTheme = .color) {
    let r        = outerRadius * (WheelMetrics.planetGlyph + 0.06)
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction, outerRadius: outerRadius)

    for item in data.planetItems {
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
