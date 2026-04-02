// DeclStripCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// A vertical declination strip diagram.
///
/// Layout (top = north pole, bottom = south pole):
/// - Background: in-bounds region (cyan tint), out-of-bounds region above obliquity (blue tint)
/// - Central vertical bar with horizontal degree lines
/// - Factor glyphs on the left (north / positive declination) with a line to the bar
/// - Factor glyphs on the right (south / negative declination) with a line to the bar
/// - Degree labels inside the bar
/// - "N" / "S" labels at the bottom
struct DeclStripCanvas: View {
    let items: [DeclStripItem]
    let obliquity: Double
    let blackWhite: Bool

    // MARK: - Colours

    private var inBoundsColor:  Color { blackWhite ? Color(white: 0.95) : Color(red: 0.88, green: 0.96, blue: 0.98) }
    private var oobColor:       Color { blackWhite ? Color(white: 0.85) : Color(red: 0.76, green: 0.89, blue: 0.96) }
    private var barColor:       Color { blackWhite ? Color(white: 0.80) : Color(red: 0.94, green: 0.91, blue: 0.70) }
    private var lineColor:      Color { blackWhite ? Color(white: 0.40) : Color(red: 0.0,  green: 0.55, blue: 0.55) }
    private var glyphColor:     Color { blackWhite ? .black             : Color(red: 0.18, green: 0.31, blue: 0.53) }
    private var labelColor:     Color { blackWhite ? .black             : Color(red: 0.18, green: 0.31, blue: 0.53) }
    private var degLineColor:   Color { blackWhite ? Color(white: 0.55) : Color(red: 0.72, green: 0.68, blue: 0.44) }

    // MARK: - Fixed layout fractions  (relative to canvas size)

    // The bar sits in the horizontal centre and spans barWidthFraction of the width.
    private let barWidthFraction:    Double = 0.12
    // The usable drawing area is barHeightFraction of the canvas height (leaves room for labels at bottom).
    private let barHeightFraction:   Double = 0.94
    // The N/S label row occupies this fraction of the canvas height at the bottom.
    private let labelAreaFraction:   Double = 0.03
    // Extra horizontal margin between the bar edge and the first glyph column.
    private let glyphMarginFraction: Double = 0.06

    var body: some View {
        Canvas { ctx, size in
            let w = Double(size.width)
            let h = Double(size.height)

            // Degrees range — always at least 30°, expanded in 5° steps when needed.
            let maxAbsDecl = items.map { abs($0.declination) }.max() ?? 0
            var declRange = 30
            if maxAbsDecl > Double(declRange) {
                let extra = Int(maxAbsDecl - Double(declRange))
                let steps = extra / 5 + 1
                declRange += steps * 5
            }
            let degreesCount = Double(declRange)

            // Geometry
            let labelAreaH  = h * labelAreaFraction
            let barH        = h * barHeightFraction
            let barW        = w * barWidthFraction
            let barX        = (w - barW) / 2.0
            let barTopY     = h - barH - labelAreaH
            let degreeH     = barH / degreesCount   // pixels per degree

            // Obliquity line y-position (from bar top)
            let oblY = barTopY + (degreesCount - obliquity) * degreeH

            // --- Backgrounds ---

            // Out-of-bounds background (full canvas, drawn first)
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: oblY)), with: .color(oobColor))
            // In-bounds background (below obliquity line)
            ctx.fill(Path(CGRect(x: 0, y: oblY, width: w, height: h - oblY)), with: .color(inBoundsColor))

            // Central bar background
            ctx.fill(Path(CGRect(x: barX, y: barTopY, width: barW, height: barH)), with: .color(barColor))

            // --- Degree lines + labels inside the bar ---
            let labelFont = Font.system(size: max(8, min(14, w * 0.028)))
            for i in 0..<declRange {
                let y = barTopY + Double(i) * degreeH
                let degValue = declRange - i

                // Horizontal tick line across the bar
                var linePath = Path()
                linePath.move(to: CGPoint(x: barX, y: y))
                linePath.addLine(to: CGPoint(x: barX + barW, y: y))
                ctx.stroke(linePath, with: .color(degLineColor), lineWidth: 0.75)

                // Degree number (inside bar, near left edge)
                let txt = Text("\(degValue)").font(labelFont).foregroundStyle(labelColor)
                ctx.draw(txt, at: CGPoint(x: barX + barW * 0.15, y: y + degreeH * 0.3), anchor: .topLeading)
            }

            // --- Obliquity indicator line (full width) ---
            var oblPath = Path()
            oblPath.move(to: CGPoint(x: 0, y: oblY))
            oblPath.addLine(to: CGPoint(x: w, y: oblY))
            ctx.stroke(oblPath, with: .color(blackWhite ? .black : .orange), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

            // --- Factor glyphs and position lines ---
            let glyphFont = Font.custom("EnigmaAstrology2", size: max(10, min(24, w * 0.06)))
            let northBaseX  = barX - w * glyphMarginFraction
            let southBaseX  = barX + barW + w * glyphMarginFraction

            // Separate north (≥0) and south (<0) items, sorted to minimise overlap.
            let northItems = items.filter { $0.declination >= 0 }.sorted { $0.declination < $1.declination }
            let southItems = items.filter { $0.declination < 0  }.sorted { abs($0.declination) < abs($1.declination) }

            let margin = w * 0.045
            drawGlyphs(ctx: &ctx, items: northItems, baseX: northBaseX, isNorth: true,
                       barX: barX, barTopY: barTopY, degreeH: degreeH, degreesCount: degreesCount,
                       margin: margin, glyphFont: glyphFont, lineColor: lineColor, glyphColor: glyphColor)

            drawGlyphs(ctx: &ctx, items: southItems, baseX: southBaseX, isNorth: false,
                       barX: barX + barW, barTopY: barTopY, degreeH: degreeH, degreesCount: degreesCount,
                       margin: margin, glyphFont: glyphFont, lineColor: lineColor, glyphColor: glyphColor)

            // --- N / S direction labels ---
            let dirFont = Font.system(size: max(9, min(13, w * 0.03))).weight(.semibold)
            let dirY    = h - labelAreaH * 0.5
            ctx.draw(Text("N").font(dirFont).foregroundStyle(labelColor),
                     at: CGPoint(x: barX - w * 0.08, y: dirY), anchor: .center)
            ctx.draw(Text("S").font(dirFont).foregroundStyle(labelColor),
                     at: CGPoint(x: barX + barW + w * 0.08, y: dirY), anchor: .center)
        }
        .background(Color.white)
        .aspectRatio(0.55, contentMode: .fit)   // portrait strip
    }

    // MARK: - Helper

    private func drawGlyphs(
        ctx: inout GraphicsContext,
        items: [DeclStripItem],
        baseX: Double,
        isNorth: Bool,
        barX: Double,                // x of bar edge nearest to this side
        barTopY: Double,
        degreeH: Double,
        degreesCount: Double,
        margin: Double,
        glyphFont: Font,
        lineColor: Color,
        glyphColor: Color
    ) {
        var lastDecl: Double = -1000
        var marginFactor = 0

        for item in items {
            let absDecl = abs(item.declination)
            let y = barTopY + (degreesCount - absDecl) * degreeH

            // Push glyph sideways when two items are very close in declination
            if (absDecl - lastDecl) < 0.5 { marginFactor += 1 } else { marginFactor = 0 }
            let xPos = isNorth
                ? baseX - Double(marginFactor) * margin
                : baseX + Double(marginFactor) * margin

            // Position line from glyph to bar edge
            var linePath = Path()
            linePath.move(to: CGPoint(x: xPos, y: y))
            linePath.addLine(to: CGPoint(x: barX, y: y))
            ctx.stroke(linePath, with: .color(lineColor.opacity(0.5)), lineWidth: 0.75)

            // Glyph
            let txt = Text(item.glyph).font(glyphFont).foregroundStyle(glyphColor)
            ctx.draw(txt, at: CGPoint(x: xPos, y: y), anchor: .center)

            lastDecl = absDecl
        }
    }
}

// MARK: - Data model

struct DeclStripItem {
    let factor: Factors
    let glyph: String
    let declination: Double          // positive = north, negative = south
    let longitude: Double            // ecliptic longitude 0–360
}
