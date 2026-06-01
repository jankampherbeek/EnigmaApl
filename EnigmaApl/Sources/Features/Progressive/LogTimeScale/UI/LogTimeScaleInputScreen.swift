// LogTimeScaleInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "LogTimeScale", bundle: .main, comment: "")
}

struct LogTimeScaleInputScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var progressiveSession: ProgressiveSession
    @EnvironmentObject private var logTimeScaleModel: LogTimeScaleModel

    @State private var selectedMode: LogTimeScaleMode = .overview

    private var hasEvent: Bool { progressiveSession.selectedEvent != nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(LogTimeScaleKeys.title))
                    .font(.title2.weight(.semibold))

                modePicker
                calculateButton
            }
            .frame(maxWidth: 700, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(LogTimeScaleKeys.title))
        .onChange(of: hasEvent) { _, newValue in
            if !newValue { selectedMode = .overview }
        }
    }

    // MARK: - Mode picker

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            radioOption(title: t(LogTimeScaleKeys.modePositionsForEvent), mode: .positionsForEvent)
                .disabled(!hasEvent)
            radioOption(title: t(LogTimeScaleKeys.modeOverview), mode: .overview)
        }
    }

    private func radioOption(title: String, mode: LogTimeScaleMode) -> some View {
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

    // MARK: - Calculate button

    private var calculateButton: some View {
        Button(t(LogTimeScaleKeys.calculate)) {
            logTimeScaleModel.calculate(
                mode: selectedMode,
                chart: chartSession.selectedChart,
                event: progressiveSession.selectedEvent
            )
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedMode == .positionsForEvent && !hasEvent)
    }
}
