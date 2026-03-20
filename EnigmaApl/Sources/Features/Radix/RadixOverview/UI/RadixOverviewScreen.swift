//
//  RadixOverviewScreen.swift
//  EnigmaApl
//

import SwiftUI

private func ro(_ key: String) -> String {
    NSLocalizedString(key, tableName: "RadixOverview", bundle: .main, comment: "")
}

struct RadixOverviewScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var radixNav: RadixNavigator
    @StateObject private var model = RadixOverviewModel()

    private let nameWidth: CGFloat = 240
    private let julianDayWidth: CGFloat = 120
    private let selectWidth: CGFloat = 80

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(ro(RadixOverviewKeys.title))
                    .font(.title2.weight(.semibold))

                actionButtons

                chartsTable
            }
            .frame(maxWidth: 700, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(ro(RadixOverviewKeys.title))
    }

    // MARK: - Action buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(ro(RadixOverviewKeys.newChart)) {
                radixNav.setInspector(.newChart)
            }
            .buttonStyle(.borderedProminent)

            Button(ro(RadixOverviewKeys.searchChart)) {
                radixNav.setInspector(.search)
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Charts table

    @ViewBuilder
    private var chartsTable: some View {
        if chartSession.charts.isEmpty {
            Text(ro(RadixOverviewKeys.empty))
                .foregroundStyle(.secondary)
                .font(.callout)
        } else {
            GroupBox(ro(RadixOverviewKeys.chartsHeader)) {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Text(ro(RadixOverviewKeys.columnName))
                                .frame(width: nameWidth, alignment: .leading)
                            Text(ro(RadixOverviewKeys.columnJulianDay))
                                .frame(width: julianDayWidth, alignment: .trailing)
                            Spacer().frame(width: selectWidth)
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)

                        Divider()

                        ForEach(Array(chartSession.charts.enumerated()), id: \.element.id) { index, named in
                            HStack(spacing: 12) {
                                Text(named.name)
                                    .frame(width: nameWidth, alignment: .leading)
                                    .lineLimit(1)
                                Text(model.formattedJulianDay(named.chart.JulianDay))
                                    .frame(width: julianDayWidth, alignment: .trailing)
                                    .foregroundStyle(.secondary)
                                Button(ro(RadixOverviewKeys.select)) {
                                    chartSession.select(named)
                                    radixNav.setInspector(.positions)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .frame(width: selectWidth)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                        }
                    }
                }
            }
        }
    }
}
