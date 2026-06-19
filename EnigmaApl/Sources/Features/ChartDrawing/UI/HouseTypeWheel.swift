// HouseTypeWheel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct HouseTypeWheel: View {
    let chart: FullChart
    let chartVersion: UUID
    @Binding var blackWhite: Bool
    @Binding var hideTime:   Bool
    @Binding var showExport: Bool

    @StateObject private var model = HouseTypeWheelModel()
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private var activeConfig: UserConfiguration? { activeConfigs.first }

    private var currentTheme: WheelTheme { blackWhite ? .blackWhite : .color }

    private var effectiveData: WheelPlotData {
        guard hideTime else { return model.plotData }
        let d = model.plotData
        return WheelPlotData(
            ascendantLongitude: d.ascendantLongitude,
            mcLongitude:        d.mcLongitude,
            cuspLongitudes:     d.cuspLongitudes,
            planetItems:        d.planetItems,
            hasTime:            false,
            aspectItems:        []
        )
    }

    var body: some View {
        VStack(spacing: 4) {
            HouseTypeWheelCanvas(plotData: effectiveData, theme: currentTheme)

        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(
                wheelView: HouseTypeWheelCanvas(plotData: effectiveData, theme: currentTheme)
            )
        }
        .onAppear { model.update(from: chart, config: activeConfig) }
        .onChange(of: chartVersion) { model.update(from: chart, config: activeConfig) }
    }
}

// MARK: - HouseTypeWheelCanvas
// Lives in this file so it can access the private drawing functions below.

struct HouseTypeWheelCanvas: View {
    let plotData: WheelPlotData
    let theme: WheelTheme

    var body: some View {
        Canvas { ctx, size in
            let outerRadius = Double(min(size.width, size.height)) / 2.0
            let center      = CGPoint(x: size.width / 2, y: size.height / 2)
            let cusps       = plotData.cuspLongitudes

            drawHouseCircles(&ctx, center: center, outerRadius: outerRadius, theme: theme)
            if cusps.count >= 12 {
                drawHouseSignSectors(&ctx, center: center, outerRadius: outerRadius,
                                     cusps: cusps, theme: theme)
                drawHouseSignSeparators(&ctx, center: center, outerRadius: outerRadius,
                                        cusps: cusps, theme: theme)
                drawHouseSignGlyphs(&ctx, center: center, outerRadius: outerRadius,
                                    cusps: cusps, theme: theme)
            }
            if plotData.hasTime {
                drawHouseCuspLines(&ctx, center: center, outerRadius: outerRadius, theme: theme)
                drawHouseCuspPositionTexts(&ctx, center: center, outerRadius: outerRadius,
                                           data: plotData, theme: theme)
                drawHouseCardinalLabels(&ctx, center: center, outerRadius: outerRadius,
                                        data: plotData, theme: theme)
            }
            drawHousePlanetConnectLines(&ctx, center: center, outerRadius: outerRadius,
                                        data: plotData, theme: theme)
            drawHousePlanetGlyphs(&ctx, center: center, outerRadius: outerRadius,
                                  data: plotData, theme: theme)
            drawHousePlanetTexts(&ctx, center: center, outerRadius: outerRadius,
                                 data: plotData, theme: theme)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Circles

private func drawHouseCircles(_ ctx: inout GraphicsContext, center: CGPoint,
                               outerRadius: Double, theme: WheelTheme) {
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: outerRadius)
    let layers: [(Double, Color, Bool)] = [
        (WheelMetrics.outerCircle, theme.outerCircleBackground, false),
        (WheelMetrics.outerSign,   theme.signRingBackground,    true),
        (WheelMetrics.outerHouse,  theme.houseRingBackground,   true),
    ]
    for (fraction, fill, drawStroke) in layers {
        let r    = CGFloat(outerRadius * fraction)
        let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        ctx.fill(Path(ellipseIn: rect), with: .color(fill))
        if drawStroke {
            ctx.stroke(Path(ellipseIn: rect), with: .color(theme.circleStroke), lineWidth: stroke)
        }
    }
}

// MARK: - Sign sectors (proportional)

/// Returns 13 visual angles — one per sign boundary (longitude 0°, 30°, …, 330°)
/// plus a closing value equal to angles[0] + 360°.
/// The sequence is monotonically increasing.
private func houseSignBoundaryAngles(cusps: [Double]) -> [Double] {
    var angles: [Double] = []
    for i in 0..<12 {
        var angle = HouseWheelPlotDataBuilder.eclipticToHouseAngle(
            longitude: Double(i) * 30.0, cusps: cusps)
        if let prev = angles.last, angle <= prev {
            angle += 360.0
        }
        angles.append(angle)
    }
    angles.append(angles[0] + 360.0)
    return angles
}

private func drawHouseSignSectors(_ ctx: inout GraphicsContext, center: CGPoint,
                                   outerRadius: Double, cusps: [Double], theme: WheelTheme) {
    let innerR  = outerRadius * WheelMetrics.outerHouse
    let outerR  = outerRadius * WheelMetrics.outerSign
    let angles  = houseSignBoundaryAngles(cusps: cusps)

    for i in 0..<12 {
        let sign  = Signs(rawValue: i + 1) ?? .Aries
        let color = theme.signSectorColor(for: sign)
        let path  = annularSectorPath(from: angles[i], to: angles[i + 1],
                                      inner: innerR, outer: outerR, center: center)
        ctx.fill(path, with: .color(color))
    }
}

private func drawHouseSignSeparators(_ ctx: inout GraphicsContext, center: CGPoint,
                                      outerRadius: Double, cusps: [Double], theme: WheelTheme) {
    let innerR  = outerRadius * WheelMetrics.outerHouse
    let outerR  = outerRadius * WheelMetrics.outerSign
    let stroke  = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: outerRadius)
    let angles  = houseSignBoundaryAngles(cusps: cusps)

    for i in 0..<12 {
        let angle = angles[i]
        let p1    = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        let p2    = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        var path  = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(theme.signSeparator), lineWidth: stroke)
    }
}

private func drawHouseSignGlyphs(_ ctx: inout GraphicsContext, center: CGPoint,
                                  outerRadius: Double, cusps: [Double], theme: WheelTheme) {
    let glyphR   = outerRadius * WheelMetrics.signGlyph
    let fontSize = WheelMetrics.fontSize(WheelMetrics.signGlyphFontFraction, outerRadius: outerRadius)
    let angles   = houseSignBoundaryAngles(cusps: cusps)

    for i in 0..<12 {
        let midAngle = (angles[i] + angles[i + 1]) / 2.0
        let pt       = WheelGeometry.point(angleDeg: midAngle, radius: glyphR, center: center)
        guard let sign = Signs(rawValue: i + 1) else { continue }
        let glyph    = GlyphSelector.getGlyphForSign(sign)
        let text     = Text(glyph)
            .font(.custom("EnigmaAstrology3", size: fontSize))
            .foregroundColor(theme.signGlyph)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - House cusp lines (equal spacing, run to center — color unchanged in b/w mode)

private func drawHouseCuspLines(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double, theme: WheelTheme) {
    let outerR = outerRadius * WheelMetrics.outerHouse
    let thin   = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: outerRadius)
    let thick  = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 2.0, outerRadius: outerRadius)

    for i in 0..<12 {
        let angle = 90.0 + Double(i) * 30.0
        let lw    = (i % 3 == 0) ? thick : thin
        var path  = Path()
        path.move(to: center)
        path.addLine(to: WheelGeometry.point(angleDeg: angle, radius: outerR, center: center))
        ctx.stroke(path, with: .color(theme.cuspLine.opacity(WheelMetrics.cuspLineOpacity)),
                   lineWidth: lw)
    }
}

// MARK: - Cusp position texts (near center, on the cusp line)

private func drawHouseCuspPositionTexts(_ ctx: inout GraphicsContext, center: CGPoint,
                                         outerRadius: Double, data: WheelPlotData,
                                         theme: WheelTheme) {
    guard data.cuspLongitudes.count >= 12 else { return }
    let r        = outerRadius * 0.20
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction, outerRadius: outerRadius)

    for i in 0..<12 {
        let cuspLong = data.cuspLongitudes[i]
        let angle    = 90.0 + Double(i) * 30.0
        let pt       = WheelGeometry.point(angleDeg: angle, radius: r, center: center)
        let rotDeg   = cuspTextRotation(angle: angle)
        let label    = cuspPositionText(longitude: cuspLong)
        let text     = Text(label)
            .font(.system(size: fontSize))
            .foregroundColor(theme.cardinalIndicator)

        ctx.drawLayer { layerCtx in
            layerCtx.translateBy(x: pt.x, y: pt.y)
            layerCtx.rotate(by: .degrees(rotDeg))
            let resolved = layerCtx.resolve(text)
            layerCtx.draw(resolved, at: .zero, anchor: .center)
        }
    }
}

// MARK: - Cardinal labels (A / D / M / I at their actual visual positions)

private func drawHouseCardinalLabels(_ ctx: inout GraphicsContext, center: CGPoint,
                                      outerRadius: Double, data: WheelPlotData,
                                      theme: WheelTheme) {
    guard data.cuspLongitudes.count >= 12 else { return }
    let cusps    = data.cuspLongitudes
    let r        = outerRadius * WheelMetrics.cardinalIndicator
    let fontSize = WheelMetrics.fontSize(WheelMetrics.cardinalFontFraction, outerRadius: outerRadius)

    let ascAngle = HouseWheelPlotDataBuilder.eclipticToHouseAngle(
        longitude: data.ascendantLongitude, cusps: cusps)
    let dscAngle = HouseWheelPlotDataBuilder.eclipticToHouseAngle(
        longitude: WheelGeometry.normalise(data.ascendantLongitude + 180.0), cusps: cusps)
    let mcAngle  = HouseWheelPlotDataBuilder.eclipticToHouseAngle(
        longitude: data.mcLongitude, cusps: cusps)
    let icAngle  = HouseWheelPlotDataBuilder.eclipticToHouseAngle(
        longitude: WheelGeometry.normalise(data.mcLongitude + 180.0), cusps: cusps)

    let labels: [(String, Double)] = [
        ("A", ascAngle), ("D", dscAngle), ("M", mcAngle), ("I", icAngle)
    ]
    for (label, angle) in labels {
        let pt   = WheelGeometry.point(angleDeg: angle, radius: r, center: center)
        let text = Text(label)
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(theme.cardinalIndicator)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - Planets

private func drawHousePlanetConnectLines(_ ctx: inout GraphicsContext, center: CGPoint,
                                          outerRadius: Double, data: WheelPlotData,
                                          theme: WheelTheme) {
    let glyphR = outerRadius * 0.68
    let houseR = outerRadius * WheelMetrics.outerHouse
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.connectLineFraction, outerRadius: outerRadius)

    for item in data.planetItems {
        let p1   = WheelGeometry.point(angleDeg: item.plotAngle,    radius: glyphR, center: center)
        let p2   = WheelGeometry.point(angleDeg: item.mundaneAngle, radius: houseR, center: center)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path,
                   with: .color(theme.planetConnectLine.opacity(WheelMetrics.connectLineOpacity)),
                   lineWidth: stroke)
    }
}

private func drawHousePlanetGlyphs(_ ctx: inout GraphicsContext, center: CGPoint,
                                    outerRadius: Double, data: WheelPlotData,
                                    theme: WheelTheme) {
    let r        = outerRadius * 0.68
    let fontSize = WheelMetrics.fontSize(WheelMetrics.planetGlyphFontFraction, outerRadius: outerRadius)

    for item in data.planetItems {
        let pt   = WheelGeometry.point(angleDeg: item.plotAngle, radius: r, center: center)
        let text = Text(item.glyph)
            .font(.custom("EnigmaAstrology3", size: fontSize))
            .foregroundColor(theme.planetGlyph)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

private func drawHousePlanetTexts(_ ctx: inout GraphicsContext, center: CGPoint,
                                   outerRadius: Double, data: WheelPlotData,
                                   theme: WheelTheme) {
    let r        = outerRadius * 0.50
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
