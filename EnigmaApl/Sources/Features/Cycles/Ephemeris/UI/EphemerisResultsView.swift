// EphemerisResultsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Charts
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif

private func e(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Ephemeris", bundle: .main, comment: "")
}

// Tracks the vertical scroll offset of the factor-columns scroll view so the
// pinned day column can mirror it without being inside the same scroll view.
private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#if os(macOS)
// NSScrollView wrapper with permanently-visible scrollbars so a regular mouse
// can grab either scrollbar without first touching the trackpad.
// Frame-based (no Auto Layout): updateNSView sets host.frame from fittingSize
// so NSScrollView always knows the true document extent and can scroll.
private struct PermanentScrollView<Content: View>: NSViewRepresentable {
    let content: Content
    let onScroll: (CGFloat) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onScroll: onScroll) }

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSScrollView()
        scroll.hasVerticalScroller   = true
        scroll.hasHorizontalScroller = true
        scroll.autohidesScrollers    = false
        scroll.scrollerStyle         = .legacy   // force always-visible track+knob scrollbars
        scroll.drawsBackground       = false
        scroll.borderType            = .noBorder

        let host = NSHostingView(rootView: content)
        scroll.documentView = host

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.didScroll(_:)),
            name: NSScrollView.didLiveScrollNotification,
            object: scroll
        )
        return scroll
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        if let host = nsView.documentView as? NSHostingView<Content> {
            host.rootView = content
        }
        context.coordinator.onScroll = onScroll
        // Defer so SwiftUI finishes laying out the hosted content before we
        // read fittingSize.  Without the deferral the size is still zero and
        // NSScrollView sees no scrollable extent, keeping the knobs at full
        // size and preventing any scrolling.
        DispatchQueue.main.async {
            guard let host = nsView.documentView as? NSHostingView<Content> else { return }
            let size = host.fittingSize
            if size.width > 0 && size.height > 0 && host.frame.size != size {
                host.frame = CGRect(origin: .zero, size: size)
            }
        }
    }

    final class Coordinator: NSObject {
        var onScroll: (CGFloat) -> Void
        init(onScroll: @escaping (CGFloat) -> Void) { self.onScroll = onScroll }
        deinit { NotificationCenter.default.removeObserver(self) }

        @objc func didScroll(_ notification: Notification) {
            guard let scroll = notification.object as? NSScrollView else { return }
            onScroll(scroll.contentView.bounds.origin.y)
        }
    }
}
#endif

struct EphemerisResultsView: View {
    @EnvironmentObject private var model: EphemerisModel

    private var monthYearString: String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        guard let date = cal.date(from: DateComponents(year: model.year, month: model.month, day: 1)) else {
            return "\(model.month) \(model.year)"
        }
        return formatter.string(from: date)
    }

    private var subtitleString: String {
        [e(EphemerisKeys.coordinateKey(for: model.selectedCoordinate)),
         NSLocalizedString(model.observerPosition.rbKey, comment: ""),
         NSLocalizedString(model.ayanamsha.rbKey, comment: "")]
            .joined(separator: " • ")
    }

    var body: some View {
        if model.rows.isEmpty || model.selectedFactors.isEmpty {
            Text(e(EphemerisKeys.noResults))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: 0) {
                VStack(spacing: 2) {
                    Text(monthYearString)
                        .font(.headline)
                    Text(subtitleString)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                TabView {
                    EphemerisTableView()
                        .tabItem { Text(e(EphemerisKeys.tabTable)) }
                    EphemerisGraphView()
                        .tabItem { Text(e(EphemerisKeys.tabGraph)) }
                }
            }
        }
    }
}

// MARK: - Table

private struct EphemerisTableView: View {
    @EnvironmentObject private var model: EphemerisModel

    private let dayColWidth: CGFloat   = 44
    private let valueColWidth: CGFloat = 130
    private let cellPadH: CGFloat      = 6
    // Explicit fixed height keeps the header row identical in both columns.
    private let headerHeight: CGFloat  = 32
    private let rowPadV: CGFloat       = 3

    private var dayColTotalWidth: CGFloat { dayColWidth + 2 * cellPadH }

    // The calculator appends one extra row (first day of next month) so the
    // graph line always has a real endpoint. The table shows only real days.
    private var displayRows: [EphemerisRow] { Array(model.rows.dropLast()) }

    @State private var verticalScrollOffset: CGFloat = 0

    private var monthYearString: String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        guard let date = cal.date(from: DateComponents(year: model.year, month: model.month, day: 1)) else {
            return "\(model.month) \(model.year)"
        }
        return formatter.string(from: date)
    }

    private var subtitleString: String {
        [e(EphemerisKeys.coordinateKey(for: model.selectedCoordinate)),
         NSLocalizedString(model.observerPosition.rbKey, comment: ""),
         NSLocalizedString(model.ayanamsha.rbKey, comment: "")]
            .joined(separator: " • ")
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(e(EphemerisKeys.exportPDF)) { exportTablePDF() }
                    .buttonStyle(.bordered)
                    .padding([.top, .trailing])
            }
            tableContent
        }
    }

    private var tableContent: some View {
        // GeometryReader gives the real viewport size.  The HStack distributes
        // that width between the pinned day column and the biaxial scroll view,
        // so both scroll indicators sit at the viewport edges (horizontal bar
        // always at the bottom, reachable by dragging with any mouse).
        GeometryReader { proxy in
            HStack(alignment: .top, spacing: 0) {
                // ── Pinned day column ────────────────────────────────────────
                // Never participates in horizontal scrolling.  Content is
                // shifted vertically by the tracked scroll offset so rows stay
                // aligned with the adjacent factor columns.
                dayColumn
                    .offset(y: -verticalScrollOffset)
                    .frame(width: dayColTotalWidth,
                           height: proxy.size.height,
                           alignment: .top)
                    .clipped()
                    #if os(macOS)
                    .background(Color(NSColor.windowBackgroundColor))
                    #else
                    .background(Color(UIColor.systemBackground))
                    #endif

                Rectangle()
                    .fill(Color.primary.opacity(0.3))
                    .frame(width: 1)

                // ── Factor columns: biaxial scroll ───────────────────────────
                // fixedSize(both axes) forces the VStack to use its natural
                // size so the scroll view never centers it vertically.
                #if os(macOS)
                // PermanentScrollView keeps scrollbars always visible so a
                // regular mouse can grab the horizontal bar without needing
                // a trackpad interaction first.  Vertical offset is tracked
                // via NSScrollView notification instead of PreferenceKey.
                PermanentScrollView(content: factorContent, onScroll: { offset in
                    verticalScrollOffset = offset
                })
                .frame(height: proxy.size.height)
                #else
                ScrollView([.horizontal, .vertical]) {
                    factorContent
                }
                .defaultScrollAnchor(.topLeading)
                .coordinateSpace(name: "tableScroll")
                .onPreferenceChange(ScrollOffsetKey.self) { offset in
                    verticalScrollOffset = offset
                }
                .scrollIndicators(.visible)
                .frame(height: proxy.size.height)
                #endif
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    // MARK: - Fixed day column

    private var dayColumn: some View {
        VStack(spacing: 0) {
            Text(e(EphemerisKeys.dateHeader))
                .fontWeight(.semibold)
                .frame(width: dayColWidth, alignment: .center)
                .frame(height: headerHeight)
                .padding(.horizontal, cellPadH)
                .background(Color.primary.opacity(0.10))
            Divider()
            ForEach(displayRows) { row in
                Text(String(format: "%02d", row.id))
                    .frame(width: dayColWidth, alignment: .center)
                    .padding(.horizontal, cellPadH)
                    .padding(.vertical, rowPadV)
                    .background(row.id % 2 == 0 ? Color.primary.opacity(0.06) : Color.clear)
            }
        }
        .font(.system(.body, design: .monospaced))
        .frame(width: dayColTotalWidth)
    }

    // MARK: - Factor content (shared between macOS and non-macOS scroll wrappers)

    // fixedSize on both axes: forces the VStack to its natural size so the
    // scroll view never decides to center it when content < viewport height.
    private var factorContent: some View {
        factorColumns
            .fixedSize(horizontal: true, vertical: true)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetKey.self,
                        value: -geo.frame(in: .named("tableScroll")).origin.y
                    )
                }
            )
    }

    // MARK: - Scrollable factor columns

    private var factorColumns: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(model.selectedFactors, id: \.rawValue) { factor in
                    Text(GlyphSelector.getGlyphForFactor(factor))
                        .font(.custom("EnigmaAstrology3", size: 16))
                        .fontWeight(.semibold)
                        .frame(width: valueColWidth, alignment: .trailing)
                        .frame(height: headerHeight)
                        .padding(.horizontal, cellPadH)
                }
            }
            .background(Color.primary.opacity(0.10))
            Divider()
            ForEach(displayRows) { row in
                HStack(spacing: 0) {
                    ForEach(model.selectedFactors, id: \.rawValue) { factor in
                        formattedCell(row: row, factor: factor)
                            .frame(width: valueColWidth, alignment: .trailing)
                            .padding(.horizontal, cellPadH)
                            .padding(.vertical, rowPadV)
                    }
                }
                .font(.system(.body, design: .monospaced))
                .background(row.id % 2 == 0 ? Color.primary.opacity(0.06) : Color.clear)
            }
        }
    }

    // MARK: - Cell formatting

    @ViewBuilder
    private func formattedCell(row: EphemerisRow, factor: Factors) -> some View {
        if let value = row.value(for: factor, coordinate: model.selectedCoordinate) {
            if model.selectedCoordinate == .longitude {
                let (dms, sign, _) = PositionInDegreesConversion.DoubleToDmsSign(value)
                if let sign = sign {
                    Text(dms)
                    + Text(" \(GlyphSelector.getGlyphForSign(sign))")
                        .font(.custom("EnigmaAstrology3", size: 12))
                } else {
                    Text(dms)
                }
            } else if model.selectedCoordinate == .distance {
                Text(String(format: "%.5f", value))
            } else {
                Text(PositionInDegreesConversion.DoubleToDms(value))
            }
        } else {
            Text("—")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Export

    @MainActor
    private func exportTablePDF() {
        let colW = valueColWidth + 2 * cellPadH
        let contentWidth = 2 * 16 + dayColTotalWidth + CGFloat(model.selectedFactors.count) * colW
        let printView = EphemerisTablePrintContent(
            rows: displayRows,
            factors: model.selectedFactors,
            coordinate: model.selectedCoordinate,
            title: monthYearString,
            subtitle: subtitleString
        )
        .frame(width: contentWidth)
        guard let data = ephemerisMakePDF(printView, width: contentWidth) else { return }
        let filename = "Ephemeris_\(model.year)_\(String(format: "%02d", model.month)).pdf"
        ephemerisSave(data: data, filename: filename, contentType: .pdf)
    }
}

// MARK: - Graph

private struct EphemerisGraphView: View {
    @EnvironmentObject private var model: EphemerisModel

    @State private var chartHeight: CGFloat = 400
    @State private var dragStartHeight: CGFloat = 400
    @State private var xPrePad: Int = 1

    private var monthYearString: String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        guard let date = cal.date(from: DateComponents(year: model.year, month: model.month, day: 1)) else {
            return "\(model.month) \(model.year)"
        }
        return formatter.string(from: date)
    }

    private var subtitleString: String {
        [e(EphemerisKeys.coordinateKey(for: model.selectedCoordinate)),
         NSLocalizedString(model.observerPosition.rbKey, comment: ""),
         NSLocalizedString(model.ayanamsha.rbKey, comment: "")]
            .joined(separator: " • ")
    }

    private let chartColors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .teal, .cyan, .mint, .indigo, .brown, .yellow
    ]

    private var factorColors: [(factor: Factors, color: Color)] {
        Array(zip(model.selectedFactors, chartColors.cycled(to: model.selectedFactors.count)))
            .map { (factor: $0.0, color: $0.1) }
    }

    private struct DayPoint: Identifiable {
        let id: String
        let day: Int
        let value: Double
        let segment: Int
        let color: Color
    }

    private var chartPoints: [(factor: Factors, color: Color, points: [DayPoint])] {
        let isAngular = model.selectedCoordinate == .longitude || model.selectedCoordinate == .rightAscension
        return factorColors.map { item in
            // model.rows includes one extra row (first day of next month) so
            // the last real day is always part of a ≥2-point segment.
            // Carry row.id alongside the value so skipped-nil rows don't corrupt
            // the day-number mapping (compactMap on values alone shifts all indices).
            let pairs: [(day: Int, value: Double)] = model.rows.compactMap { row in
                guard let val = row.value(for: item.factor, coordinate: model.selectedCoordinate)
                else { return nil }
                return (day: row.id, value: val)
            }
            var segments = [Int](repeating: 0, count: pairs.count)
            if isAngular && pairs.count > 1 {
                var seg = 0
                for i in 1..<pairs.count {
                    if abs(pairs[i].value - pairs[i - 1].value) > 180.0 { seg += 1 }
                    segments[i] = seg
                }
            }
            let points: [DayPoint] = pairs.enumerated().map { i, pair in
                DayPoint(
                    id: "\(item.factor.rawValue)-\(pair.day)-\(segments[i])",
                    day: pair.day,
                    value: pair.value,
                    segment: segments[i],
                    color: item.color
                )
            }
            return (factor: item.factor, color: item.color, points: points)
        }
    }

    private var yAxisStride: Double {
        switch model.selectedCoordinate {
        case .longitude, .rightAscension: return 10.0
        case .declination: return 2.0
        case .latitude, .speedLongitude, .speedDeclination: return 1.0
        case .distance: return 1.0
        }
    }

    private struct GlyphPlacement {
        let factor: Factors
        let color: Color
        let x: CGFloat
        let y: CGFloat
    }

    /// Actual number of days in the selected month, computed directly from
    /// Calendar so the graph is correct even if the calculator row count is off.
    private var daysInMonth: Int {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        guard let date = cal.date(from: DateComponents(year: model.year, month: model.month, day: 1)),
              let range = cal.range(of: .day, in: .month, for: date) else { return 31 }
        return range.count
    }

    private var chartXDomain: ClosedRange<Int> {
        // Extend two units beyond the last real day: one for the axis-mark
        // breathing room (Swift Charts clips marks at the exact boundary), and
        // one more so the sentinel row (id = daysInMonth+1) is also not at the
        // boundary and its line segment is fully rendered.
        (1 - xPrePad)...(daysInMonth + 2)
    }

    /// Y domain anchored at 0 so grid lines start from 0°, not from the data minimum.
    private var chartYDomain: ClosedRange<Double> {
        let allValues = chartPoints.flatMap { $0.points.map(\.value) }
        guard !allValues.isEmpty else { return 0...1 }
        let dataMin = allValues.min()!
        let dataMax = allValues.max()!
        let yMin = min(0.0, dataMin)
        let yMax = dataMax > yMin ? dataMax : yMin + 1
        return yMin...yMax
    }

    private func glyphPlacements(proxy: ChartProxy, geo: GeometryProxy) -> [GlyphPlacement] {
        let size: CGFloat = 14
        let glyphPx: CGFloat = 12
        let plotFrame = geo[proxy.plotAreaFrame]

        // Skip until layout is complete — avoid division by zero in neededPad.
        guard plotFrame.width > 0,
              let day1Pos = proxy.position(forX: 1) else { return [] }

        // Pixel x of day 1 within the overlay's coordinate space.
        let day1X = plotFrame.minX + day1Pos

        // Get the view-y at each factor's actual line-start value.
        var items: [(factor: Factors, color: Color, y: CGFloat)] = chartPoints.compactMap { item in
            guard let first = item.points.first,
                  let yPos = proxy.position(forY: first.value) else { return nil }
            return (factor: item.factor, color: item.color, y: plotFrame.minY + yPos)
        }
        items.sort { $0.y < $1.y }

        var result: [GlyphPlacement] = []
        var maxCluster = 1
        var i = 0
        while i < items.count {
            var end = i + 1
            while end < items.count && (items[end].y - items[i].y) < size { end += 1 }
            let group = Array(items[i..<end])
            maxCluster = max(maxCluster, group.count)

            let clusterY = group.count == 1 ? group[0].y
                         : group.map(\.y).reduce(0, +) / CGFloat(group.count)

            for (k, item) in group.enumerated() {
                // Place inside the plot area, to the left of day 1.
                // k = group.count-1 is the rightmost glyph (closest to day 1).
                let x = day1X - glyphPx / 2 - CGFloat(group.count - 1 - k) * glyphPx
                result.append(GlyphPlacement(
                    factor: item.factor, color: item.color,
                    x: x,
                    y: clusterY
                ))
            }
            i = end
        }

        // Extend the x-domain left so glyphs stay within the plot area.
        let dayWidth = plotFrame.width / CGFloat(daysInMonth)
        let neededPad = max(1, Int(ceil(CGFloat(maxCluster) * glyphPx / dayWidth)) + 1)
        if neededPad != xPrePad {
            DispatchQueue.main.async { xPrePad = neededPad }
        }

        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button(e(EphemerisKeys.exportPDF)) { exportChartPDF() }
                    .buttonStyle(.bordered)
                Button(e(EphemerisKeys.exportPNG)) { exportChartPNG() }
                    .buttonStyle(.bordered)
            }
            .padding([.top, .trailing])

            Chart {
                ForEach(chartPoints, id: \.factor.rawValue) { item in
                    ForEach(item.points) { point in
                        LineMark(
                            x: .value(e(EphemerisKeys.dateHeader), point.day),
                            y: .value("", point.value),
                            series: .value("", "\(item.factor.rawValue)-\(point.segment)")
                        )
                        .foregroundStyle(item.color)
                    }
                }
            }
            .chartLegend(.hidden)
            .chartXScale(domain: chartXDomain)
            .chartXAxis {
                // Explicit values for real days only — avoids stride iterating over
                // the negative-day glyph slots and guarantees every day gets a mark.
                // Small font (size 9) keeps two-digit labels from overlapping.
                AxisMarks(values: Array(1...daysInMonth)) { value in
                    if let day = value.as(Int.self) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\(day)")
                                .font(.system(size: 9))
                        }
                    }
                }
            }
            .chartYScale(domain: chartYDomain)
            .chartYAxis {
                AxisMarks(values: .stride(by: yAxisStride)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    let placements = glyphPlacements(proxy: proxy, geo: geo)
                    ZStack {
                        ForEach(placements, id: \.factor.rawValue) { pos in
                            Text(GlyphSelector.getGlyphForFactor(pos.factor))
                                .font(.custom("EnigmaAstrology3", size: 12))
                                .foregroundStyle(pos.color)
                                .position(x: pos.x, y: pos.y)
                        }
                    }
                }
            }
            .frame(height: chartHeight)
            .padding([.horizontal, .top])

            resizeHandle

            legendArea
                .padding([.horizontal, .bottom])
        }
    }

    private var legendArea: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
            ForEach(factorColors, id: \.factor.rawValue) { item in
                HStack(spacing: 4) {
                    Text(GlyphSelector.getGlyphForFactor(item.factor))
                        .font(.custom("EnigmaAstrology3", size: 14))
                        .foregroundStyle(item.color)
                    Text(NSLocalizedString(item.factor.localizedName, comment: ""))
                        .font(.caption)
                        .foregroundStyle(item.color)
                    Spacer()
                }
            }
        }
    }

    private var resizeHandle: some View {
        VStack(spacing: 3) {
            Divider()
            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { _ in
                    Circle()
                        .fill(Color.secondary.opacity(0.5))
                        .frame(width: 4, height: 4)
                }
            }
            Divider()
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { value in
                    chartHeight = max(150, dragStartHeight + value.translation.height)
                }
                .onEnded { _ in
                    dragStartHeight = chartHeight
                }
        )
        #if os(macOS)
        .onHover { inside in
            if inside { NSCursor.resizeUpDown.push() } else { NSCursor.pop() }
        }
        #endif
    }

    // MARK: - Export

    @MainActor
    private func exportChartPDF() {
        let content = chartExportContent.frame(width: 900)
        guard let data = ephemerisMakePDF(content, width: 900) else { return }
        let filename = "Ephemeris_\(model.year)_\(String(format: "%02d", model.month))_chart.pdf"
        ephemerisSave(data: data, filename: filename, contentType: .pdf)
    }

    @MainActor
    private func exportChartPNG() {
        let content = chartExportContent.frame(width: 900)
        guard let data = ephemerisMakePNG(content, width: 900, height: 600) else { return }
        let filename = "Ephemeris_\(model.year)_\(String(format: "%02d", model.month))_chart.png"
        ephemerisSave(data: data, filename: filename, contentType: .png)
    }

    @ViewBuilder
    private var chartExportContent: some View {
        let pts    = chartPoints
        let days   = daysInMonth
        let xDom   = chartXDomain
        let yDom   = chartYDomain
        let stride = yAxisStride
        let fc     = factorColors
        let mTitle = monthYearString
        let mSub   = subtitleString

        VStack(alignment: .leading, spacing: 8) {
            VStack(spacing: 2) {
                Text(mTitle).font(.headline)
                Text(mSub).font(.subheadline).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Chart {
                ForEach(pts, id: \.factor.rawValue) { item in
                    ForEach(item.points) { point in
                        LineMark(
                            x: .value(e(EphemerisKeys.dateHeader), point.day),
                            y: .value("", point.value),
                            series: .value("", "\(item.factor.rawValue)-\(point.segment)")
                        )
                        .foregroundStyle(item.color)
                    }
                }
            }
            .chartLegend(.hidden)
            .chartXScale(domain: xDom)
            .chartXAxis {
                AxisMarks(values: Array(1...days)) { value in
                    if let day = value.as(Int.self) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel { Text("\(day)").font(.system(size: 9)) }
                    }
                }
            }
            .chartYScale(domain: yDom)
            .chartYAxis {
                AxisMarks(values: .stride(by: stride)) { _ in
                    AxisGridLine(); AxisTick(); AxisValueLabel()
                }
            }
            .frame(height: 450)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
                ForEach(fc, id: \.factor.rawValue) { item in
                    HStack(spacing: 4) {
                        Text(GlyphSelector.getGlyphForFactor(item.factor))
                            .font(.custom("EnigmaAstrology3", size: 14))
                            .foregroundStyle(item.color)
                        Text(NSLocalizedString(item.factor.localizedName, comment: ""))
                            .font(.caption)
                            .foregroundStyle(item.color)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background {
            #if os(macOS)
            Color(NSColor.windowBackgroundColor)
            #else
            Color(UIColor.systemBackground)
            #endif
        }
    }
}

// MARK: - Table print layout

private struct EphemerisTablePrintContent: View {
    let rows: [EphemerisRow]
    let factors: [Factors]
    let coordinate: EphemerisCoordinate
    let title: String
    let subtitle: String

    private let dayW: CGFloat    = 44
    private let valueW: CGFloat  = 130
    private let padH: CGFloat    = 6
    private let rowPadV: CGFloat = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 12)

            HStack(spacing: 0) {
                Text("Day")
                    .fontWeight(.semibold)
                    .frame(width: dayW, alignment: .center)
                    .padding(.horizontal, padH)
                ForEach(factors, id: \.rawValue) { factor in
                    Text(GlyphSelector.getGlyphForFactor(factor))
                        .font(.custom("EnigmaAstrology3", size: 14))
                        .fontWeight(.semibold)
                        .frame(width: valueW, alignment: .trailing)
                        .padding(.horizontal, padH)
                }
            }
            .background(Color.primary.opacity(0.10))
            Divider()

            ForEach(rows) { row in
                HStack(spacing: 0) {
                    Text(String(format: "%02d", row.id))
                        .frame(width: dayW, alignment: .center)
                        .padding(.horizontal, padH)
                        .padding(.vertical, rowPadV)
                    ForEach(factors, id: \.rawValue) { factor in
                        printCell(row: row, factor: factor)
                            .frame(width: valueW, alignment: .trailing)
                            .padding(.horizontal, padH)
                            .padding(.vertical, rowPadV)
                    }
                }
                .font(.system(.body, design: .monospaced))
                .background(row.id % 2 == 0 ? Color.primary.opacity(0.06) : Color.clear)
            }
        }
        .padding()
        .background(Color.white)
    }

    @ViewBuilder
    private func printCell(row: EphemerisRow, factor: Factors) -> some View {
        if let value = row.value(for: factor, coordinate: coordinate) {
            if coordinate == .longitude {
                let (dms, sign, _) = PositionInDegreesConversion.DoubleToDmsSign(value)
                if let sign = sign {
                    Text(dms)
                    + Text(" \(GlyphSelector.getGlyphForSign(sign))")
                        .font(.custom("EnigmaAstrology3", size: 10))
                } else {
                    Text(dms)
                }
            } else if coordinate == .distance {
                Text(String(format: "%.5f", value))
            } else {
                Text(PositionInDegreesConversion.DoubleToDms(value))
            }
        } else {
            Text("—").foregroundStyle(.secondary)
        }
    }
}

// MARK: - Export helpers

@MainActor
private func ephemerisMakePDF<V: View>(_ view: V, width: CGFloat) -> Data? {
    let renderer = ImageRenderer(content: view)
    renderer.proposedSize = ProposedViewSize(width: width, height: nil)
    renderer.scale = 2.0
    guard let cgImage = renderer.cgImage else { return nil }
    let size = CGSize(width: CGFloat(cgImage.width) / renderer.scale,
                      height: CGFloat(cgImage.height) / renderer.scale)
    let mutableData = NSMutableData()
    guard let consumer = CGDataConsumer(data: mutableData as CFMutableData) else { return nil }
    var box = CGRect(origin: .zero, size: size)
    guard let ctx = CGContext(consumer: consumer, mediaBox: &box, nil) else { return nil }
    ctx.beginPDFPage(nil)
    ctx.draw(cgImage, in: box)
    ctx.endPDFPage()
    ctx.closePDF()
    let data = mutableData as Data
    return data.isEmpty ? nil : data
}

@MainActor
private func ephemerisMakePNG<V: View>(_ view: V, width: CGFloat, height: CGFloat) -> Data? {
    let renderer = ImageRenderer(content: view)
    renderer.proposedSize = ProposedViewSize(width: width, height: height)
    renderer.scale = 2.0
    #if os(macOS)
    guard let nsImage = renderer.nsImage,
          let tiff = nsImage.tiffRepresentation,
          let rep  = NSBitmapImageRep(data: tiff) else { return nil }
    return rep.representation(using: .png, properties: [:])
    #else
    return renderer.uiImage?.pngData()
    #endif
}

#if os(macOS)
@MainActor
private func ephemerisSave(data: Data, filename: String, contentType: UTType) {
    let panel = NSSavePanel()
    panel.allowedContentTypes  = [contentType]
    panel.nameFieldStringValue = filename
    panel.directoryURL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask).first
    panel.canCreateDirectories = true
    if let window = NSApp.keyWindow {
        panel.beginSheetModal(for: window) { response in
            guard response == .OK, let url = panel.url else { return }
            try? data.write(to: url)
        }
    } else {
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            try? data.write(to: url)
        }
    }
}
#else
@MainActor
private func ephemerisSave(data: Data, filename: String, contentType: UTType) {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
    try? data.write(to: url)
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let root  = scene.keyWindow?.rootViewController else { return }
    let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    root.present(activity, animated: true)
}
#endif

// MARK: - Array helper

private extension Array {
    func cycled(to count: Int) -> [Element] {
        guard !self.isEmpty else { return [] }
        return (0..<count).map { self[$0 % self.count] }
    }
}
