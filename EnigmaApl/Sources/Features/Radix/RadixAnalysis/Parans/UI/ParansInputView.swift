// ParansInputView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct ParansInputView: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var paranModel:   ParansModel
    @EnvironmentObject private var radixNav:     RadixNavigator
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var orbMinutes: Int = 10
    @State private var orbSeconds: Int = 0
    @State private var showHelp = false

    private var activeConfig: UserConfiguration? { activeConfigs.first }
    private var canCalculate: Bool { chartSession.selected != nil && activeConfig != nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Button {
                    radixNav.setInspector(.analysis)
                } label: {
                    Label(t(ParansKeys.backLabel), systemImage: "chevron.left")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Text(t(ParansKeys.title))
                    .font(.title2.weight(.semibold))

                GroupBox(label: Text(t(ParansKeys.orbSection)).font(.headline)) {
                    LabeledContent(t(ParansKeys.orbLabel)) {
                        HStack(spacing: 8) {
                            Text("\(orbMinutes)'")
                                .frame(width: 32, alignment: .trailing)
                                .monospacedDigit()
                            Stepper("", value: $orbMinutes, in: 0...60)
                                .labelsHidden()
                                .fixedSize()
                            Text("\(String(format: "%02d", orbSeconds))\"")
                                .frame(width: 32, alignment: .trailing)
                                .monospacedDigit()
                            Stepper("", value: $orbSeconds, in: 0...59)
                                .labelsHidden()
                                .fixedSize()
                        }
                    }
                    .padding(.vertical, 4)
                }

                Button(t(ParansKeys.calculate)) {
                    triggerCalculation()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canCalculate || paranModel.isCalculating)

                if paranModel.isCalculating {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text(t(ParansKeys.calculating))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }

                if chartSession.selected == nil {
                    Text(t(ParansKeys.noChart))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 500, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
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
            WheelHelpSheet(helpText: t(ParansKeys.helpInput))
        }
        .onAppear {
            loadOrbFromConfig()
            if canCalculate { triggerCalculation() }
        }
    }

    // MARK: - Helpers

    private func loadOrbFromConfig() {
        guard let config = activeConfig else { return }
        let totalSec = Int((config.fixStarConfig.paranTimeOrb * 60.0).rounded())
        orbMinutes = totalSec / 60
        orbSeconds = totalSec % 60
        if orbMinutes == 0 && orbSeconds == 0 { orbMinutes = 10 }
    }

    private func triggerCalculation() {
        guard let named = chartSession.selected, let config = activeConfig else { return }
        let orbDecimalMinutes = Double(orbMinutes) + Double(orbSeconds) / 60.0
        paranModel.calculate(
            chart: named.chart,
            geoLon: named.baseRequest.Longitude,
            geoLat: named.baseRequest.Latitude,
            height: named.baseRequest.Height,
            factorConfig: config.factorConfig,
            fixStarConfig: config.fixStarConfig,
            calculationConfig: config.calculationConfig,
            paranTimeOrbMinutes: max(1.0 / 60.0, orbDecimalMinutes)
        )
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Parans", bundle: .main, comment: "")
    }
}
