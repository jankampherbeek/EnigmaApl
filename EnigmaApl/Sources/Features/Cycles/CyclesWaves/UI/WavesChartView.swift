// WavesChartView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Charts

struct WavesChartView: View {
    @EnvironmentObject private var model: WavesModel

    @State private var chartHeight: CGFloat = 400
    @State private var dragStartHeight: CGFloat = 400

    var body: some View {
        if model.hasResults {
            VStack(spacing: 0) {
                chart
                    .frame(height: chartHeight)
                    .padding([.horizontal, .top])
                resizeHandle
            }
        } else {
            Text(w(WavesKeys.chartNoResults))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Chart

    private var chart: some View {
        let seriesLabel = NSLocalizedString(model.cycleType.localizedName, comment: "")
        return Chart {
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
        .chartScrollableAxes(.horizontal)
        .chartXAxis { xAxisMarks }
        .chartPlotStyle { $0.padding(.bottom, 80) }
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
