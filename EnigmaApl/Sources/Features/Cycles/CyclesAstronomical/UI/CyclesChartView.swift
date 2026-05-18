// CyclesChartView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Charts

struct CyclesChartView: View {
    @EnvironmentObject private var model: AstronomicalCyclesModel

    @State private var chartHeight: CGFloat = 400
    @State private var dragStartHeight: CGFloat = 400

    var body: some View {
        if model.hasResults {
            VStack(spacing: 0) {
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
        } else {
            Text(ac(AstroCyclesKeys.chartNoResults))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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

    @ViewBuilder
    private var singleChart: some View {
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
            singleChartMarks(segmented)
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
                .chartScrollableAxes(.horizontal)
        case .latitude:
            singleChartMarks(segmented)
                .chartYAxis {
                    AxisMarks(values: .stride(by: 1)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxisLabel(coordinateLabel)
                .chartLegend(.visible)
                .chartScrollableAxes(.horizontal)
        case .declination:
            singleChartMarks(segmented)
                .chartYAxis {
                    AxisMarks(values: .stride(by: 2)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxisLabel(coordinateLabel)
                .chartLegend(.visible)
                .chartScrollableAxes(.horizontal)
        case .distance:
            singleChartMarks(segmented)
                .chartYAxis {
                    AxisMarks(values: .stride(by: 5)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxisLabel(coordinateLabel)
                .chartLegend(.visible)
                .chartScrollableAxes(.horizontal)
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

    private var pairsChart: some View {
        Chart {
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
        .chartScrollableAxes(.horizontal)
        .chartXAxis { xAxisMarks }
        .chartPlotStyle { $0.padding(.bottom, 80) }
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
