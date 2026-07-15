// HoroscopeScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
import SwiftUI

struct HoroscopeScreen: View {
    @EnvironmentObject private var chartSession: ChartSession

    @Binding var blackWhite:  Bool
    @Binding var hideAspects: Bool
    @Binding var hideTime:    Bool
    @Binding var showExport:  Bool

    var body: some View {
        Group {
            if let named = chartSession.selected {
                ChartWheelRouter(
                    chart: named.chart, chartVersion: named.version,
                    blackWhite: $blackWhite, hideAspects: $hideAspects,
                    hideTime: $hideTime, showExport: $showExport
                )
                .padding()
            } else {
                ContentUnavailableView(
                    t(RadixChartKeys.noChartTitle),
                    systemImage: "circle.dashed",
                    description: Text(t(RadixChartKeys.noChartDescription))
                )
            }
        }
    }

    // MARK: - Helpers

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "RadixChart", bundle: .main, comment: "")
    }
}
