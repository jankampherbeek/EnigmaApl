// PrimDirInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "PrimDir", bundle: .main, comment: "")
}

struct PrimDirInputScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var primDirModel: PrimDirModel
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var startDateText: String = ""
    @State private var endDateText: String = ""
    @State private var selectedMethod: PrimaryMethod = .placidus
    @State private var selectedApproach: PrimaryApproach = .mundane
    @State private var selectedTimeKey: PrimaryTimeKey = .naibod
    @State private var showHelp = false

    private var hasChart: Bool { chartSession.selectedChart != nil }
    private var savedConfig: PrimaryDirectionsConfig {
        activeConfigs.first?.progressionsConfig.primaryDirections ?? PrimaryDirectionsConfig()
    }
    private var isModified: Bool {
        selectedMethod != savedConfig.method ||
        selectedApproach != savedConfig.approach ||
        selectedTimeKey != savedConfig.timeKey
    }

    var body: some View {
        Group {
            if !hasChart {
                ContentUnavailableView(
                    t(PrimDirKeys.title),
                    systemImage: "arrow.up.right.circle",
                    description: Text(t(PrimDirKeys.noChart))
                )
            } else {
                form
            }
        }
        .navigationTitle(t(PrimDirKeys.title))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(PrimDirKeys.help))
        }
        .onAppear { syncFromConfig() }
    }

    // MARK: - Form

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(t(PrimDirKeys.title))
                    .font(.title2.weight(.semibold))

                if let name = chartSession.selected?.name {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                dateSection
                settingsOverride
                calculateButton
            }
            .frame(maxWidth: 700, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Date input

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(t(PrimDirKeys.startDateLabel))
                    .font(.subheadline.weight(.medium))
                TextField(t(PrimDirKeys.datePlaceholder), text: $startDateText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(t(PrimDirKeys.endDateLabel))
                    .font(.subheadline.weight(.medium))
                TextField(t(PrimDirKeys.datePlaceholder), text: $endDateText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)
            }
        }
    }

    // MARK: - Settings override

    private var settingsOverride: some View {
        GroupBox(t(PrimDirKeys.settingsHeader)) {
            VStack(alignment: .leading, spacing: 10) {
                Text(t(PrimDirKeys.settingsOverrideNote))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                LabeledContent(t(PrimDirKeys.methodLabel)) {
                    Picker("", selection: $selectedMethod) {
                        ForEach(PrimaryMethod.allCases, id: \.self) { method in
                            Text(NSLocalizedString(method.rbKey, comment: "")).tag(method)
                        }
                    }
                    .labelsHidden()
                    .frame(maxWidth: 200)
                }

                LabeledContent(t(PrimDirKeys.approachLabel)) {
                    Picker("", selection: $selectedApproach) {
                        ForEach(PrimaryApproach.allCases, id: \.self) { approach in
                            Text(NSLocalizedString(approach.rbKey, comment: "")).tag(approach)
                        }
                    }
                    .labelsHidden()
                    .frame(maxWidth: 200)
                }

                LabeledContent(t(PrimDirKeys.timeKeyLabel)) {
                    Picker("", selection: $selectedTimeKey) {
                        ForEach(PrimaryTimeKey.allCases, id: \.self) { key in
                            Text(NSLocalizedString(key.rbKey, comment: "")).tag(key)
                        }
                    }
                    .labelsHidden()
                    .frame(maxWidth: 200)
                }

                if isModified {
                    Button(t(PrimDirKeys.settingsReset)) {
                        syncFromConfig()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(.vertical, 4)
            .font(.callout)
        }
        .frame(maxWidth: 500)
    }

    // MARK: - Calculate button

    private var calculateButton: some View {
        Button(t(PrimDirKeys.calculate)) {
            runCalculation()
        }
        .buttonStyle(.borderedProminent)
        .disabled(!hasChart)
    }

    // MARK: - Helpers

    private func syncFromConfig() {
        let c = savedConfig
        selectedMethod = c.method
        selectedApproach = c.approach
        selectedTimeKey = c.timeKey
    }

    private func runCalculation() {
        guard let namedChart = chartSession.selected else { return }
        let effectiveConfig = PrimaryDirectionsConfig(
            promissors: savedConfig.promissors,
            significators: savedConfig.significators,
            orb: savedConfig.orb,
            method: selectedMethod,
            approach: selectedApproach,
            timeKey: selectedTimeKey
        )
        primDirModel.calculate(
            startDateText: startDateText,
            endDateText: endDateText,
            chart: namedChart.chart,
            geoLat: namedChart.baseRequest.Latitude,
            natalJD: namedChart.baseRequest.JulianDay,
            config: effectiveConfig
        )
    }
}
