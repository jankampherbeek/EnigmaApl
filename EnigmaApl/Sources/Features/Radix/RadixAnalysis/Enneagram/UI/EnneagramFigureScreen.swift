// EnneagramResultsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct EnneagramResultsScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var enneagramModel: EnneagramModel

    @State private var activeTab: ResultsTab = .overview
    @State private var activeSheet: ActiveSheet?

    private let typeW:     CGFloat = 50
    private let nameW:     CGFloat = 240
    private let strengthW: CGFloat = 100

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Enneagram", bundle: .main, comment: "")
    }

    private var results: [EnneagramTypeResult] {
        guard let chart = chartSession.selectedChart else { return [] }
        return EnneagramOrchestrator.strengths(chart: chart, options: enneagramModel.options)
    }

    private var detailLines: [EnneagramDetailLine] {
        guard let chart = chartSession.selectedChart else { return [] }
        return EnneagramOrchestrator.details(chart: chart, options: enneagramModel.options)
    }

    private var typeNames: [Int: String] {
        Dictionary(uniqueKeysWithValues: (1...9).map { n in
            let key: String
            switch n {
            case 1: key = EnneagramKeys.type1
            case 2: key = EnneagramKeys.type2
            case 3: key = EnneagramKeys.type3
            case 4: key = EnneagramKeys.type4
            case 5: key = EnneagramKeys.type5
            case 6: key = EnneagramKeys.type6
            case 7: key = EnneagramKeys.type7
            case 8: key = EnneagramKeys.type8
            default: key = EnneagramKeys.type9
            }
            return (n, t(key))
        })
    }

    var body: some View {
        Group {
            if chartSession.selectedChart == nil {
                ContentUnavailableView(
                    t(EnneagramKeys.title),
                    systemImage: "circle.grid.3x3",
                    description: Text(t(EnneagramKeys.noChart))
                )
            } else {
                tabContent
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Picker("", selection: $activeTab) {
                    Text(t(EnneagramKeys.tabOverview)).tag(ResultsTab.overview)
                    Text(t(EnneagramKeys.tabDetails)).tag(ResultsTab.details)
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }
            ToolbarItem(placement: .automatic) {
                Button { activeSheet = .help } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .help:
                WheelHelpSheet(helpText: t(EnneagramKeys.help))
            case .typeDescription(let type):
                EnneagramTypeDescriptionSheet(type: type)
            }
        }
    }

    // MARK: - Tab content

    @ViewBuilder
    private var tabContent: some View {
        switch activeTab {
        case .overview:
            overviewContent
        case .details:
            EnneagramDetailsView(detailLines: detailLines)
        }
    }

    // MARK: - Overview tab

    private var overviewContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Diagram
                Text(t(EnneagramKeys.diagramTitle))
                    .font(.title2.weight(.semibold))

                GeometryReader { geo in
                    let size = min(geo.size.width, geo.size.height)
                    EnneagramCanvas(results: results, size: size) { type in
                        activeSheet = .typeDescription(type)
                    }
                    .frame(width: size, height: size)
                }
                .frame(maxWidth: 500)
                .aspectRatio(1, contentMode: .fit)

                Divider()

                // Strength table
                Text(t(EnneagramKeys.overviewTitle))
                    .font(.title2.weight(.semibold))

                overviewTable
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    @ViewBuilder
    private var overviewTable: some View {
        GroupBox {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text(t(EnneagramKeys.colType))
                        .frame(width: typeW, alignment: .center)
                    Text(t(EnneagramKeys.colName))
                        .frame(width: nameW, alignment: .leading)
                    Text(t(EnneagramKeys.colStrength))
                        .frame(width: strengthW, alignment: .trailing)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)

                Divider()

                ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                    overviewRow(result, index: index)
                }
            }
        }
    }

    @ViewBuilder
    private func overviewRow(_ result: EnneagramTypeResult, index: Int) -> some View {
        let isTop = index == 0
        HStack(spacing: 12) {
            Text("\(result.type)")
                .font(.headline)
                .foregroundStyle(isTop ? Color.red : .primary)
                .frame(width: typeW, alignment: .center)
            Text(typeNames[result.type] ?? "")
                .frame(width: nameW, alignment: .leading)
                .lineLimit(1)
            Text(String(format: "%.4f", result.strength))
                .frame(width: strengthW, alignment: .trailing)
                .foregroundStyle(.secondary)
                .font(.system(.body, design: .monospaced))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
        .contentShape(Rectangle())
        .onTapGesture { activeSheet = .typeDescription(result.type) }
    }
}

// MARK: - Supporting types

private enum ResultsTab {
    case overview, details
}

private enum ActiveSheet: Identifiable {
    case help
    case typeDescription(Int)

    var id: String {
        switch self {
        case .help:               return "help"
        case .typeDescription(let n): return "desc_\(n)"
        }
    }
}
