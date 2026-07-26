// SynastryDavisonView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Synastry", bundle: .main, comment: "")
}

private enum DavisonLocationMethodOption: String, CaseIterable, Identifiable {
    case simplified
    case original
    case referenceLocation
    case sphericalMidpoint

    var id: String { rawValue }

    var labelKey: String {
        switch self {
        case .simplified:        return SynastryKeys.combineMethodSimplified
        case .original:          return SynastryKeys.combineMethodOriginal
        case .referenceLocation: return SynastryKeys.combineMethodReferenceLocation
        case .sphericalMidpoint: return SynastryKeys.combineMethodSphericalMidpoint
        }
    }
}

/// Davison (Combine) chart: a real chart calculated for the midpoint moment in time (UT)
/// and one of four midpoint-location conventions. Presented the same way as the Composite
/// chart: a method picker, an optional reference-location entry, then the usual chart
/// figure (aspects, black/white, export).
struct SynastryDavisonView: View {
    let charts: [NamedChart]

    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private let seWrapper = SEWrapper()

    @State private var method: DavisonLocationMethodOption = .simplified

    // Reference-location fields (LocationSection needs these bindings even though
    // the Davison chart has no time-zone concept of its own).
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

    @State private var davisonResult: DavisonOrchestrator.Result?
    @State private var blackWhite = false
    @State private var hideAspects = false
    @State private var showExport = false
    @State private var showHelp = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            settingsSection

            if let davisonResult {
                Divider()
                resultSection(result: davisonResult)
            }
        }
        .onChange(of: method) { _, _ in
            guard davisonResult != nil else { return }
            calculate()
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(SynastryKeys.helpCombine))
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FieldBlock(t(SynastryKeys.combineMethodLabel)) {
                Picker(t(SynastryKeys.combineMethodLabel), selection: $method) {
                    ForEach(DavisonLocationMethodOption.allCases) { option in
                        Text(t(option.labelKey)).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(maxWidth: 500)
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
                Button(t(SynastryKeys.combineShowChart)) { calculate() }
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
    private func resultSection(result: DavisonOrchestrator.Result) -> some View {
        let chart = result.chart
        VStack(alignment: .leading, spacing: 12) {
            wheelControls

            Text(String(format: t(SynastryKeys.combineChartTitle), charts.map(\.name).joined(separator: ", ")))
                .font(.title3.weight(.semibold))

            resultSummary(result: result)

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

    private func resultSummary(result: DavisonOrchestrator.Result) -> some View {
        let dateTime = seWrapper.dateFromJulianDay(result.chart.JulianDay)
        let dateText = String(format: "%04d-%02d-%02d", dateTime.Date.Year, dateTime.Date.Month, dateTime.Date.Day)
        let timeText = String(format: "%02d:%02d:%02d", dateTime.Time.Hour, dateTime.Time.Minute, dateTime.Time.Second)
        let locationText = coordText(result.latitude, isLat: true) + ", " + coordText(result.longitude, isLat: false)

        return VStack(alignment: .leading, spacing: 4) {
            LabeledContent(t(SynastryKeys.combineResultDate)) {
                Text(dateText).monospacedDigit()
            }
            LabeledContent(t(SynastryKeys.combineResultTime)) {
                Text(timeText).monospacedDigit()
            }
            LabeledContent(t(SynastryKeys.combineResultLocation)) {
                Text(locationText).monospacedDigit()
            }
        }
        .frame(maxWidth: 400, alignment: .leading)
    }

    /// Formats a plain geographic coordinate as DMS with a hemisphere letter.
    private func coordText(_ value: Double, isLat: Bool) -> String {
        let absValue = Swift.abs(value)
        let deg = Int(absValue)
        let minFrac = (absValue - Double(deg)) * 60.0
        let min = Int(minFrac)
        let sec = Int((minFrac - Double(min)) * 60.0)
        let hemi: String
        if isLat { hemi = value >= 0 ? "N" : "S" }
        else      { hemi = value >= 0 ? "E" : "W" }
        return String(format: "%d° %02d′ %02d″ %@", deg, min, sec, hemi)
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

    private var configFactors: [Factors] {
        guard let config = activeConfigs.first else { return [] }
        return config.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor }
    }

    private func calculate() {
        let calculationConfig = activeConfigs.first?.calculationConfig ?? CalculationConfig()
        let factors = configFactors.isEmpty
            ? [Factors.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto]
            : configFactors

        let locationMethod: DavisonOrchestrator.LocationMethod
        switch method {
        case .simplified:
            locationMethod = .simplified
        case .original:
            locationMethod = .original
        case .sphericalMidpoint:
            locationMethod = .sphericalMidpoint
        case .referenceLocation:
            let lat = dmsToDecimal(deg: latitudeDegrees, min: latitudeMinutes, sec: latitudeSeconds, negative: latHemi == .south)
            let lon = dmsToDecimal(deg: longitudeDegrees, min: longitudeMinutes, sec: longitudeSeconds, negative: lonHemi == .west)
            locationMethod = .referenceLocation(latitude: lat, longitude: lon)
        }

        davisonResult = DavisonOrchestrator.calculate(
            charts: charts,
            factorsToUse: factors, calculationConfig: calculationConfig,
            method: locationMethod, seWrapper: seWrapper
        )
    }

    private func dmsToDecimal(deg: Int, min: Int, sec: Int, negative: Bool) -> Double {
        let value = Double(deg) + Double(min) / 60.0 + Double(sec) / 3600.0
        return negative ? -value : value
    }
}
