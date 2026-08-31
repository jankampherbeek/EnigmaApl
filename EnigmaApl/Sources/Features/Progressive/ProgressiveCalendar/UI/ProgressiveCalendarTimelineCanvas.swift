// ProgressiveCalendarTimelineCanvas.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "ProgressiveCalendar", bundle: .main, comment: "")
}

/// Horizontal-histogram-style timeline for one Progressive Calendar technique: time on the
/// x-axis.
///
/// Aspect/parallel episodes each get their own row — the same aspect color (see
/// `AspectSettings.defaultColor(for:)`) can be shared by more than one aspect (e.g. trine and
/// sextile are both green), so color alone cannot identify what an episode's shape represents.
/// Each row is instead labeled with the same three glyphs the results table uses (progressive
/// factor, aspect/parallel, radix or second progressive factor), and its shape grows from zero
/// at orb-entry to a peak at the exact moment and shrinks back to zero at orb-exit — built
/// directly from `enterJD`/`exactJD`/`exitJD`, without any extra sampling.
///
/// OOB (out-of-bounds) events share that same row-per-occurrence area, interleaved with the
/// episodes in chronological order — each labeled with its factor glyph followed by the text
/// "OOB" (plus a direction arrow) and marked with a tick at its date, since an OOB moment is
/// instantaneous rather than a range.
///
/// The remaining instantaneous events (stations, cusp conjunctions, declination extremes) keep
/// one row per factor, with small colored tick marks for each event on that factor's row.
///
/// The date axis is drawn outside the rows' scroll area, so it stays visible while the rows
/// scroll underneath it whenever there are more rows than fit in the visible height.
///
/// Clicking anywhere in the plot area (axis or rows) shows the date at that x-position — a
/// dashed crosshair marks the clicked spot and a label below the diagram states the exact
/// date/time, both computed by inverting the same `x(for:width:)` mapping used to place
/// everything else, so the reported date always matches what's under the click.
struct ProgressiveCalendarTimelineCanvas: View {
    let episodes: [ProgressiveOrbEpisode]
    let events: [ProgressiveCalendarEvent]
    let startJD: Double
    let endJD: Double

    @State private var canvasWidth: CGFloat = 0
    @State private var selectedJD: Double?

    private let rowHeight: CGFloat = 30
    private let peakHalfHeight: CGFloat = 11
    private let leftLabelWidth: CGFloat = 64
    private let topInset: CGFloat = 12
    private let sectionGap: CGFloat = 14
    private let axisHeight: CGFloat = 22
    private let maxVisibleRows = 8
    private let tickCount = 5

    /// A row in the top (episodes + OOB) section, in chronological order.
    private enum TopRow {
        case episode(ProgressiveOrbEpisode)
        case oob(ProgressiveCalendarEvent)

        var sortJD: Double {
            switch self {
            case .episode(let episode): return episode.exactJD
            case .oob(let event): return event.jd
            }
        }
    }

    private var oobEvents: [ProgressiveCalendarEvent] {
        events.filter {
            switch $0.kind {
            case .oobEnter, .oobExit: return true
            default: return false
            }
        }
    }

    private var topRows: [TopRow] {
        (episodes.map(TopRow.episode) + oobEvents.map(TopRow.oob))
            .sorted { $0.sortJD < $1.sortJD }
    }

    /// The bottom (grouped-by-factor) section excludes OOB — those now live in `topRows`.
    private var eventRows: [Factors] {
        var set = Set<Factors>()
        for event in events {
            switch event.kind {
            case .oobEnter, .oobExit: continue
            default: set.insert(Self.factor(for: event.kind))
            }
        }
        return set.sorted { $0.rawValue < $1.rawValue }
    }

    private var otherEvents: [ProgressiveCalendarEvent] {
        events.filter {
            switch $0.kind {
            case .oobEnter, .oobExit: return false
            default: return true
            }
        }
    }

    private var rowCount: Int {
        max(topRows.count + eventRows.count, 1)
    }

    private var canvasHeight: CGFloat {
        var height = topInset * 2
        if !topRows.isEmpty { height += CGFloat(topRows.count) * rowHeight }
        if !topRows.isEmpty && !eventRows.isEmpty { height += sectionGap }
        if !eventRows.isEmpty { height += CGFloat(eventRows.count) * rowHeight }
        return max(height, rowHeight + topInset * 2)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Canvas { context, size in
                drawAxis(context: context, size: size)
            }
            .frame(maxWidth: .infinity)
            .frame(height: axisHeight)
            .trackWidth($canvasWidth)
            .gesture(tapToSelectGesture)

            ScrollView(.vertical, showsIndicators: rowCount > maxVisibleRows) {
                Canvas { context, size in
                    draw(context: context, size: size)
                }
                .frame(maxWidth: .infinity)
                .frame(height: canvasHeight)
                .trackWidth($canvasWidth)
                .gesture(tapToSelectGesture)
            }
            .frame(maxHeight: min(canvasHeight, CGFloat(maxVisibleRows) * rowHeight + topInset * 2))

            if let selectedJD {
                Text(String(format: t(ProgressiveCalendarKeys.diagramSelectedDate), preciseDateTimeStr(selectedJD)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            legend
        }
    }

    private var tapToSelectGesture: some Gesture {
        SpatialTapGesture().onEnded { value in
            if let jd = jd(forX: value.location.x, width: canvasWidth) {
                selectedJD = jd
            }
        }
    }

    // MARK: - X-axis mapping (shared between the axis and the row canvas)

    private func x(for jd: Double, width: CGFloat) -> CGFloat {
        let plotWidth = width - leftLabelWidth
        guard plotWidth > 0, endJD > startJD else { return leftLabelWidth }
        let clamped = min(max(jd, startJD), endJD)
        return leftLabelWidth + CGFloat((clamped - startJD) / (endJD - startJD)) * plotWidth
    }

    /// Inverse of `x(for:width:)`: the Julian Day at a given x-position, clamped to
    /// `[startJD, endJD]`. Returns `nil` for a tap left of the plot area (over the row labels).
    private func jd(forX xPos: CGFloat, width: CGFloat) -> Double? {
        let plotWidth = width - leftLabelWidth
        guard plotWidth > 0, endJD > startJD, xPos >= leftLabelWidth else { return nil }
        let fraction = min(max(Double((xPos - leftLabelWidth) / plotWidth), 0.0), 1.0)
        return startJD + fraction * (endJD - startJD)
    }

    private var tickJDs: [Double] {
        guard endJD > startJD, tickCount > 1 else { return [startJD] }
        return (0..<tickCount).map { i in
            startJD + (endJD - startJD) * Double(i) / Double(tickCount - 1)
        }
    }

    private func dateLabel(_ jd: Double) -> String {
        let se = SEWrapper()
        let dt = se.dateFromJulianDay(jd)
        return String(format: "%04d/%02d/%02d", dt.Date.Year, dt.Date.Month, dt.Date.Day)
    }

    private func preciseDateTimeStr(_ jd: Double) -> String {
        let se = SEWrapper()
        let dt = se.dateFromJulianDay(jd)
        let sec = min(dt.Time.Second, 59)
        return String(format: "%04d/%02d/%02d %02d:%02d:%02d",
                      dt.Date.Year, dt.Date.Month, dt.Date.Day,
                      dt.Time.Hour, dt.Time.Minute, sec)
    }

    private func drawCrosshair(context: GraphicsContext, size: CGSize) {
        guard let selectedJD else { return }
        let crosshairX = x(for: selectedJD, width: size.width)
        var line = Path()
        line.move(to: CGPoint(x: crosshairX, y: 0))
        line.addLine(to: CGPoint(x: crosshairX, y: size.height))
        context.stroke(line, with: .color(.accentColor), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
    }

    // MARK: - Axis drawing

    private func drawAxis(context: GraphicsContext, size: CGSize) {
        guard size.width - leftLabelWidth > 0, endJD > startJD else { return }

        var baseline = Path()
        baseline.move(to: CGPoint(x: leftLabelWidth, y: axisHeight - 1))
        baseline.addLine(to: CGPoint(x: size.width, y: axisHeight - 1))
        context.stroke(baseline, with: .color(.primary.opacity(0.25)), lineWidth: 1)

        drawCrosshair(context: context, size: size)

        for (index, jd) in tickJDs.enumerated() {
            let tickX = x(for: jd, width: size.width)

            var tick = Path()
            tick.move(to: CGPoint(x: tickX, y: axisHeight - 5))
            tick.addLine(to: CGPoint(x: tickX, y: axisHeight - 1))
            context.stroke(tick, with: .color(.primary.opacity(0.4)), lineWidth: 1)

            let alignment: HorizontalAlignment = index == 0 ? .leading : (index == tickJDs.count - 1 ? .trailing : .center)
            let anchorX: CGFloat = alignment == .leading ? tickX + 2 : (alignment == .trailing ? tickX - 2 : tickX)
            context.draw(
                Text(dateLabel(jd)).font(.caption2).foregroundStyle(.secondary),
                at: CGPoint(x: anchorX, y: axisHeight / 2 - 3),
                anchor: alignment == .leading ? .leading : (alignment == .trailing ? .trailing : .center)
            )
        }
    }

    // MARK: - Rows drawing

    private func draw(context: GraphicsContext, size: CGSize) {
        guard size.width - leftLabelWidth > 0, endJD > startJD else { return }

        var rowTop = topInset

        for row in topRows {
            let midY = rowTop + rowHeight / 2
            drawBaseline(midY: midY, width: size.width, context: context)

            switch row {
            case .episode(let episode):
                context.draw(
                    Text(episodeLabelGlyphs(episode)).font(.custom("EnigmaAstrology3", size: 15)),
                    at: CGPoint(x: leftLabelWidth / 2, y: midY)
                )
                drawEpisode(episode, midY: midY, width: size.width, context: context)
            case .oob(let event):
                context.draw(
                    oobRowLabel(event),
                    at: CGPoint(x: 4, y: midY),
                    anchor: .leading
                )
                drawTick(event, midY: midY, x: x(for: event.jd, width: size.width), context: context)
            }
            rowTop += rowHeight
        }

        if !topRows.isEmpty && !eventRows.isEmpty {
            rowTop += sectionGap
        }

        for factor in eventRows {
            let midY = rowTop + rowHeight / 2
            drawBaseline(midY: midY, width: size.width, context: context)
            context.draw(
                Text(GlyphSelector.getGlyphForFactor(factor)).font(.custom("EnigmaAstrology3", size: 16)),
                at: CGPoint(x: leftLabelWidth / 2, y: midY)
            )
            for event in otherEvents where Self.factor(for: event.kind) == factor {
                let tickX = x(for: event.jd, width: size.width)
                drawTick(event, midY: midY, x: tickX, context: context)
                if let label = tickLabel(for: event.kind) {
                    context.draw(
                        Text(label).font(.system(size: 10, weight: .medium)).foregroundStyle(Self.eventColor(event.kind)),
                        at: CGPoint(x: tickX, y: midY - peakHalfHeight - 6)
                    )
                }
            }
            rowTop += rowHeight
        }

        drawCrosshair(context: context, size: size)
    }

    /// Factor glyph followed by the text "OOB" and a direction arrow, mixing the astrology
    /// glyph font with the system font in one `Text` (SwiftUI supports concatenating `Text`
    /// values with different fonts via `+`).
    private func oobRowLabel(_ event: ProgressiveCalendarEvent) -> Text {
        let arrow = { () -> String in
            if case .oobEnter = event.kind { return "\u{2191}" }
            return "\u{2193}"
        }()
        return Text(GlyphSelector.getGlyphForFactor(Self.factor(for: event.kind)))
            .font(.custom("EnigmaAstrology3", size: 15))
            + Text(" OOB" + arrow).font(.caption2)
    }

    private func drawBaseline(midY: CGFloat, width: CGFloat, context: GraphicsContext) {
        var baseline = Path()
        baseline.move(to: CGPoint(x: leftLabelWidth, y: midY))
        baseline.addLine(to: CGPoint(x: width, y: midY))
        context.stroke(baseline, with: .color(.primary.opacity(0.12)), lineWidth: 1)
    }

    private func episodeLabelGlyphs(_ episode: ProgressiveOrbEpisode) -> String {
        GlyphSelector.getGlyphForFactor(episode.factor1)
            + Self.episodeKindGlyph(episode.kind)
            + GlyphSelector.getGlyphForFactor(episode.factor2)
    }

    private func drawEpisode(_ episode: ProgressiveOrbEpisode, midY: CGFloat, width: CGFloat, context: GraphicsContext) {
        let leftX = x(for: episode.enterJD ?? startJD, width: width)
        let exactX = x(for: episode.exactJD, width: width)
        let rightX = x(for: episode.exitJD ?? endJD, width: width)

        let strength = episode.maxOrb > 0 ? max(0.0, min(1.0, 1.0 - episode.minOrb / episode.maxOrb)) : 1.0
        let peak = peakHalfHeight * CGFloat(strength)
        let leftHeight: CGFloat = episode.enterJD == nil ? peak : 0
        let rightHeight: CGFloat = episode.exitJD == nil ? peak : 0

        var path = Path()
        path.move(to: CGPoint(x: leftX, y: midY - leftHeight))
        path.addLine(to: CGPoint(x: exactX, y: midY - peak))
        path.addLine(to: CGPoint(x: rightX, y: midY - rightHeight))
        path.addLine(to: CGPoint(x: rightX, y: midY + rightHeight))
        path.addLine(to: CGPoint(x: exactX, y: midY + peak))
        path.addLine(to: CGPoint(x: leftX, y: midY + leftHeight))
        path.closeSubpath()

        let color = Self.episodeColor(episode.kind)
        context.fill(path, with: .color(color.opacity(0.55)))
        context.stroke(path, with: .color(color), lineWidth: 1)
    }

    private func drawTick(_ event: ProgressiveCalendarEvent, midY: CGFloat, x: CGFloat, context: GraphicsContext) {
        var tick = Path()
        tick.move(to: CGPoint(x: x, y: midY - peakHalfHeight))
        tick.addLine(to: CGPoint(x: x, y: midY + peakHalfHeight))
        let color = Self.eventColor(event.kind)
        context.stroke(tick, with: .color(color), lineWidth: 2)
        context.fill(Path(ellipseIn: CGRect(x: x - 2.5, y: midY - 2.5, width: 5, height: 5)), with: .color(color))
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: 14) {
            legendItem(color: .cyan, label: "∥ parallel")
            legendItem(color: .indigo, label: "∦ contra-parallel")
            legendItem(color: .orange, label: "Rx/D station")
            legendItem(color: .red, label: "OOB")
            legendItem(color: .green, label: "\u{00B1}Decl")
            legendItem(color: .gray, label: "Cnj cusp")
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 3) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label)
        }
    }

    /// Small text label drawn above a bottom-section tick, or `nil` for kinds that don't get
    /// one (OOB is unlabeled here — it now lives in the top section anyway). "R"/"D" mark the
    /// start and end of a retrograde period (the station where the planet turns retrograde,
    /// and the station where it turns direct again); "+"/"-" mark a maximum declination to the
    /// north/south, "o" marks a zero-declination crossing; the cusp code matches
    /// `ProgressiveCalendarResultsScreen`'s table labeling — plain astrological shorthand, not
    /// localized (same convention as "Rx"/"D" there).
    private func tickLabel(for kind: ProgressiveCalendarEventKind) -> String? {
        switch kind {
        case .retrogradeStation: return "R"
        case .directStation: return "D"
        case .zeroDeclination: return "o"
        case .maxDeclination(_, let isNorthern): return isNorthern ? "+" : "-"
        case .cuspConjunction(_, let cusp):
            switch cusp {
            case .house(let number): return "H\(number)"
            case .ascendant: return "ASC"
            case .midheaven: return "MC"
            case .eastpoint: return "EP"
            case .vertex: return "VX"
            }
        case .oobEnter, .oobExit:
            return nil
        }
    }

    // MARK: - Row / color / glyph mapping

    private static func factor(for kind: ProgressiveCalendarEventKind) -> Factors {
        switch kind {
        case .cuspConjunction(let factor, _): return factor
        case .retrogradeStation(let factor): return factor
        case .directStation(let factor): return factor
        case .oobEnter(let factor): return factor
        case .oobExit(let factor): return factor
        case .zeroDeclination(let factor): return factor
        case .maxDeclination(let factor, _): return factor
        }
    }

    private static func episodeKindGlyph(_ kind: ProgressiveOrbEpisodeKind) -> String {
        switch kind {
        case .aspectToRadix(let aspect), .aspectProgToProg(let aspect):
            return GlyphSelector.getGlyphForAspect(aspect)
        case .parallelToRadix, .parallelProgToProg:
            return "\u{F000}"
        case .contraParallelToRadix, .contraParallelProgToProg:
            return "\u{F010}"
        }
    }

    private static func episodeColor(_ kind: ProgressiveOrbEpisodeKind) -> Color {
        switch kind {
        case .aspectToRadix(let aspect), .aspectProgToProg(let aspect):
            return Color(AspectSettings.defaultColor(for: aspect))
        case .parallelToRadix, .parallelProgToProg:
            return .cyan
        case .contraParallelToRadix, .contraParallelProgToProg:
            return .indigo
        }
    }

    private static func eventColor(_ kind: ProgressiveCalendarEventKind) -> Color {
        switch kind {
        case .cuspConjunction: return .gray
        case .retrogradeStation, .directStation: return .orange
        case .oobEnter, .oobExit: return .red
        case .zeroDeclination, .maxDeclination: return .green
        }
    }
}

// MARK: - Width tracking

private extension View {
    /// Reports this view's own rendered width into `width`, without affecting layout —
    /// used so a tap's x-location can be converted back into a Julian Day using the exact
    /// same width the Canvas last drew with.
    func trackWidth(_ width: Binding<CGFloat>) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { width.wrappedValue = geo.size.width }
                    .onChange(of: geo.size.width) { _, newWidth in width.wrappedValue = newWidth }
            }
        )
    }
}
