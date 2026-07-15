// ChartWheelRouter.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
import SwiftUI
import SwiftData

/// Routes a single `FullChart` to the wheel type configured in the active
/// `UserConfiguration.displayConfig.drawingType`. Shared by any screen that shows one
/// chart as a figure (radix, composite, …).
struct ChartWheelRouter: View {
    let chart: FullChart
    let chartVersion: UUID
    @Binding var blackWhite:  Bool
    @Binding var hideAspects: Bool
    @Binding var hideTime:    Bool
    @Binding var showExport:  Bool

    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private var drawingType: DrawingType {
        activeConfigs.first?.displayConfig.drawingType ?? .signBased
    }

    var body: some View {
        switch drawingType {
        case .signBased:
            ZodiacTypeWheel(
                chart: chart, chartVersion: chartVersion,
                blackWhite: $blackWhite, hideAspects: $hideAspects,
                hideTime: $hideTime, showExport: $showExport
            )
        case .houseBased:
            HouseTypeWheel(
                chart: chart, chartVersion: chartVersion,
                blackWhite: $blackWhite, hideTime: $hideTime,
                showExport: $showExport
            )
        case .french:
            FrenchTypeWheel(
                chart: chart, chartVersion: chartVersion,
                blackWhite: $blackWhite, hideAspects: $hideAspects,
                hideTime: $hideTime, showExport: $showExport
            )
        case .ring:
            RingTypeWheel(
                chart: chart, chartVersion: chartVersion,
                blackWhite: $blackWhite, hideAspects: $hideAspects,
                hideTime: $hideTime, showExport: $showExport
            )
        case .dial360:
            Dial360TypeWheel(
                chart: chart, chartVersion: chartVersion,
                blackWhite: $blackWhite, hideTime: $hideTime,
                showExport: $showExport
            )
        case .dial90:
            Dial90TypeWheel(
                chart: chart, chartVersion: chartVersion,
                blackWhite: $blackWhite, hideTime: $hideTime,
                showExport: $showExport
            )
        case .dial45:
            Dial45TypeWheel(
                chart: chart, chartVersion: chartVersion,
                blackWhite: $blackWhite, hideTime: $hideTime,
                showExport: $showExport
            )
        }
    }
}
