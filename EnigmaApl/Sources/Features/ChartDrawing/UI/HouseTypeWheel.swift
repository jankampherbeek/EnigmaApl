// HouseTypeWheel.swift
// EnigmaApl
//
// Draws a house-based horoscope wheel using SwiftUI Canvas.
// Each house occupies exactly 30° of visual space.
// Cusp 1 is placed at 90° (9 o'clock), identical to where the ascendant
// sits in ZodiacTypeWheel.
// Zodiac signs are shown in the sign ring with proportional widths.
// No aspect circle; no aspect lines. House cusp lines run to the center.

import SwiftUI
import SwiftData

struct HouseTypeWheel: View {
    let chart: FullChart
    let chartVersion: UUID

    @StateObject private var model = HouseTypeWheelModel()
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private var activeConfig: UserConfiguration? { activeConfigs.first }

    var body: some View {
        Canvas { ctx, size in
            let outerRadius = Double(min(size.width, size.height)) / 2.0
            let center      = CGPoint(x: size.width / 2, y: size.height / 2)
            let data        = model.plotData
            let cusps       = data.cuspLongitudes

            drawHouseCircles(&ctx, center: center, outerRadius: outerRadius)
            if cusps.count >= 12 {
                drawHouseSignSectors(&ctx, center: center, outerRadius: outerRadius, cusps: cusps)
                drawHouseSignSeparators(&ctx, center: center, outerRadius: outerRadius, cusps: cusps)
                drawHouseSignGlyphs(&ctx, center: center, outerRadius: outerRadius, cusps: cusps)
            }
            if data.hasTime {
                drawHouseCuspLines(&ctx, center: center, outerRadius: outerRadius)
                drawHouseCuspPositionTexts(&ctx, center: center, outerRadius: outerRadius, data: data)
                drawHouseCardinalLabels(&ctx, center: center, outerRadius: outerRadius, data: data)
            }
            drawHousePlanetConnectLines(&ctx, center: center, outerRadius: outerRadius, data: data)
            drawHousePlanetGlyphs(&ctx, center: center, outerRadius: outerRadius, data: data)
            drawHousePlanetTexts(&ctx, center: center, outerRadius: outerRadius, data: data)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear { model.update(from: chart, config: activeConfig) }
        .onChange(of: chartVersion) { model.update(from: chart, config: activeConfig) }
    }
}

// MARK: - Circles

private func drawHouseCircles(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double) {
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: outerRadius)
    let layers: [(Double, Color, Bool)] = [
        (WheelMetrics.outerCircle, WheelColors.outerCircleBackground, false),
        (WheelMetrics.outerSign,   WheelColors.signRingBackground,    true),
        (WheelMetrics.outerHouse,  WheelColors.houseRingBackground,   true),
    ]
    for (fraction, fill, drawStroke) in layers {
        let r    = CGFloat(outerRadius * fraction)
        let rect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        ctx.fill(Path(ellipseIn: rect), with: .color(fill))
        if drawStroke {
            ctx.stroke(Path(ellipseIn: rect), with: .color(WheelColors.circleStroke), lineWidth: stroke)
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
                                   outerRadius: Double, cusps: [Double]) {
    let innerR  = outerRadius * WheelMetrics.outerHouse
    let outerR  = outerRadius * WheelMetrics.outerSign
    let angles  = houseSignBoundaryAngles(cusps: cusps)

    for i in 0..<12 {
        let sign  = Signs(rawValue: i + 1) ?? .Aries
        let color = SignColorSelector.getColorForSign(sign)
        let path  = annularSectorPath(from: angles[i], to: angles[i + 1],
                                      inner: innerR, outer: outerR, center: center)
        ctx.fill(path, with: .color(color))
    }
}

private func drawHouseSignSeparators(_ ctx: inout GraphicsContext, center: CGPoint,
                                      outerRadius: Double, cusps: [Double]) {
    let innerR  = outerRadius * WheelMetrics.outerHouse
    let outerR  = outerRadius * WheelMetrics.outerSign
    let stroke  = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: outerRadius)
    let angles  = houseSignBoundaryAngles(cusps: cusps)

    for i in 0..<12 {
        let angle = angles[i]  // WheelGeometry.point handles any angle via sin/cos
        let p1    = WheelGeometry.point(angleDeg: angle, radius: innerR, center: center)
        let p2    = WheelGeometry.point(angleDeg: angle, radius: outerR, center: center)
        var path  = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path, with: .color(WheelColors.signSeparator), lineWidth: stroke)
    }
}

private func drawHouseSignGlyphs(_ ctx: inout GraphicsContext, center: CGPoint,
                                  outerRadius: Double, cusps: [Double]) {
    let glyphR   = outerRadius * WheelMetrics.signGlyph
    let fontSize = WheelMetrics.fontSize(WheelMetrics.signGlyphFontFraction, outerRadius: outerRadius)
    let angles   = houseSignBoundaryAngles(cusps: cusps)

    for i in 0..<12 {
        let midAngle = (angles[i] + angles[i + 1]) / 2.0
        let pt       = WheelGeometry.point(angleDeg: midAngle, radius: glyphR, center: center)
        guard let sign = Signs(rawValue: i + 1) else { continue }
        let glyph    = GlyphSelector.getGlyphForSign(sign)
        let text     = Text(glyph).font(.custom("EnigmaAstrology2", size: fontSize))
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - House cusp lines (equal spacing, run to center)

private func drawHouseCuspLines(_ ctx: inout GraphicsContext, center: CGPoint, outerRadius: Double) {
    let outerR = outerRadius * WheelMetrics.outerHouse
    let thin   = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: outerRadius)
    let thick  = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 2.0, outerRadius: outerRadius)

    for i in 0..<12 {
        // Cusp 1 at 90°, cusp 2 at 120°, … (counter-clockwise)
        let angle = 90.0 + Double(i) * 30.0
        // Angular houses (1, 4, 7, 10) — indices 0, 3, 6, 9 — get a thicker line
        let lw    = (i % 3 == 0) ? thick : thin
        var path  = Path()
        path.move(to: center)
        path.addLine(to: WheelGeometry.point(angleDeg: angle, radius: outerR, center: center))
        ctx.stroke(path, with: .color(WheelColors.cuspLine.opacity(WheelMetrics.cuspLineOpacity)),
                   lineWidth: lw)
    }
}

// MARK: - Cusp position texts (near center, on the cusp line)

private func drawHouseCuspPositionTexts(_ ctx: inout GraphicsContext, center: CGPoint,
                                         outerRadius: Double, data: WheelPlotData) {
    guard data.cuspLongitudes.count >= 12 else { return }
    let r        = outerRadius * 0.20
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction, outerRadius: outerRadius)

    for i in 0..<12 {
        let cuspLong = data.cuspLongitudes[i]
        let angle    = 90.0 + Double(i) * 30.0   // visual position of cusp i+1
        let pt       = WheelGeometry.point(angleDeg: angle, radius: r, center: center)
        let rotDeg   = cuspTextRotation(angle: angle)
        let label    = cuspPositionText(longitude: cuspLong)
        let text     = Text(label)
            .font(.system(size: fontSize))
            .foregroundColor(WheelColors.cardinalIndicator)

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
                                      outerRadius: Double, data: WheelPlotData) {
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
            .foregroundColor(WheelColors.cardinalIndicator)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - Planets

private func drawHousePlanetConnectLines(_ ctx: inout GraphicsContext, center: CGPoint,
                                          outerRadius: Double, data: WheelPlotData) {
    let glyphR = outerRadius * 0.68
    let houseR = outerRadius * WheelMetrics.outerHouse
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.connectLineFraction, outerRadius: outerRadius)

    for item in data.planetItems {
        let p1   = WheelGeometry.point(angleDeg: item.plotAngle,    radius: glyphR, center: center)
        let p2   = WheelGeometry.point(angleDeg: item.mundaneAngle, radius: houseR, center: center)
        var path = Path(); path.move(to: p1); path.addLine(to: p2)
        ctx.stroke(path,
                   with: .color(WheelColors.planetConnectLine.opacity(WheelMetrics.connectLineOpacity)),
                   lineWidth: stroke)
    }
}

private func drawHousePlanetGlyphs(_ ctx: inout GraphicsContext, center: CGPoint,
                                    outerRadius: Double, data: WheelPlotData) {
    let r        = outerRadius * 0.68
    let fontSize = WheelMetrics.fontSize(WheelMetrics.planetGlyphFontFraction, outerRadius: outerRadius)

    for item in data.planetItems {
        let pt   = WheelGeometry.point(angleDeg: item.plotAngle, radius: r, center: center)
        let text = Text(item.glyph)
            .font(.custom("EnigmaAstrology2", size: fontSize))
            .foregroundColor(WheelColors.planetGlyph)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

private func drawHousePlanetTexts(_ ctx: inout GraphicsContext, center: CGPoint,
                                   outerRadius: Double, data: WheelPlotData) {
    let r        = outerRadius * 0.53
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction, outerRadius: outerRadius)

    for item in data.planetItems {
        let pa   = item.plotAngle
        let pt   = WheelGeometry.point(angleDeg: pa, radius: r, center: center)
        let text = Text(item.positionText)
            .font(.system(size: fontSize))
            .foregroundColor(WheelColors.planetText)

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
