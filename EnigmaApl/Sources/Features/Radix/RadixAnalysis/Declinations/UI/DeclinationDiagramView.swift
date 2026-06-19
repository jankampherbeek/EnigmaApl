// DeclinationDiagramView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

// MARK: - Data models

/// One celestial point entry for the declination diagram.
struct DeclDiagramItem {
    let factor:      Factors
    let glyph:       String
    let longitude:   Double   // ecliptic longitude 0–360
    let declination: Double   // positive = north, negative = south
}

// MARK: - Canvas

/// Full 2-D declination diagram (Kt Boehrer style).
///
/// Horizontal axis: ecliptic longitude 0–180° (left = Aries side, right = Libra side).
/// Vertical axis: declination −range … 0 … +range.
/// North positions appear in the upper half, South in the lower half.
/// Position lines: a horizontal line at each point's declination + a vertical line from
/// the longitude axis to the declination position.
struct DeclDiagramCanvas: View {
    let items:             [DeclDiagramItem]
    let obliquity:         Double
    let blackWhite:        Bool
    let showPositionLines: Bool

    // MARK: Colours
    private var bgColor:         Color { blackWhite ? Color(white: 0.88) : Color(red: 0.73, green: 0.89, blue: 0.97) }
    private var inBoundsColor:   Color { blackWhite ? Color(white: 0.96) : Color(red: 0.88, green: 0.96, blue: 0.99) }
    private var signBarColor:    Color { blackWhite ? Color(white: 0.82) : Color(red: 0.82, green: 0.78, blue: 0.40) }
    private var polygonNFill:    Color { blackWhite ? Color(white: 0.90) : Color(red: 1.0,  green: 0.93, blue: 0.88) }
    private var polygonNStroke:  Color { blackWhite ? Color(white: 0.45) : Color(red: 0.85, green: 0.40, blue: 0.20) }
    private var polygonSFill:    Color { blackWhite ? Color(white: 0.85) : Color(red: 0.87, green: 0.95, blue: 1.0)  }
    private var polygonSStroke:  Color { blackWhite ? Color(white: 0.40) : Color(red: 0.27, green: 0.52, blue: 0.84) }
    private var axisColor:       Color { blackWhite ? .black             : Color(white: 0.20) }
    private var glyphColor:      Color { blackWhite ? .black             : Color(red: 0.18, green: 0.31, blue: 0.53) }
    private var signGlyphColor:  Color { blackWhite ? .black             : Color(red: 0.18, green: 0.31, blue: 0.53) }
    private var degTextColor:    Color { blackWhite ? .black             : Color(red: 0.30, green: 0.30, blue: 0.50) }
    private var posLineColors:   [Color] {
        blackWhite
        ? [Color(white: 0.20), Color(white: 0.45), Color(white: 0.60)]
        : [Color(red: 0.0,  green: 0.55, blue: 0.55),
           Color(red: 0.75, green: 0.0,  blue: 0.75),
           Color(red: 0.0,  green: 0.0,  blue: 0.80)]
    }

    // Sign glyphs: Aries … Virgo (top row, longitude 0–150°),
    //             Pisces … Libra reversed (bottom row, longitude 0–150° maps to 180°–30°)
    private let signGlyphsTop: [Signs] = [.Aries, .Taurus, .Gemini, .Cancer, .Leo, .Virgo]
    private let signGlyphsBottom: [Signs] = [.Pisces, .Aquarius, .Capricorn, .Sagittarius, .Scorpio, .Libra]

    var body: some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height

            // Declination range: at least 30°, extended in 5° steps.
            let maxAbsDecl = items.map { abs($0.declination) }.max() ?? 0
            var declRange = 30
            if maxAbsDecl > Double(declRange) {
                let extra = Int(maxAbsDecl - Double(declRange))
                declRange += (extra / 5 + 1) * 5
            }
            let rangeD = Double(declRange)

            // Layout constants (fractions of canvas).
            let topBorder    = h * 0.07   // room for sign glyphs / top long-axis
            let bottomBorder = h * 0.07
            let leftBorder   = w * 0.06   // room for decl labels + left axis
            let rightBorder  = w * 0.06
            let diagramW     = w - leftBorder - rightBorder
            let diagramH     = h - topBorder - bottomBorder
            let midY         = topBorder + diagramH / 2.0  // y for 0° declination

            // Size of one declination degree in pixels.
            let declPixPerDeg = (diagramH / 2.0) / rangeD
            // Size of one longitude degree in pixels.
            let longPixPerDeg = diagramW / 180.0

            // ── Background ──────────────────────────────────────────────────
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)), with: .color(bgColor))

            // In-bounds region (between ±obliquity).
            let inBoundsHalf = obliquity * declPixPerDeg
            ctx.fill(
                Path(CGRect(x: leftBorder, y: midY - inBoundsHalf,
                            width: diagramW, height: inBoundsHalf * 2)),
                with: .color(inBoundsColor)
            )

            // Alternating sign bars (every 30°, 6 bars).
            let signW = longPixPerDeg * 30.0
            for i in stride(from: 0, to: 6, by: 2) {
                let xBar = leftBorder + Double(i) * signW
                // top OOB strip
                ctx.fill(Path(CGRect(x: xBar, y: topBorder,
                                     width: signW, height: midY - inBoundsHalf - topBorder)),
                         with: .color(signBarColor.opacity(0.50)))
                // in-bounds strip
                ctx.fill(Path(CGRect(x: xBar, y: midY - inBoundsHalf,
                                     width: signW, height: inBoundsHalf * 2)),
                         with: .color(signBarColor.opacity(0.25)))
                // bottom OOB strip
                ctx.fill(Path(CGRect(x: xBar, y: midY + inBoundsHalf,
                                     width: signW, height: topBorder + diagramH - (midY + inBoundsHalf))),
                         with: .color(signBarColor.opacity(0.50)))
            }

            // ── Polygon (ecliptic curve) ─────────────────────────────────────
            var northPts: [CGPoint] = []
            var southPts: [CGPoint] = []
            for deg in 0...180 {
                let d = Double(deg)
                let decl = asin(sin(d * .pi / 180.0) * sin(obliquity * .pi / 180.0)) * 180.0 / .pi
                let x = leftBorder + d * longPixPerDeg
                northPts.append(CGPoint(x: x, y: midY - decl * declPixPerDeg))
                southPts.append(CGPoint(x: x, y: midY + decl * declPixPerDeg))
            }
            // Draw north polygon (fill between 0° line and curve).
            var northPath = Path()
            northPath.move(to: CGPoint(x: leftBorder, y: midY))
            for pt in northPts { northPath.addLine(to: pt) }
            northPath.addLine(to: CGPoint(x: leftBorder + diagramW, y: midY))
            northPath.closeSubpath()
            ctx.fill(northPath, with: .color(polygonNFill.opacity(0.50)))
            ctx.stroke(northPath, with: .color(polygonNStroke), lineWidth: 1.0)

            var southPath = Path()
            southPath.move(to: CGPoint(x: leftBorder, y: midY))
            for pt in southPts { southPath.addLine(to: pt) }
            southPath.addLine(to: CGPoint(x: leftBorder + diagramW, y: midY))
            southPath.closeSubpath()
            ctx.fill(southPath, with: .color(polygonSFill.opacity(0.50)))
            ctx.stroke(southPath, with: .color(polygonSStroke), lineWidth: 1.0)

            // ── Axes ─────────────────────────────────────────────────────────
            // Horizontal: longitude axis at top and bottom.
            drawLine(ctx: &ctx, from: CGPoint(x: leftBorder, y: topBorder),
                     to: CGPoint(x: leftBorder + diagramW, y: topBorder), color: axisColor)
            drawLine(ctx: &ctx, from: CGPoint(x: leftBorder, y: topBorder + diagramH),
                     to: CGPoint(x: leftBorder + diagramW, y: topBorder + diagramH), color: axisColor)
            // Vertical: declination axis at left and right.
            drawLine(ctx: &ctx, from: CGPoint(x: leftBorder, y: topBorder),
                     to: CGPoint(x: leftBorder, y: topBorder + diagramH), color: axisColor)
            drawLine(ctx: &ctx, from: CGPoint(x: leftBorder + diagramW, y: topBorder),
                     to: CGPoint(x: leftBorder + diagramW, y: topBorder + diagramH), color: axisColor)
            // Zero-declination centre line.
            drawLine(ctx: &ctx, from: CGPoint(x: leftBorder, y: midY),
                     to: CGPoint(x: leftBorder + diagramW, y: midY),
                     color: axisColor.opacity(0.40), width: 0.5)

            // ── Longitude degree ticks (top & bottom) ────────────────────────
            for i in 0...180 {
                let x = leftBorder + Double(i) * longPixPerDeg
                let tickLen: Double = (i % 10 == 0) ? 8 : (i % 5 == 0 ? 5 : 2)
                // top
                drawLine(ctx: &ctx,
                         from: CGPoint(x: x, y: topBorder),
                         to:   CGPoint(x: x, y: topBorder + tickLen), color: axisColor)
                // bottom
                drawLine(ctx: &ctx,
                         from: CGPoint(x: x, y: topBorder + diagramH),
                         to:   CGPoint(x: x, y: topBorder + diagramH - tickLen), color: axisColor)
            }

            // ── Declination degree ticks (left & right) ───────────────────────
            let totalTicks = declRange * 2
            for i in 0...totalTicks {
                let y = topBorder + Double(i) * (diagramH / Double(totalTicks))
                let tickLen: Double = (i % 10 == 0) ? 8 : (i % 5 == 0 ? 5 : 2)
                // left
                drawLine(ctx: &ctx, from: CGPoint(x: leftBorder, y: y),
                         to: CGPoint(x: leftBorder + tickLen, y: y), color: axisColor)
                // right
                drawLine(ctx: &ctx, from: CGPoint(x: leftBorder + diagramW, y: y),
                         to: CGPoint(x: leftBorder + diagramW - tickLen, y: y), color: axisColor)
            }

            // ── Declination degree labels (left axis, every 10°) ──────────────
            let degFont = Font.system(size: max(7, min(11, w * 0.018)))
            for i in stride(from: 0, through: declRange, by: 10) {
                let degValue = declRange - i
                // North labels
                let yN = topBorder + Double(i) * declPixPerDeg
                ctx.draw(
                    Text("\(degValue)").font(degFont).foregroundStyle(degTextColor),
                    at: CGPoint(x: leftBorder - 4, y: yN), anchor: .trailing
                )
                // South labels (mirror)
                if i > 0 {
                    let yS = midY + Double(i) * declPixPerDeg
                    ctx.draw(
                        Text("\(degValue)").font(degFont).foregroundStyle(degTextColor),
                        at: CGPoint(x: leftBorder - 4, y: yS), anchor: .trailing
                    )
                }
            }

            // ── Sign glyphs (top and bottom border) ───────────────────────────
            let signFont = Font.custom("EnigmaAstrology3", size: max(10, min(20, w * 0.028)))
            for i in 0..<6 {
                let signCentreX = leftBorder + (Double(i) + 0.5) * signW
                // Top row: Aries … Virgo
                ctx.draw(
                    Text(GlyphSelector.getGlyphForSign(signGlyphsTop[i])).font(signFont).foregroundStyle(signGlyphColor),
                    at: CGPoint(x: signCentreX, y: topBorder / 2), anchor: .center
                )
                // Bottom row: Pisces … Libra (mirror)
                ctx.draw(
                    Text(GlyphSelector.getGlyphForSign(signGlyphsBottom[i])).font(signFont).foregroundStyle(signGlyphColor),
                    at: CGPoint(x: signCentreX, y: topBorder + diagramH + bottomBorder / 2), anchor: .center
                )
            }

            // ── Celestial point glyphs + position lines ───────────────────────
            let glyphFont  = Font.custom("EnigmaAstrology3", size: max(9, min(18, w * 0.025)))
            let glyphSize  = max(9.0, min(18.0, w * 0.025))

            // Sort into 72 columns of 2.5° longitude each to handle overlap.
            let sortedItems = items.sorted { abs($0.declination) < abs($1.declination) }
            var adjustedDecl: [Factors: Double] = [:]
            for item in sortedItems {
                adjustedDecl[item.factor] = item.declination
            }

            // Minimal declination separation to avoid glyph overlap (degrees).
            let minSepDeg = glyphSize / declPixPerDeg * 1.4

            // Group by longitude bucket (2.5°).
            var buckets: [[DeclDiagramItem]] = Array(repeating: [], count: 72)
            for item in sortedItems {
                let effectiveLong = item.longitude < 180.0 ? item.longitude : 360.0 - item.longitude
                let bucket = min(71, Int(effectiveLong / 2.5))
                buckets[bucket].append(item)
            }
            for b in 0..<72 {
                buckets[b].sort { abs($0.declination) < abs($1.declination) }
                var lastDecl = -1000.0
                for item in buckets[b] {
                    var decl = adjustedDecl[item.factor] ?? item.declination
                    let absDiff = abs(abs(decl) - abs(lastDecl))
                    if absDiff < minSepDeg {
                        let push = minSepDeg - absDiff
                        decl = decl >= 0 ? decl + push : decl - push
                    }
                    adjustedDecl[item.factor] = decl
                    lastDecl = decl
                }
            }

            var colorIndex = 0
            for item in sortedItems {
                let lineColor  = posLineColors[colorIndex % posLineColors.count]
                colorIndex += 1

                let adjDecl    = adjustedDecl[item.factor] ?? item.declination
                let rawDecl    = item.declination
                let effLong    = item.longitude < 180.0 ? item.longitude : 360.0 - item.longitude
                let xPos       = leftBorder + effLong * longPixPerDeg
                let yActual    = midY - rawDecl * declPixPerDeg      // true y for position lines
                let yGlyph     = midY - adjDecl * declPixPerDeg      // adjusted y for glyph

                if showPositionLines {
                    // Horizontal line from left axis to right axis at actual declination.
                    var hLine = Path()
                    hLine.move(to: CGPoint(x: leftBorder, y: yActual))
                    hLine.addLine(to: CGPoint(x: leftBorder + diagramW, y: yActual))
                    ctx.stroke(hLine, with: .color(lineColor.opacity(0.60)),
                               style: StrokeStyle(lineWidth: 0.6))

                    // Vertical line from longitude axis to the declination position.
                    let yBorderForLong = item.longitude < 180.0 ? topBorder : topBorder + diagramH
                    var vLine = Path()
                    vLine.move(to: CGPoint(x: xPos, y: yBorderForLong))
                    vLine.addLine(to: CGPoint(x: xPos, y: yActual))
                    ctx.stroke(vLine, with: .color(lineColor.opacity(0.60)),
                               style: StrokeStyle(lineWidth: 0.6))
                }

                // Glyph
                ctx.draw(
                    Text(item.glyph).font(glyphFont).foregroundStyle(glyphColor),
                    at: CGPoint(x: xPos - glyphSize * 0.3, y: yGlyph - glyphSize * 0.55),
                    anchor: .topLeading
                )
            }
        }
        .background(Color.white)
        .aspectRatio(1.3, contentMode: .fit)
    }

    // MARK: - Drawing helper
    private func drawLine(ctx: inout GraphicsContext,
                          from: CGPoint, to: CGPoint,
                          color: Color, width: CGFloat = 1.0) {
        var p = Path()
        p.move(to: from)
        p.addLine(to: to)
        ctx.stroke(p, with: .color(color), lineWidth: width)
    }
}

// MARK: - View

struct DeclinationDiagramView: View {
    @Binding var activeTab: DeclinationsTab

    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var blackWhite        = false
    @State private var showPositionLines = false
    @State private var showExport        = false
    @State private var showFactsheet     = false
    @State private var showHelp          = false

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Declinations", bundle: .main, comment: "")
    }

    // MARK: - Derived data

    private var diagramItems: [DeclDiagramItem] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return config.factorConfig.factorSettings
            .filter { $0.isUsed }
            .compactMap { settings -> DeclDiagramItem? in
                guard let (longitude, declination) = DeclMidpointsCalculator.longAndDeclination(
                    for: settings.factor, in: chart
                ) else { return nil }
                return DeclDiagramItem(
                    factor:      settings.factor,
                    glyph:       GlyphSelector.getGlyphForFactor(settings.factor),
                    longitude:   longitude,
                    declination: declination
                )
            }
            .sorted { $0.longitude < $1.longitude }
    }

    private var obliquity: Double {
        chartSession.selectedChart?.Obliquity ?? 23.45
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let wideLayout = geo.size.width > 700
            Group {
                if wideLayout {
                    HStack(alignment: .top, spacing: 12) {
                        diagramCanvas
                            .frame(maxWidth: .infinity)
                        positionsTable
                            .frame(width: 280)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            diagramCanvas
                                .frame(maxWidth: .infinity)
                            positionsTable
                        }
                        .padding()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                tabPicker
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    showPositionLines.toggle()
                } label: {
                    Label(t(DeclinationsKeys.diagramBtnPositionLines),
                          systemImage: showPositionLines ? "lines.measurement.horizontal" : "lines.measurement.horizontal")
                }
                .foregroundStyle(showPositionLines ? .primary : .secondary)
                .accessibilityLabel(t(DeclinationsKeys.diagramBtnPositionLines))
            }
            ToolbarItem(placement: .automatic) {
                Button { blackWhite.toggle() } label: {
                    Image(systemName: blackWhite ? "circle.lefthalf.filled" : "paintpalette")
                }
                .accessibilityLabel(blackWhite ? "Switch to color" : "Switch to black and white")
            }
            ToolbarItem(placement: .automatic) {
                Button { showExport = true } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Export")
            }
            ToolbarItem(placement: .automatic) {
                Button { showFactsheet = true } label: {
                    Image(systemName: "book.pages")
                }
                .accessibilityLabel("Factsheet")
            }
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showFactsheet) {
            FactsheetView(baseName: "declinations")
        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(
                wheelView: DeclDiagramCanvas(
                    items: diagramItems,
                    obliquity: obliquity,
                    blackWhite: blackWhite,
                    showPositionLines: showPositionLines
                )
            )
        }
        .sheet(isPresented: $showHelp) {
            NavigationStack {
                ScrollView {
                    Text(t(DeclinationsKeys.diagramHelp))
                        .padding()
                }
                .navigationTitle("Help")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("OK") { showHelp = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Sub-views

    private var diagramCanvas: some View {
        DeclDiagramCanvas(
            items: diagramItems,
            obliquity: obliquity,
            blackWhite: blackWhite,
            showPositionLines: showPositionLines
        )
    }

    @ViewBuilder
    private var positionsTable: some View {
        if diagramItems.isEmpty {
            Text(t(DeclinationsKeys.diagramNoData))
                .foregroundStyle(.secondary)
                .font(.callout)
        } else {
            GroupBox {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text(t(DeclinationsKeys.diagramColFactor))
                            .frame(width: 28, alignment: .center)
                        Text(t(DeclinationsKeys.diagramColLongitude))
                            .frame(width: 110, alignment: .trailing)
                        Text(t(DeclinationsKeys.diagramColDeclination))
                            .frame(width: 90, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)

                    Divider()

                    ForEach(Array(diagramItems.enumerated()), id: \.offset) { index, item in
                        tableRow(item, index: index)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func tableRow(_ item: DeclDiagramItem, index: Int) -> some View {
        HStack(spacing: 4) {
            Text(item.glyph)
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: 28, alignment: .center)
                .accessibilityLabel(item.factor.localizedName)

            longitudeText(item.longitude)
                .frame(width: 110, alignment: .trailing)

            Text(PositionInDegreesConversion.DoubleToDms(item.declination))
                .frame(width: 90, alignment: .trailing)
                .monospacedDigit()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Helpers

    @ViewBuilder
    private func longitudeText(_ longitude: Double) -> some View {
        let (dmsString, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(longitude)
        if success, let sign {
            Text(longitudeAttributedString(dms: dmsString, sign: sign))
                .monospacedDigit()
        } else {
            Text(PositionInDegreesConversion.DoubleToDms(longitude))
                .monospacedDigit()
        }
    }

    private func longitudeAttributedString(dms: String, sign: Signs) -> AttributedString {
        var dmsAttr = AttributedString(dms + " ")
        dmsAttr.font = .body
        var glyphAttr = AttributedString(GlyphSelector.getGlyphForSign(sign))
        glyphAttr.font = .custom("EnigmaAstrology3", size: 18)
        return dmsAttr + glyphAttr
    }

    private var tabPicker: some View {
        Picker("", selection: $activeTab) {
            Text(t(DeclinationsKeys.btnAllDeclinations)).tag(DeclinationsTab.all)
            Text(t(DeclinationsKeys.btnParallels)).tag(DeclinationsTab.parallels)
            Text(t(DeclinationsKeys.btnEquivalents)).tag(DeclinationsTab.equivalents)
            Text(t(DeclinationsKeys.btnDiagram)).tag(DeclinationsTab.diagram)
            Text(t(DeclinationsKeys.btnMidpoints)).tag(DeclinationsTab.midpoints)
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
}
