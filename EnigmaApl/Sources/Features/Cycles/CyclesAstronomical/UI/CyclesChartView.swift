// CyclesChartView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Charts
import UniformTypeIdentifiers

struct CyclesChartView: View {
    @EnvironmentObject private var model: AstronomicalCyclesModel

    @State private var chartHeight: CGFloat = 400
    @State private var dragStartHeight: CGFloat = 400
    @State private var selectedTab: Int = 0
    @State private var showDms: Bool = true
    @State private var chartWidth: CGFloat = 0

    var body: some View {
        if model.hasResults {
            TabView(selection: $selectedTab) {
                chartTab
                    .tabItem { Text(ac(AstroCyclesKeys.tabChart)) }
                    .tag(0)
                positionsTab
                    .tabItem { Text(ac(AstroCyclesKeys.tabPositions)) }
                    .tag(1)
            }
        } else {
            Text(ac(AstroCyclesKeys.chartNoResults))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Chart tab

    private var chartTab: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(ac(AstroCyclesKeys.chartExport)) {
                    if let data = renderChartToPNG() {
                        #if os(macOS)
                        savePanel(data: data, defaultName: "astronomical_cycles.png", ext: "png")
                        #endif
                    }
                }
                .buttonStyle(.bordered)
                .padding([.top, .trailing])
            }

            Group {
                if model.isPairs {
                    pairsChart
                } else {
                    singleChart
                }
            }
            .frame(height: chartHeight)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { chartWidth = geo.size.width }
                        .onChange(of: geo.size.width) { chartWidth = $0 }
                }
            )
            .padding([.horizontal, .top])

            resizeHandle
        }
    }

    #if os(macOS)
    private func savePanel(data: Data, defaultName: String, ext: String) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = defaultName
        panel.allowedContentTypes = ext == "png" ? [.png] : [.commaSeparatedText]
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            try? data.write(to: url)
        }
    }
    #endif

    @MainActor
    private func renderChartToPNG() -> Data? {
        let exportWidth = exportChartWidth
        #if os(macOS)
        let bgColor = Color(nsColor: .windowBackgroundColor)
        #else
        let bgColor = Color(uiColor: .systemBackground)
        #endif
        let chartView = model.isPairs
            ? buildPairsChart()
            : buildSingleChart()
        let content = chartView
            .frame(width: exportWidth, height: chartHeight)
            .background(bgColor)
        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = .init(width: exportWidth, height: chartHeight)
        renderer.scale = 2.0
        #if os(macOS)
        guard let cgImage = renderer.cgImage else { return nil }
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .png, properties: [:])
        #else
        return renderer.uiImage?.pngData()
        #endif
    }

    // MARK: - Positions tab

    private struct PositionRow: Identifiable {
        let id: Int
        let julianDay: Double
        let values: [Double]
    }

    private var positionRows: [PositionRow] {
        if model.isPairs {
            guard let firstSeries = model.pairResults.first else { return [] }
            return firstSeries.indices.map { i in
                let jd = firstSeries[i].julianDay
                let values = model.pairResults.map { $0.count > i ? $0[i].difference : 0.0 }
                return PositionRow(id: i, julianDay: jd, values: values)
            }
        } else {
            guard let firstResult = model.singleResults.first else { return [] }
            return firstResult.series.indices.map { i in
                let jd = firstResult.series[i].julianDay
                let values = model.singleResults.map { $0.series.count > i ? $0.series[i].position : 0.0 }
                return PositionRow(id: i, julianDay: jd, values: values)
            }
        }
    }

    private var columnHeaders: [String] {
        if model.isPairs {
            return model.factorPairs.map { pair in
                let n1 = NSLocalizedString(pair.factor1.localizedName, comment: "")
                let n2 = NSLocalizedString(pair.factor2.localizedName, comment: "")
                return "\(n1) – \(n2)"
            }
        } else {
            return model.singleResults.map { NSLocalizedString($0.factor.localizedName, comment: "") }
        }
    }

    private let dateColWidth: CGFloat  = 100
    private let jdColWidth: CGFloat    = 130
    private let valueColWidth: CGFloat = 120

    private var positionsTab: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(ac(AstroCyclesKeys.positionsExport)) {
                    let csv = buildCSV()
                    if let data = csv.data(using: .utf8) {
                        #if os(macOS)
                        savePanel(data: data, defaultName: "astronomical_cycles.csv", ext: "csv")
                        #endif
                    }
                }
                .buttonStyle(.bordered)
                .padding([.top, .leading])

                Spacer()

                Picker("", selection: $showDms) {
                    Text(ac(AstroCyclesKeys.positionsFormatDms)).tag(true)
                    Text(ac(AstroCyclesKeys.positionsFormatDecimal)).tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
                .padding([.top, .trailing])
            }

            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text(ac(AstroCyclesKeys.chartDate))
                            .fontWeight(.semibold)
                            .frame(width: dateColWidth, alignment: .leading)
                        Text(ac(AstroCyclesKeys.positionsJulianDay))
                            .fontWeight(.semibold)
                            .frame(width: jdColWidth, alignment: .leading)
                        ForEach(columnHeaders.indices, id: \.self) { i in
                            Text(columnHeaders[i])
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .frame(width: valueColWidth, alignment: .trailing)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.primary.opacity(0.10))

                    Divider()

                    let rows = positionRows
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(rows) { row in
                            HStack(spacing: 0) {
                                Text(jdToDateString(row.julianDay))
                                    .frame(width: dateColWidth, alignment: .leading)
                                Text(String(format: "%.4f", row.julianDay))
                                    .frame(width: jdColWidth, alignment: .leading)
                                ForEach(row.values.indices, id: \.self) { i in
                                    Text(formatValue(row.values[i]))
                                        .frame(width: valueColWidth, alignment: .trailing)
                                }
                            }
                            .font(.system(.body, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(row.id % 2 == 1 ? Color.primary.opacity(0.06) : Color.clear)
                        }
                    }
                }
            }
        }
    }

    private func buildCSV() -> String {
        let headers = ([ac(AstroCyclesKeys.chartDate), ac(AstroCyclesKeys.positionsJulianDay)] + columnHeaders)
            .map { csvEscape($0) }.joined(separator: ",")
        let dataLines = positionRows.map { row in
            ([jdToDateString(row.julianDay), String(format: "%.4f", row.julianDay)]
                + row.values.map { formatValue($0) })
                .map { csvEscape($0) }.joined(separator: ",")
        }
        return ([headers] + dataLines).joined(separator: "\n")
    }

    private func csvEscape(_ value: String) -> String {
        guard value.contains(",") || value.contains("\"") || value.contains("\n") else { return value }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    private func formatValue(_ value: Double) -> String {
        showDms ? PositionInDegreesConversion.DoubleToDms(value) : String(format: "%.4f", value)
    }

    private static let tableDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()

    private func jdToDateString(_ jd: Double) -> String {
        Self.tableDateFormatter.string(from: jdToDate(jd))
    }

    // MARK: - Resize handle

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

    // MARK: - Single factors chart

    private var singleChart: some View { buildSingleChart() }

    private func buildSingleChart() -> AnyView {
        let isAngular = model.coordinate == .longitude || model.coordinate == .rightAscension
        let segmented = model.singleResults.map { factorResult in
            (
                factor: factorResult.factor,
                series: factorResult.series,
                segments: isAngular
                    ? wrapSegments(factorResult.series)
                    : Array(repeating: 0, count: factorResult.series.count)
            )
        }
        switch model.coordinate {
        case .longitude, .rightAscension:
            return AnyView(singleChartMarks(segmented)
                .chartYScale(domain: 0...360)
                .chartYAxis {
                    AxisMarks(values: Array(stride(from: 0, through: 360, by: 15))) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxisLabel(coordinateLabel)
                .chartLegend(.visible))
        case .latitude:
            return AnyView(singleChartMarks(segmented)
                .chartYAxis {
                    AxisMarks(values: .stride(by: 1)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxisLabel(coordinateLabel)
                .chartLegend(.visible))
        case .declination:
            return AnyView(singleChartMarks(segmented)
                .chartYAxis {
                    AxisMarks(values: .stride(by: 2)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxisLabel(coordinateLabel)
                .chartLegend(.visible))
        case .distance:
            return AnyView(singleChartMarks(segmented)
                .chartYAxis {
                    AxisMarks(values: .stride(by: 5)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxisLabel(coordinateLabel)
                .chartLegend(.visible))
        }
    }

    private typealias SegmentedResult = (factor: Factors, series: [(julianDay: Double, position: Double)], segments: [Int])

    private func singleChartMarks(_ segmented: [SegmentedResult]) -> some View {
        Chart {
            ForEach(segmented, id: \.factor.rawValue) { factorResult in
                let name = NSLocalizedString(factorResult.factor.localizedName, comment: "")
                ForEach(factorResult.series.indices, id: \.self) { i in
                    let point = factorResult.series[i]
                    let seriesKey = "\(factorResult.factor.rawValue)-\(factorResult.segments[i])"
                    LineMark(
                        x: .value(ac(AstroCyclesKeys.chartDate), jdToDate(point.julianDay)),
                        y: .value(coordinateLabel, point.position),
                        series: .value("", seriesKey)
                    )
                    .foregroundStyle(by: .value("", name))
                }
            }
        }
        .chartXAxis { xAxisContent(stride: xAxisStrideDays) }
        .chartPlotStyle { $0.padding(.bottom, 80) }
    }

    /// Assigns a segment index to each point, incrementing whenever consecutive positions
    /// differ by more than 180° — which indicates a 0°/360° wrap-around.
    private func wrapSegments(_ series: [(julianDay: Double, position: Double)]) -> [Int] {
        guard series.count > 1 else { return Array(repeating: 0, count: series.count) }
        var result = [Int](repeating: 0, count: series.count)
        var current = 0
        for i in 1..<series.count {
            if abs(series[i].position - series[i - 1].position) > 180.0 {
                current += 1
            }
            result[i] = current
        }
        return result
    }

    // MARK: - Factor pairs chart

    private var pairsChart: some View { buildPairsChart() }

    private func buildPairsChart() -> AnyView {
        AnyView(Chart {
            ForEach(Array(model.pairResults.enumerated()), id: \.offset) { index, series in
                let label = pairLabel(for: index)
                ForEach(series, id: \.julianDay) { point in
                    LineMark(
                        x: .value(ac(AstroCyclesKeys.chartDate), jdToDate(point.julianDay)),
                        y: .value(ac(AstroCyclesKeys.chartYDifference), point.difference)
                    )
                    .foregroundStyle(by: .value("", label))
                }
            }
        }
        .chartYAxisLabel(ac(AstroCyclesKeys.chartYDifference))
        .chartLegend(.visible)
        .chartXAxis { xAxisContent(stride: xAxisStrideDays) }
        .chartPlotStyle { $0.padding(.bottom, 80) })
    }

    // MARK: - Helpers

    private static let xAxisDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()

    private var periodDays: Double {
        if model.isPairs {
            guard let s = model.pairResults.first, let first = s.first, let last = s.last else { return 365 }
            return last.julianDay - first.julianDay
        } else {
            guard let r = model.singleResults.first, let first = r.series.first, let last = r.series.last else { return 365 }
            return last.julianDay - first.julianDay
        }
    }

    private var xAxisStrideDays: Int { max(1, Int(round(periodDays / 60.0))) }

    private var exportChartWidth: CGFloat {
        let base = chartWidth > 0 ? chartWidth : 900.0
        return max(base, 1800.0)
    }

    @AxisContentBuilder
    private func xAxisContent(stride: Int) -> some AxisContent {
        AxisMarks(values: .stride(by: .day, count: stride)) { value in
            AxisGridLine()
            AxisTick()
            AxisValueLabel {
                if let date = value.as(Date.self) {
                    Text(Self.xAxisDateFormatter.string(from: date))
                        .font(.caption2)
                        .fixedSize()
                        .rotationEffect(.degrees(-90))
                        .frame(width: 1, height: 65)
                }
            }
        }
    }

    private var coordinateLabel: String {
        NSLocalizedString(model.coordinate.rbKey, comment: "")
    }

    private func pairLabel(for index: Int) -> String {
        guard index < model.factorPairs.count else { return "\(index + 1)" }
        let pair = model.factorPairs[index]
        let n1 = NSLocalizedString(pair.factor1.localizedName, comment: "")
        let n2 = NSLocalizedString(pair.factor2.localizedName, comment: "")
        return "\(n1) – \(n2)"
    }

    private func jdToDate(_ jd: Double) -> Date {
        Date(timeIntervalSince1970: (jd - 2440587.5) * 86400.0)
    }
}
