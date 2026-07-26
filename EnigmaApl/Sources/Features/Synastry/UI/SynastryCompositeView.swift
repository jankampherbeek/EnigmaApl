// SynastryCompositeView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Synastry", bundle: .main, comment: "")
}

private enum CompositeHouseMethodOption: String, CaseIterable, Identifiable {
    case midpointsOnly
    case referenceLocation

    var id: String { rawValue }

    var labelKey: String {
        switch self {
        case .midpointsOnly:      return SynastryKeys.compositeMethodMidpointsOnly
        case .referenceLocation: return SynastryKeys.compositeMethodReferenceLocation
        }
    }
}

/// Composite chart: every factor sits on the midpoint between its two natal positions.
/// Lets the user pick between a pure-midpoints house method and a reference-location
/// method (composite MC fixed, houses derived from its ARMC), then shows the result as
/// the usual chart figure (aspects, black/white, export).
struct SynastryCompositeView: View {
    let charts: [NamedChart]

    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private let seWrapper = SEWrapper()

    @State private var method: CompositeHouseMethodOption = .midpointsOnly

    // Reference-location fields (LocationSection needs these bindings even though
    // composite has no time-zone concept of its own).
    @State private var locationName = ""
    @State private var latitudeDegrees = 0
    @State private var latitudeMinutes = 0
    @State private var latitudeSeconds = 0
    @State private var longitudeDegrees = 0
    @State private var longitudeMinutes = 0
    @State private var longitudeSeconds = 0
    @State private var latHemi: LatitudeHemisphere = .north
    @State private var lonHemi: LongitudeHemisphere = .east
    @State private var offsetHour = 0
    @State private var offsetMinute = 0
    @State private var utOffsetDirection: UTOffsetDirection = .later
    @State private var dstOption: DSTOption = .noDST
    @State private var selectedCity: LocationCity? = nil

    @State private var compositeChart: FullChart?
    @State private var blackWhite = false
    @State private var hideAspects = false
    @State private var showExport = false
    @State private var showHelp = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            settingsSection

            if let compositeChart {
                Divider()
                resultSection(chart: compositeChart)
            }
        }
        .onChange(of: method) { _, _ in
            guard compositeChart != nil else { return }
            calculate()
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(SynastryKeys.helpComposite))
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FieldBlock(t(SynastryKeys.compositeMethodLabel)) {
                Picker(t(SynastryKeys.compositeMethodLabel), selection: $method) {
                    ForEach(CompositeHouseMethodOption.allCases) { option in
                        Text(t(option.labelKey)).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(maxWidth: 400)
            }

            if method == .referenceLocation {
                LocationSection(
                    locationName: $locationName,
                    latitudeDegrees: $latitudeDegrees, latitudeMinutes: $latitudeMinutes, latitudeSeconds: $latitudeSeconds,
                    longitudeDegrees: $longitudeDegrees, longitudeMinutes: $longitudeMinutes, longitudeSeconds: $longitudeSeconds,
                    latHemi: $latHemi, lonHemi: $lonHemi,
                    offsetHour: $offsetHour, offsetMinute: $offsetMinute,
                    utOffsetDirection: $utOffsetDirection, dstOption: $dstOption,
                    selectedCity: $selectedCity
                )
                .frame(maxWidth: 500, alignment: .leading)
            }

            HStack(spacing: 12) {
                Button(t(SynastryKeys.compositeShowChart)) { calculate() }
                    .buttonStyle(.borderedProminent)

                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Help")
            }
        }
    }

    // MARK: - Result

    @ViewBuilder
    private func resultSection(chart: FullChart) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            wheelControls

            Text(String(format: t(SynastryKeys.compositeChartTitle), charts.map(\.name).joined(separator: ", ")))
                .font(.title3.weight(.semibold))

            ChartWheelRouter(
                chart: chart, chartVersion: UUID(),
                blackWhite: $blackWhite, hideAspects: $hideAspects,
                hideTime: .constant(false), showExport: $showExport
            )
        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(
                wheelView: ChartWheelRouter(
                    chart: chart, chartVersion: UUID(),
                    blackWhite: $blackWhite, hideAspects: $hideAspects,
                    hideTime: .constant(false), showExport: $showExport
                )
            )
        }
    }

    private var wheelControls: some View {
        HStack(spacing: 8) {
            Button { blackWhite.toggle() } label: {
                Image(systemName: blackWhite ? "circle.lefthalf.filled" : "paintpalette")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(blackWhite ? "Switch to color" : "Switch to black and white")

            Button { hideAspects.toggle() } label: {
                Image(systemName: "angle")
                    .foregroundStyle(hideAspects ? .secondary : .primary)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(hideAspects ? "Show aspects" : "Hide aspects")

            Button { showExport = true } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Export")
        }
    }

    // MARK: - Calculation

    private func calculate() {
        let houseSystem = Int(activeConfigs.first?.calculationConfig.houseSystem.seId.asciiValue ?? 80)
        let houseMethod: CompositeOrchestrator.HouseMethod
        switch method {
        case .midpointsOnly:
            houseMethod = .midpointsOnly
        case .referenceLocation:
            let lat = dmsToDecimal(deg: latitudeDegrees, min: latitudeMinutes, sec: latitudeSeconds, negative: latHemi == .south)
            let lon = dmsToDecimal(deg: longitudeDegrees, min: longitudeMinutes, sec: longitudeSeconds, negative: lonHemi == .west)
            houseMethod = .referenceLocation(latitude: lat, longitude: lon)
        }
        compositeChart = CompositeOrchestrator.calculate(
            charts: charts.map { $0.chart },
            houseSystem: houseSystem, method: houseMethod, seWrapper: seWrapper
        )
    }

    private func dmsToDecimal(deg: Int, min: Int, sec: Int, negative: Bool) -> Double {
        let value = Double(deg) + Double(min) / 60.0 + Double(sec) / 3600.0
        return negative ? -value : value
    }
}
