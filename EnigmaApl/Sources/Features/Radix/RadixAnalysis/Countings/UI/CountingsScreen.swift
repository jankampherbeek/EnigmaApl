// CountingsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData
import Charts

/// A titled block with a small two-column table (group name, count) of `CountingsLine`s.
private struct CountingsTable: View {
    let title: String
    let countLabel: String
    let lines: [CountingsLine]

    private let nameWidth: CGFloat = 90
    private let countWidth: CGFloat = 50

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        Spacer().frame(width: nameWidth, alignment: .leading)
                        Text(countLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: countWidth, alignment: .trailing)
                    }
                    Divider()

                    ForEach(Array(lines.enumerated()), id: \.element.id) { index, line in
                        HStack(spacing: 8) {
                            Text(CountingsLabels.groupLabel(line.group))
                                .frame(width: nameWidth, alignment: .leading)
                            Text("\(line.count)").frame(width: countWidth, alignment: .trailing)
                        }
                        .padding(.vertical, 3)
                        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                }
            }
            .textSelection(.enabled)
        }
    }
}

/// A pie chart of `CountingsLine.count` per group.
private struct CountingsPieChart: View {
    let title: String
    let countLabel: String
    let lines: [CountingsLine]

    var body: some View {
        let nonZero = lines.filter { $0.count > 0 }
        GroupBox {
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)
                if nonZero.isEmpty {
                    Text("—").foregroundStyle(.secondary)
                } else {
                    Chart(nonZero) { line in
                        SectorMark(
                            angle: .value(countLabel, line.count),
                            innerRadius: .ratio(0.55),
                            angularInset: 1.5
                        )
                        .foregroundStyle(CountingsLabels.groupColor(line.group))
                        .cornerRadius(3)
                    }
                    .chartLegend(position: .bottom, alignment: .leading, spacing: 8)
                    .chartForegroundStyleScale(
                        domain: nonZero.map { CountingsLabels.groupLabel($0.group) },
                        range: nonZero.map { CountingsLabels.groupColor($0.group) }
                    )
                    .frame(height: 220)
                }
            }
        }
    }
}

struct CountingsScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]
    @State private var showHelp = false

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Countings", bundle: .main, comment: "")
    }

    private var lines: (elements: [CountingsLine], crosses: [CountingsLine]) {
        guard let chart = chartSession.selectedChart, let config = activeConfigs.first else { return ([], []) }
        return CountingsOrchestrator.elementsAndCrosses(chart: chart, factorConfig: config.factorConfig)
    }

    var body: some View {
        Group {
            if chartSession.selectedChart == nil {
                Text(t(CountingsKeys.noChart))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
            } else {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 12) {
                        headerTitle

                        CountingsTable(title: t(CountingsKeys.elementsTitle), countLabel: t(CountingsKeys.colCount), lines: lines.elements)
                        CountingsPieChart(title: t(CountingsKeys.elementsChartTitle), countLabel: t(CountingsKeys.colCount), lines: lines.elements)

                        CountingsTable(title: t(CountingsKeys.crossesTitle), countLabel: t(CountingsKeys.colCount), lines: lines.crosses)
                        CountingsPieChart(title: t(CountingsKeys.crossesChartTitle), countLabel: t(CountingsKeys.colCount), lines: lines.crosses)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
                }
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
            WheelHelpSheet(helpText: t(CountingsKeys.help))
        }
    }

    private var headerTitle: some View {
        Text(String(format: t(CountingsKeys.headerTitleFormat), chartSession.selected?.name ?? ""))
            .font(.headline)
    }
}
