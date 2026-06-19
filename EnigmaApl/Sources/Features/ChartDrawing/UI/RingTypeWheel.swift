// RingTypeWheel.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct RingTypeWheel: View {
    let chart: FullChart
    let chartVersion: UUID
    @Binding var blackWhite:  Bool
    @Binding var hideAspects: Bool
    @Binding var hideTime:    Bool
    @Binding var showExport:  Bool

    @StateObject private var model = ZodiacTypeWheelModel()
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
            cuspLongitudes:     [],
            planetItems:        d.planetItems,
            hasTime:            false,
            aspectItems:        d.aspectItems
        )
    }

    var body: some View {
        VStack(spacing: 4) {
            RingTypeWheelCanvas(
                plotData:    effectiveData,
                theme:       currentTheme,
                showAspects: !hideAspects
            )

        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(
                wheelView: RingTypeWheelCanvas(
                    plotData:    effectiveData,
                    theme:       currentTheme,
                    showAspects: !hideAspects
                )
            )
        }
        .onAppear { model.update(from: chart, config: activeConfig) }
        .onChange(of: chartVersion) { model.update(from: chart, config: activeConfig) }
    }
}

// MARK: - RingTypeWheelCanvas

struct RingTypeWheelCanvas: View {
    let plotData: WheelPlotData
    let theme: WheelTheme
    let showAspects: Bool

    var body: some View {
        Canvas { ctx, size in
            let outerRadius = Double(min(size.width, size.height)) / 2.0
            let center      = CGPoint(x: size.width / 2, y: size.height / 2)

            // Altijd witte achtergrond, ook in dark mode.
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white))

            drawRingCircle(&ctx, center: center, outerRadius: outerRadius, theme: theme)
            if plotData.hasTime {
                drawRingCuspLines(&ctx, center: center, outerRadius: outerRadius,
                                  data: plotData, theme: theme)
                drawRingCuspLabels(&ctx, center: center, outerRadius: outerRadius,
                                   data: plotData, theme: theme)
                drawRingInterceptedSignGlyphs(&ctx, center: center, outerRadius: outerRadius,
                                              data: plotData, theme: theme)
            }
            if showAspects {
                drawRingAspectLines(&ctx, center: center, outerRadius: outerRadius,
                                    data: plotData, theme: theme)
            }
            drawRingPlanetGlyphs(&ctx, center: center, outerRadius: outerRadius,
                                 data: plotData, theme: theme)
            drawRingPlanetTexts(&ctx, center: center, outerRadius: outerRadius,
                                data: plotData, theme: theme)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Circle

private func drawRingCircle(_ ctx: inout GraphicsContext, center: CGPoint,
                             outerRadius: Double, theme: WheelTheme) {
    let r      = outerRadius * RingMetrics.ring
    let rect   = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
    let stroke = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction, outerRadius: outerRadius)
    ctx.stroke(Path(ellipseIn: rect),
               with: .color(Color(white: 0.75)),
               lineWidth: stroke)
}

// MARK: - Cusp lines (center → ring)

private func drawRingCuspLines(_ ctx: inout GraphicsContext, center: CGPoint,
                                outerRadius: Double, data: WheelPlotData, theme: WheelTheme) {
    let ringR   = outerRadius * RingMetrics.ring
    let thin    = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction,       outerRadius: outerRadius)
    let thick   = WheelMetrics.strokeWidth(WheelMetrics.strokeFraction * 2.0, outerRadius: outerRadius)
    let ascLong = data.ascendantLongitude

    for (i, cuspLong) in data.cuspLongitudes.enumerated() {
        let angle = WheelGeometry.mundaneAngle(longitude: cuspLong, ascendantLongitude: ascLong)
        let lw    = (i % 3 == 0) ? thick : thin
        let p2    = WheelGeometry.point(angleDeg: angle, radius: ringR, center: center)
        var path  = Path(); path.move(to: center); path.addLine(to: p2)
        ctx.stroke(path, with: .color(Color(white: 0.75)),
                   lineWidth: lw)
    }
}

// MARK: - Cusp labels (degree + sign glyph, outside ring)

private func drawRingCuspLabels(_ ctx: inout GraphicsContext, center: CGPoint,
                                 outerRadius: Double, data: WheelPlotData, theme: WheelTheme) {
    let r        = outerRadius * RingMetrics.cuspLabel
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction, outerRadius: outerRadius)
    let ascLong  = data.ascendantLongitude

    for cuspLong in data.cuspLongitudes {
        let angle  = WheelGeometry.mundaneAngle(longitude: cuspLong, ascendantLongitude: ascLong)
        let pt     = WheelGeometry.point(angleDeg: angle, radius: r, center: center)
        let label  = ringPositionLabel(longitude: cuspLong, textSize: fontSize, color: theme.cuspText)
        let rotDeg = cuspTextRotation(angle: angle)

        ctx.drawLayer { layerCtx in
            layerCtx.translateBy(x: pt.x, y: pt.y)
            layerCtx.rotate(by: .degrees(rotDeg))
            layerCtx.draw(layerCtx.resolve(label), at: .zero, anchor: .center)
        }
    }
}

// MARK: - Intercepted sign glyphs

/// Draws a sign glyph at the midpoint of each sign that contains no cusp.
private func drawRingInterceptedSignGlyphs(_ ctx: inout GraphicsContext, center: CGPoint,
                                            outerRadius: Double, data: WheelPlotData,
                                            theme: WheelTheme) {
    let r        = outerRadius * RingMetrics.cuspLabel
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction * 1.4, outerRadius: outerRadius)
    let ascLong  = data.ascendantLongitude

    // Determine which sign indices (0–11) contain at least one cusp.
    let occupiedSigns = Set(data.cuspLongitudes.map { Int($0 / 30.0) % 12 })

    for signIdx in 0..<12 where !occupiedSigns.contains(signIdx) {
        let midLong  = Double(signIdx) * 30.0 + 15.0
        let angle    = WheelGeometry.mundaneAngle(longitude: midLong, ascendantLongitude: ascLong)
        let pt       = WheelGeometry.point(angleDeg: angle, radius: r, center: center)
        guard let sign = Signs(rawValue: signIdx + 1) else { continue }
        let glyph    = GlyphSelector.getGlyphForSign(sign)
        let text     = Text(glyph)
            .font(.custom("EnigmaAstrology3", size: fontSize))
            .foregroundColor(theme.cuspText)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - Planet glyphs (centered on the ring)

private func drawRingPlanetGlyphs(_ ctx: inout GraphicsContext, center: CGPoint,
                                   outerRadius: Double, data: WheelPlotData, theme: WheelTheme) {
    let r        = outerRadius * RingMetrics.ring
    let fontSize = WheelMetrics.fontSize(WheelMetrics.planetGlyphFontFraction * 1.5, outerRadius: outerRadius)

    for item in data.planetItems {
        let pt   = WheelGeometry.point(angleDeg: item.plotAngle, radius: r, center: center)
        let text = Text(item.glyph)
            .font(.custom("EnigmaAstrology3", size: fontSize))
            .foregroundColor(.black)
        ctx.draw(ctx.resolve(text), at: pt, anchor: .center)
    }
}

// MARK: - Planet texts (degree + sign glyph, outside ring)

private func drawRingPlanetTexts(_ ctx: inout GraphicsContext, center: CGPoint,
                                  outerRadius: Double, data: WheelPlotData, theme: WheelTheme) {
    let r        = outerRadius * RingMetrics.planetLabel
    let fontSize = WheelMetrics.fontSize(WheelMetrics.positionTextFraction, outerRadius: outerRadius)

    for item in data.planetItems {
        let pa     = item.plotAngle
        let pt     = WheelGeometry.point(angleDeg: pa, radius: r, center: center)
        let label  = ringPositionLabel(longitude: item.eclipticLongitude,
                                       textSize: fontSize, color: theme.planetText)
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
            layerCtx.draw(layerCtx.resolve(label), at: .zero, anchor: anchor)
        }
    }
}

// MARK: - Aspect lines

private let ringMajorAspects: Set<Aspects> = [.opposition, .square, .trine, .sextile, .inconjunct]

private func drawRingAspectLines(_ ctx: inout GraphicsContext, center: CGPoint,
                                  outerRadius: Double, data: WheelPlotData, theme: WheelTheme) {
    guard !data.aspectItems.isEmpty else { return }
    let r          = outerRadius * RingMetrics.aspectEndpoint
    let majorWidth = WheelMetrics.strokeWidth(WheelMetrics.aspectLineFraction * 2.0, outerRadius: outerRadius)
    let minorWidth = WheelMetrics.strokeWidth(WheelMetrics.connectLineFraction,       outerRadius: outerRadius)
    let dashLen    = CGFloat(outerRadius * 0.04)

    for item in data.aspectItems {
        let p1    = WheelGeometry.point(angleDeg: item.angle1, radius: r, center: center)
        let p2    = WheelGeometry.point(angleDeg: item.angle2, radius: r, center: center)
        let color = theme.aspectLineColor(original: item.color).opacity(WheelMetrics.aspectOpacity)
        var path  = Path(); path.move(to: p1); path.addLine(to: p2)

        if ringMajorAspects.contains(item.aspect) {
            ctx.stroke(path, with: .color(color), lineWidth: majorWidth)
        } else {
            ctx.stroke(path, with: .color(color),
                       style: StrokeStyle(lineWidth: minorWidth, dash: [dashLen, dashLen]))
        }
    }
}

// MARK: - Label helper

/// Combined "deg°min' + sign glyph" Text, e.g. "15°23'♈"
private func ringPositionLabel(longitude: Double, textSize: CGFloat, color: Color) -> Text {
    let inSign  = longitude.truncatingRemainder(dividingBy: 30.0)
    let total   = Int(abs(inSign) * 60)
    let posText = "\(total / 60)°\(String(format: "%02d", total % 60))'"
    let signIdx = Int(longitude / 30.0) % 12
    let sign    = Signs(rawValue: signIdx + 1) ?? .Aries
    let glyph   = GlyphSelector.getGlyphForSign(sign)

    return Text(posText)
        .font(.system(size: textSize))
        .foregroundColor(color)
    + Text(glyph)
        .font(.custom("EnigmaAstrology3", size: textSize * 1.4))
        .foregroundColor(color)
}

// MARK: - Ring metrics

private enum RingMetrics {
    static let ring           = 0.72   // main circle radius
    static let cuspLabel      = 0.81   // cusp label (degree+sign) just outside ring
    static let planetLabel    = 0.86   // planet position text further outside
    static let aspectEndpoint = 0.69   // aspect line endpoints, just inside ring
}
