// SolarInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "SolarReturn", bundle: .main, comment: "")
}

struct SolarInputScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var solarReturnModel: SolarReturnModel
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var ageText: String = ""
    @State private var useSidereal: Bool = false
    @State private var geoLongText: String = ""
    @State private var geoLatText: String = ""
    @State private var longDirection: Int = 0   // 0 = East, 1 = West
    @State private var latDirection: Int = 0    // 0 = North, 1 = South
    @State private var showHelp = false
    @State private var validationError: String?

    private var hasChart: Bool { chartSession.selectedChart != nil }

    var body: some View {
        Group {
            if !hasChart {
                ContentUnavailableView(
                    t(SolarReturnKeys.title),
                    systemImage: "sun.max",
                    description: Text(t(SolarReturnKeys.noChart))
                )
            } else {
                form
            }
        }
        .navigationTitle(t(SolarReturnKeys.title))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(SolarReturnKeys.help))
        }
    }

    // MARK: - Form

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(t(SolarReturnKeys.title))
                    .font(.title2.weight(.semibold))

                if let name = chartSession.selected?.name {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                ageSection
                siderealSection
                relocationSection

                if let error = validationError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                calculateButton
            }
            .frame(maxWidth: 700, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Age input

    private var ageSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t(SolarReturnKeys.ageLabel))
                .font(.subheadline.weight(.medium))
            TextField(t(SolarReturnKeys.agePlaceholder), text: $ageText)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 200)
#if os(iOS)
                .keyboardType(.numberPad)
#endif
        }
    }

    // MARK: - Sidereal toggle

    private var siderealSection: some View {
        Toggle(t(SolarReturnKeys.siderealLabel), isOn: $useSidereal)
            .frame(maxWidth: 300)
    }

    // MARK: - Relocation

    private var relocationSection: some View {
        GroupBox(t(SolarReturnKeys.relocationHeader)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(t(SolarReturnKeys.longitudeLabel))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        TextField("ddd:mm:ss", text: $geoLongText)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 140)
                    }
                    Picker("", selection: $longDirection) {
                        Text(t(SolarReturnKeys.east)).tag(0)
                        Text(t(SolarReturnKeys.west)).tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 120)
                }

                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(t(SolarReturnKeys.latitudeLabel))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        TextField("dd:mm:ss", text: $geoLatText)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 140)
                    }
                    Picker("", selection: $latDirection) {
                        Text(t(SolarReturnKeys.north)).tag(0)
                        Text(t(SolarReturnKeys.south)).tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 120)
                }
            }
            .padding(.vertical, 4)
        }
        .frame(maxWidth: 400)
    }

    // MARK: - Calculate button

    private var calculateButton: some View {
        Button(t(SolarReturnKeys.calculate)) {
            runCalculation()
        }
        .buttonStyle(.borderedProminent)
        .disabled(!hasChart)
    }

    // MARK: - Calculation

    private func runCalculation() {
        validationError = nil

        guard let ageValue = Int(ageText.trimmingCharacters(in: .whitespaces)), ageValue > 0 else {
            validationError = "Please enter a valid age (integer > 0)."
            return
        }

        guard let chart = chartSession.selectedChart else { return }
        let config = activeConfigs.first

        // Parse relocation; fall back to birth location (0,0) when both fields empty
        let geoLong: Double
        let geoLat: Double
        let longEmpty = geoLongText.trimmingCharacters(in: .whitespaces).isEmpty
        let latEmpty  = geoLatText.trimmingCharacters(in: .whitespaces).isEmpty

        if longEmpty && latEmpty {
            geoLong = chartSession.selected?.baseRequest.Longitude ?? 0.0
            geoLat  = chartSession.selected?.baseRequest.Latitude  ?? 0.0
        } else {
            guard let parsedLong = parseDms(geoLongText),
                  let parsedLat  = parseDms(geoLatText) else {
                validationError = "Invalid coordinates. Use format ddd:mm:ss."
                return
            }
            geoLong = longDirection == 1 ? -parsedLong : parsedLong
            geoLat  = latDirection  == 1 ? -parsedLat  : parsedLat
        }

        let calcConfig = config?.calculationConfig ?? CalculationConfig()
        let factors: [Factors] = config.map {
            $0.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor }
        } ?? [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto]

        solarReturnModel.calculate(
            age:               ageValue,
            useSidereal:       useSidereal,
            geoLong:           geoLong,
            geoLat:            geoLat,
            chart:             chart,
            factors:           factors,
            calculationConfig: calcConfig
        )
    }

    // MARK: - Helpers

    private func parseDms(_ text: String) -> Double? {
        let parts = text.trimmingCharacters(in: .whitespaces).split(separator: ":").map { String($0) }
        guard parts.count >= 2,
              let degrees = Int(parts[0]),
              let minutes = Int(parts[1]) else { return nil }
        let seconds = parts.count >= 3 ? (Int(parts[2]) ?? 0) : 0
        return Double(degrees) + Double(minutes) / 60.0 + Double(seconds) / 3600.0
    }
}
