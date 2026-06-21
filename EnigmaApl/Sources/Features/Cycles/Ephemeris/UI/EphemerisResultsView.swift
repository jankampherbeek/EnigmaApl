// EphemerisResultsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Charts

private func e(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Ephemeris", bundle: .main, comment: "")
}

struct EphemerisResultsView: View {
    @EnvironmentObject private var model: EphemerisModel

    var body: some View {
        if model.rows.isEmpty || model.selectedFactors.isEmpty {
            Text(e(EphemerisKeys.noResults))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            TabView {
                EphemerisTableView()
                    .tabItem { Text(e(EphemerisKeys.tabTable)) }
                EphemerisGraphView()
                    .tabItem { Text(e(EphemerisKeys.tabGraph)) }
            }
        }
    }
}

// MARK: - Table

private struct EphemerisTableView: View {
    @EnvironmentObject private var model: EphemerisModel

    private let dayColWidth: CGFloat   = 44
    private let valueColWidth: CGFloat = 130

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 0) {
                headerRow
                Divider()
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(model.rows) { row in
                        tableRow(row)
                            .background(row.id % 2 == 0 ? Color.primary.opacity(0.06) : Color.clear)
                    }
                }
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            Text(e(EphemerisKeys.dateHeader))
                .fontWeight(.semibold)
                .frame(width: dayColWidth, alignment: .center)
            ForEach(model.selectedFactors, id: \.rawValue) { factor in
                Text(GlyphSelector.getGlyphForFactor(factor))
                    .font(.custom("EnigmaAstrology3", size: 16))
                    .fontWeight(.semibold)
                    .frame(width: valueColWidth, alignment: .trailing)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.10))
    }

    private func tableRow(_ row: EphemerisRow) -> some View {
        HStack(spacing: 0) {
            Text(String(format: "%02d", row.id))
                .frame(width: dayColWidth, alignment: .center)
            ForEach(model.selectedFactors, id: \.rawValue) { factor in
                formattedCell(row: row, factor: factor)
                    .frame(width: valueColWidth, alignment: .trailing)
            }
        }
        .font(.system(.body, design: .monospaced))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
    }

    @ViewBuilder
    private func formattedCell(row: EphemerisRow, factor: Factors) -> some View {
        if let value = row.value(for: factor, coordinate: model.selectedCoordinate) {
            if model.selectedCoordinate == .longitude {
                let (dms, sign, _) = PositionInDegreesConversion.DoubleToDmsSign(value)
                if let sign = sign {
                    Text(GlyphSelector.getGlyphForSign(sign))
                        .font(.custom("EnigmaAstrology3", size: 12))
                    + Text(" \(dms)")
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
}

// MARK: - Graph

private struct EphemerisGraphView: View {
    @EnvironmentObject private var model: EphemerisModel

    @State private var chartHeight: CGFloat = 400
    @State private var dragStartHeight: CGFloat = 400

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
            let values: [Double] = model.rows.compactMap { row in
                row.value(for: item.factor, coordinate: model.selectedCoordinate)
            }
            var segments = [Int](repeating: 0, count: values.count)
            if isAngular && values.count > 1 {
                var seg = 0
                for i in 1..<values.count {
                    if abs(values[i] - values[i - 1]) > 180.0 { seg += 1 }
                    segments[i] = seg
                }
            }
            let points: [DayPoint] = values.enumerated().map { i, val in
                DayPoint(
                    id: "\(item.factor.rawValue)-\(i)-\(segments[i])",
                    day: model.rows[i].id,
                    value: val,
                    segment: segments[i],
                    color: item.color
                )
            }
            return (factor: item.factor, color: item.color, points: points)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
}

// MARK: - Array helper

private extension Array {
    func cycled(to count: Int) -> [Element] {
        guard !self.isEmpty else { return [] }
        return (0..<count).map { self[$0 % self.count] }
    }
}
