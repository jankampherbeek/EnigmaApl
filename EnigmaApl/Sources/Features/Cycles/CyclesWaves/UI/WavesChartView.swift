// WavesChartView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Charts
import UniformTypeIdentifiers

private struct WavesPNGDocument: FileDocument {
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

private struct WavesCSVDocument: FileDocument {
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

struct WavesChartView: View {
    @EnvironmentObject private var model: WavesModel

    @State private var chartHeight: CGFloat = 400
    @State private var dragStartHeight: CGFloat = 400
    @State private var selectedTab: Int = 0
    @State private var showDms: Bool = true
    @State private var showExporter: Bool = false
    @State private var csvDocument = WavesCSVDocument(content: "")
    @State private var showChartExporter: Bool = false
    @State private var chartPNGDocument = WavesPNGDocument(data: Data())
    @State private var chartWidth: CGFloat = 0

    var body: some View {
        if model.hasResults {
            TabView(selection: $selectedTab) {
                chartTab
                    .tabItem { Text(w(WavesKeys.tabChart)) }
                    .tag(0)
                positionsTab
                    .tabItem { Text(w(WavesKeys.tabPositions)) }
                    .tag(1)
            }
        } else {
            Text(w(WavesKeys.chartNoResults))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Chart tab

    private var chartTab: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(w(WavesKeys.chartExport)) {
                    if let data = renderChartToPNG() {
                        chartPNGDocument = WavesPNGDocument(data: data)
                        showChartExporter = true
                    }
                }
                .buttonStyle(.bordered)
                .padding([.top, .trailing])
            }

            chart
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
        .fileExporter(
            isPresented: $showChartExporter,
            document: chartPNGDocument,
            contentType: .png,
            defaultFilename: "waves"
        ) { _ in }
    }

    @MainActor
    private func renderChartToPNG() -> Data? {
        let exportWidth = exportChartWidth
        #if os(macOS)
        let bgColor = Color(nsColor: .windowBackgroundColor)
        #else
        let bgColor = Color(uiColor: .systemBackground)
        #endif
        let content = buildChart()
            .frame(width: exportWidth, height: chartHeight)
            .background(bgColor)
        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = .init(width: exportWidth, height: chartHeight)
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

    // MARK: - Chart

    private var chart: some View { buildChart() }

    private func buildChart() -> AnyView {
        let seriesLabel = NSLocalizedString(model.cycleType.localizedName, comment: "")
        return AnyView(Chart {
            ForEach(model.results.indices, id: \.self) { i in
                let point = model.results[i]
                LineMark(
                    x: .value(w(WavesKeys.chartDate), jdToDate(point.julianDay)),
                    y: .value(w(WavesKeys.chartYWaveValue), point.waveValue)
                )
                .foregroundStyle(by: .value("", seriesLabel))
            }
        }
        .chartYAxisLabel(w(WavesKeys.chartYWaveValue))
        .chartYAxis {
            AxisMarks(values: .stride(by: yAxisStride)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartLegend(.visible)
        .chartXAxis { xAxisContent(stride: xAxisStrideDays) }
        .chartPlotStyle { $0.padding(.bottom, 80) })
    }

    // MARK: - Positions tab

    private let dateColWidth: CGFloat  = 100
    private let jdColWidth: CGFloat    = 130
    private let valueColWidth: CGFloat = 120

    private var positionsTab: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(w(WavesKeys.positionsExport)) {
                    csvDocument = WavesCSVDocument(content: buildCSV())
                    showExporter = true
                }
                .buttonStyle(.bordered)
                .padding([.top, .leading])

                Spacer()

                Picker("", selection: $showDms) {
                    Text(w(WavesKeys.positionsFormatDms)).tag(true)
                    Text(w(WavesKeys.positionsFormatDecimal)).tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
                .padding([.top, .trailing])
            }

            let valueHeader = NSLocalizedString(model.cycleType.localizedName, comment: "")

            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text(w(WavesKeys.chartDate))
                            .fontWeight(.semibold)
                            .frame(width: dateColWidth, alignment: .leading)
                        Text(w(WavesKeys.positionsJulianDay))
                            .fontWeight(.semibold)
                            .frame(width: jdColWidth, alignment: .leading)
                        Text(valueHeader)
                            .fontWeight(.semibold)
                            .frame(width: valueColWidth, alignment: .trailing)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.primary.opacity(0.10))

                    Divider()

                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(model.results.indices, id: \.self) { i in
                            let point = model.results[i]
                            HStack(spacing: 0) {
                                Text(jdToDateString(point.julianDay))
                                    .frame(width: dateColWidth, alignment: .leading)
                                Text(String(format: "%.4f", point.julianDay))
                                    .frame(width: jdColWidth, alignment: .leading)
                                Text(formatValue(point.waveValue))
                                    .frame(width: valueColWidth, alignment: .trailing)
                            }
                            .font(.system(.body, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(i % 2 == 1 ? Color.primary.opacity(0.06) : Color.clear)
                        }
                    }
                }
            }
        }
        .fileExporter(
            isPresented: $showExporter,
            document: csvDocument,
            contentType: .commaSeparatedText,
            defaultFilename: "waves"
        ) { _ in }
    }

    private func buildCSV() -> String {
        let valueHeader = NSLocalizedString(model.cycleType.localizedName, comment: "")
        let headers = [w(WavesKeys.chartDate), w(WavesKeys.positionsJulianDay), valueHeader]
            .map { csvEscape($0) }.joined(separator: ",")
        let dataLines = model.results.map { point in
            [jdToDateString(point.julianDay), String(format: "%.4f", point.julianDay), formatValue(point.waveValue)]
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

    // MARK: - X-axis

    private static let xAxisDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()

    private var periodDays: Double {
        guard let first = model.results.first, let last = model.results.last else { return 365 }
        return last.julianDay - first.julianDay
    }

    private var xAxisStrideDays: Int { max(1, Int(round(periodDays / 60.0))) }

    // Width used when rendering the export PNG: at least 2 px per day so the full period fits.
    private var exportChartWidth: CGFloat {
        max(chartWidth > 0 ? chartWidth : 900.0, periodDays * 2.0)
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

    // MARK: - Y-axis scale

    private var yAxisStride: Double {
        guard let maxVal = model.results.map({ $0.waveValue }).max(), maxVal > 0 else { return 10 }
        let candidates: [Double] = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]
        let target = maxVal / 8.0
        return candidates.first(where: { $0 >= target }) ?? 1000
    }

    // MARK: - Helpers

    private func jdToDate(_ jd: Double) -> Date {
        Date(timeIntervalSince1970: (jd - 2440587.5) * 86400.0)
    }

    private func w(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Waves", bundle: .main, comment: "")
    }
}
