// WavesChartView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Charts
import UniformTypeIdentifiers

struct WavesChartView: View {
    @EnvironmentObject private var model: WavesModel

    @State private var chartHeight: CGFloat = 400
    @State private var dragStartHeight: CGFloat = 400
    @State private var selectedTab: Int = 0
    @State private var showDms: Bool = true
    @State private var chartWidth: CGFloat = 0
    @State private var showHelp = false

    var body: some View {
        Group {
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
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: w(WavesKeys.chartHelp))
        }
    }

    // MARK: - Chart tab

    private var chartTab: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(w(WavesKeys.chartExport)) {
                    if let data = renderChartToPNG() {
                        #if os(macOS)
                        savePanel(data: data, defaultName: "waves.png", ext: "png")
                        #endif
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
                            .onChange(of: geo.size.width) { _, new in chartWidth = new }
                    }
                )
                .padding([.horizontal, .top])
            resizeHandle
        }
    }

    @MainActor
    private func renderChartToPNG() -> Data? {
        let exportWidth = exportChartWidth
        let totalPoints = model.allResults.values.map { $0.count }.reduce(0, +)
        Logger.log.debug("WavesChartView.renderChartToPNG: exportWidth=\(exportWidth) chartHeight=\(self.chartHeight) totalPoints=\(totalPoints)")
        #if os(macOS)
        let bgColor = Color(nsColor: .windowBackgroundColor)
        #else
        let bgColor = Color(uiColor: .systemBackground)
        #endif
        let content = buildChart()
            .frame(width: exportWidth, height: chartHeight)
            .background(bgColor)
            .environmentObject(model)
        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = .init(width: exportWidth, height: chartHeight)
        renderer.scale = 2.0
        #if os(macOS)
        guard let cgImage = renderer.cgImage else {
            Logger.log.error("WavesChartView.renderChartToPNG: cgImage is nil")
            return nil
        }
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let png = bitmapRep.representation(using: .png, properties: [:])
        Logger.log.debug("WavesChartView.renderChartToPNG: png bytes=\(png?.count ?? -1)")
        return png
        #else
        return renderer.uiImage?.pngData()
        #endif
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

    // MARK: - Chart

    private var chart: some View { buildChart() }

    private func buildChart() -> AnyView {
        AnyView(Chart {
            ForEach(model.selectedFactors, id: \.self) { factor in
                let points = model.allResults[factor] ?? []
                let seriesLabel = NSLocalizedString(factor.localizedName, comment: "")
                ForEach(points.indices, id: \.self) { i in
                    let point = points[i]
                    LineMark(
                        x: .value(w(WavesKeys.chartDate), jdToDate(point.julianDay)),
                        y: .value(w(WavesKeys.chartYWaveValue), point.waveValue)
                    )
                    .foregroundStyle(by: .value(w(WavesKeys.chartSeries), seriesLabel))
                }
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

    private struct MergedRow {
        let julianDay: Double
        let values: [Factors: Double]
    }

    private var mergedRows: [MergedRow] {
        var jdSet: Set<Double> = []
        for points in model.allResults.values { points.forEach { jdSet.insert($0.julianDay) } }
        let valueDicts: [Factors: [Double: Double]] = model.allResults.reduce(into: [:]) { dict, pair in
            dict[pair.key] = Dictionary(uniqueKeysWithValues: pair.value.map { ($0.julianDay, $0.waveValue) })
        }
        return jdSet.sorted().map { jd in
            let values = model.selectedFactors.reduce(into: [Factors: Double]()) { d, f in
                if let v = valueDicts[f]?[jd] { d[f] = v }
            }
            return MergedRow(julianDay: jd, values: values)
        }
    }

    private var positionsTab: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(w(WavesKeys.positionsExport)) {
                    let csv = buildCSV()
                    if let data = csv.data(using: .utf8) {
                        #if os(macOS)
                        savePanel(data: data, defaultName: "waves.csv", ext: "csv")
                        #endif
                    }
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

            let rows = mergedRows

            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text(w(WavesKeys.chartDate))
                            .fontWeight(.semibold)
                            .frame(width: dateColWidth, alignment: .leading)
                        Text(w(WavesKeys.positionsJulianDay))
                            .fontWeight(.semibold)
                            .frame(width: jdColWidth, alignment: .leading)
                        ForEach(model.selectedFactors, id: \.self) { factor in
                            Text(NSLocalizedString(factor.localizedName, comment: ""))
                                .fontWeight(.semibold)
                                .frame(width: valueColWidth, alignment: .trailing)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.primary.opacity(0.10))

                    Divider()

                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(rows.indices, id: \.self) { i in
                            let row = rows[i]
                            HStack(spacing: 0) {
                                Text(jdToDateString(row.julianDay))
                                    .frame(width: dateColWidth, alignment: .leading)
                                Text(String(format: "%.4f", row.julianDay))
                                    .frame(width: jdColWidth, alignment: .leading)
                                ForEach(model.selectedFactors, id: \.self) { factor in
                                    if let v = row.values[factor] {
                                        Text(formatValue(v))
                                            .frame(width: valueColWidth, alignment: .trailing)
                                    } else {
                                        Text("—")
                                            .frame(width: valueColWidth, alignment: .trailing)
                                    }
                                }
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
    }

    private func buildCSV() -> String {
        let factorHeaders = model.selectedFactors.map {
            NSLocalizedString($0.localizedName, comment: "")
        }
        let headers = ([w(WavesKeys.chartDate), w(WavesKeys.positionsJulianDay)] + factorHeaders)
            .map { csvEscape($0) }.joined(separator: ",")
        let rows = mergedRows
        let dataLines = rows.map { row in
            var cols = [jdToDateString(row.julianDay), String(format: "%.4f", row.julianDay)]
            for factor in model.selectedFactors {
                if let v = row.values[factor] { cols.append(formatValue(v)) }
                else { cols.append("") }
            }
            return cols.map { csvEscape($0) }.joined(separator: ",")
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
        let allJds = model.allResults.values.flatMap { $0.map { $0.julianDay } }
        guard let first = allJds.min(), let last = allJds.max() else { return 365 }
        return last - first
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

    // MARK: - Y-axis scale

    private var yAxisStride: Double {
        let allValues = model.allResults.values.flatMap { $0.map { $0.waveValue } }
        guard let maxVal = allValues.max(), maxVal > 0 else { return 10 }
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
