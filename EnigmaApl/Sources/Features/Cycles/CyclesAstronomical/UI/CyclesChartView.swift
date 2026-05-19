// CyclesChartView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Charts
import UniformTypeIdentifiers

private struct CyclesPNGDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.png] }
    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

private struct CyclesCSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    var content: String

    init(content: String) { self.content = content }

    init(configuration: ReadConfiguration) throws {
        content = String(data: configuration.file.regularFileContents ?? Data(), encoding: .utf8) ?? ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(content.utf8))
    }
}

struct CyclesChartView: View {
    @EnvironmentObject private var model: AstronomicalCyclesModel

    @State private var chartHeight: CGFloat = 400
    @State private var dragStartHeight: CGFloat = 400
    @State private var selectedTab: Int = 0
    @State private var showDms: Bool = true
    @State private var showExporter: Bool = false
    @State private var csvDocument = CyclesCSVDocument(content: "")
    @State private var showChartExporter: Bool = false
    @State private var chartPNGDocument = CyclesPNGDocument(data: Data())

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
                        chartPNGDocument = CyclesPNGDocument(data: data)
                        showChartExporter = true
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
            .padding([.horizontal, .top])

            resizeHandle
        }
        .fileExporter(
            isPresented: $showChartExporter,
            document: chartPNGDocument,
            contentType: .png,
            defaultFilename: "astronomical_cycles"
        ) { _ in }
    }

    @MainActor
    private func renderChartToPNG() -> Data? {
        #if os(macOS)
        let bgColor = Color(nsColor: .windowBackgroundColor)
        #else
        let bgColor = Color(uiColor: .systemBackground)
        #endif
        let exportWidth: CGFloat = 1400
        let chartView = model.isPairs
            ? buildPairsChart(forExport: true)
            : buildSingleChart(forExport: true)
        let content = chartView
            .frame(width: exportWidth, height: chartHeight)
            .padding()
            .background(bgColor)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 2.0
        #if os(macOS)
        guard let nsImage = renderer.nsImage,
              let tiffData = nsImage.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else { return nil }
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
                    csvDocument = CyclesCSVDocument(content: buildCSV())
                    showExporter = true
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
        .fileExporter(
            isPresented: $showExporter,
            document: csvDocument,
            contentType: .commaSeparatedText,
            defaultFilename: "astronomical_cycles"
        ) { _ in }
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

    private var singleChart: some View { buildSingleChart(forExport: false) }

    private func buildSingleChart(forExport: Bool) -> AnyView {
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
            let base = singleChartMarks(segmented)
                .chartYScale(domain: 0...360)
                .chartYAxis {
                    AxisMarks(values: Array(stride(from: 0, through: 360, by: 15))) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxisLabel(coordinateLabel)
                .chartLegend(.visible)
            return forExport ? AnyView(base) : AnyView(base.chartScrollableAxes(.horizontal))
        case .latitude:
            let base = singleChartMarks(segmented)
                .chartYAxis {
                    AxisMarks(values: .stride(by: 1)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxisLabel(coordinateLabel)
                .chartLegend(.visible)
            return forExport ? AnyView(base) : AnyView(base.chartScrollableAxes(.horizontal))
        case .declination:
            let base = singleChartMarks(segmented)
                .chartYAxis {
                    AxisMarks(values: .stride(by: 2)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxisLabel(coordinateLabel)
                .chartLegend(.visible)
            return forExport ? AnyView(base) : AnyView(base.chartScrollableAxes(.horizontal))
        case .distance:
            let base = singleChartMarks(segmented)
                .chartYAxis {
                    AxisMarks(values: .stride(by: 5)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxisLabel(coordinateLabel)
                .chartLegend(.visible)
            return forExport ? AnyView(base) : AnyView(base.chartScrollableAxes(.horizontal))
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
        .chartXAxis { xAxisMarks }
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

    private var pairsChart: some View { buildPairsChart(forExport: false) }

    private func buildPairsChart(forExport: Bool) -> AnyView {
        let base = Chart {
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
        .chartXAxis { xAxisMarks }
        .chartPlotStyle { $0.padding(.bottom, 80) }
        return forExport ? AnyView(base) : AnyView(base.chartScrollableAxes(.horizontal))
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

    @AxisContentBuilder
    private var xAxisMarks: some AxisContent {
        AxisMarks(values: .stride(by: .day, count: xAxisStrideDays)) { value in
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
