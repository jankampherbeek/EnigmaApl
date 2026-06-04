// AgePointInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "AgePoint", bundle: .main, comment: "")
}

struct AgePointInputScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var progressiveSession: ProgressiveSession
    @EnvironmentObject private var agePointModel: AgePointModel

    @State private var selectedMode: AgePointMode = .overview
    @State private var showHelp = false

    private var hasEvent: Bool { progressiveSession.selectedEvent != nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(AgePointKeys.title))
                    .font(.title2.weight(.semibold))

                modePicker
                houseSystemPicker
                calculateButton
            }
            .frame(maxWidth: 700, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(AgePointKeys.title))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(AgePointKeys.help))
        }
        .onChange(of: hasEvent) { _, newValue in
            if !newValue { selectedMode = .overview }
        }
    }

    // MARK: - Mode picker

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            radioOption(title: t(AgePointKeys.modePositionsForEvent), mode: .positionsForEvent)
                .disabled(!hasEvent)
            radioOption(title: t(AgePointKeys.modeOverview), mode: .overview)
        }
    }

    private func radioOption(title: String, mode: AgePointMode) -> some View {
        Button {
            selectedMode = mode
        } label: {
            HStack(spacing: 6) {
                Image(systemName: selectedMode == mode ? "circle.inset.filled" : "circle")
                    .imageScale(.medium)
                Text(title)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - House system picker

    private var houseSystemPicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t(AgePointKeys.houseSystemLabel))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Picker("", selection: $agePointModel.selectedHouseSystem) {
                ForEach(HouseSystems.allCases.filter { $0 != .noHouses && $0 != .gauquelin }, id: \.self) { system in
                    Text(NSLocalizedString(system.localizedName, bundle: .main, comment: ""))
                        .tag(system as HouseSystems)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(maxWidth: 300, alignment: .leading)
        }
    }

    // MARK: - Calculate button

    private var calculateButton: some View {
        Button(t(AgePointKeys.calculate)) {
            let cusps = chartSession.houseCuspLongitudes(for: agePointModel.selectedHouseSystem)
            agePointModel.calculate(
                mode: selectedMode,
                chart: chartSession.selectedChart,
                cusps: cusps,
                event: progressiveSession.selectedEvent
            )
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedMode == .positionsForEvent && !hasEvent)
    }
}
