// FixStarInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "FixStar", bundle: .main, comment: "")
}

struct FixStarInputScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var fixStarModel: FixStarModel
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var orbDeg: Int = 1
    @State private var orbMin: Int = 0
    @State private var orbSec: Int = 0

    private var activeConfig: UserConfiguration? { activeConfigs.first }
    private var orb: Double { Double(orbDeg) + Double(orbMin) / 60.0 + Double(orbSec) / 3600.0 }
    private var canCalculate: Bool { chartSession.selected != nil && activeConfig != nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(FixStarKeys.title))
                    .font(.title2.weight(.semibold))

                GroupBox(t(FixStarKeys.orbSection)) {
                    LabeledContent(t(FixStarKeys.orbLabel)) {
                        HStack(spacing: 4) {
                            Text("\(orbDeg)°")
                                .frame(width: 30, alignment: .trailing)
                                .monospacedDigit()
                            Stepper("", value: $orbDeg, in: 0...10)
                                .labelsHidden().fixedSize()
                            Text("\(orbMin)'")
                                .frame(width: 30, alignment: .trailing)
                                .monospacedDigit()
                            Stepper("", value: $orbMin, in: 0...59)
                                .labelsHidden().fixedSize()
                            Text("\(orbSec)\"")
                                .frame(width: 30, alignment: .trailing)
                                .monospacedDigit()
                            Stepper("", value: $orbSec, in: 0...59)
                                .labelsHidden().fixedSize()
                        }
                    }
                }

                Button(t(FixStarKeys.calculate)) {
                    guard let config = activeConfig else { return }
                    fixStarModel.calculate(
                        chart: chartSession.selected?.chart,
                        config: config,
                        orbOverride: orb
                    )
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canCalculate)

                if chartSession.selected == nil {
                    Text(t(FixStarKeys.noChart))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 700, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            loadOrbFromConfig()
            autoCalculate()
        }
    }

    private func loadOrbFromConfig() {
        guard let config = activeConfig else { return }
        let totalSec = Int((config.fixStarConfig.fixStarOrb * 3600.0).rounded())
        orbDeg = totalSec / 3600
        orbMin = (totalSec % 3600) / 60
        orbSec = totalSec % 60
    }

    private func autoCalculate() {
        guard canCalculate, let config = activeConfig else { return }
        fixStarModel.calculate(
            chart: chartSession.selected?.chart,
            config: config,
            orbOverride: orb
        )
    }
}
