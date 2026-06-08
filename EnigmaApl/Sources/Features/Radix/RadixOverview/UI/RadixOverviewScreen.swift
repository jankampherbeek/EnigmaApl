// RadixOverviewScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func ro(_ key: String) -> String {
    NSLocalizedString(key, tableName: "RadixOverview", bundle: .main, comment: "")
}

struct RadixOverviewScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var radixNav: RadixNavigator
    @StateObject private var model = RadixOverviewModel()
    @State private var showHelp = false

    private let nameWidth: CGFloat = 240
    private let julianDayWidth: CGFloat = 120

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
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: ro(RadixOverviewKeys.help))
        }
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
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)

                        Divider()

                        ForEach(Array(chartSession.charts.enumerated()), id: \.element.id) { index, named in
                            let isSelected = chartSession.selected?.id == named.id
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.accentColor)
                                            .imageScale(.small)
                                    }
                                    Text(named.name)
                                        .lineLimit(1)
                                }
                                .frame(width: nameWidth, alignment: .leading)
                                Text(model.formattedJulianDay(named.chart.JulianDay))
                                    .frame(width: julianDayWidth, alignment: .trailing)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                chartSession.select(named)
                                radixNav.setInspector(.positions)
                            }
                        }
                    }
                }
            }
        }
    }
}
