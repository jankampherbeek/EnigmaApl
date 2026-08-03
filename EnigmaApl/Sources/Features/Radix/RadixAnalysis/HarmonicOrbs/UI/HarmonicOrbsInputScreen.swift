// HarmonicOrbsInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// Shown in the center column when .analysisHarmonicOrbs is active.
/// Lets the user define a maximum orb and select which aspects participate; the actual orb per
/// aspect is that maximum orb divided by the aspect's harmonic number.
struct HarmonicOrbsInputScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var harmonicOrbsModel: HarmonicOrbsModel
    @EnvironmentObject private var radixNav: RadixNavigator
    @State private var showHelp = false

    private var chartName: String { chartSession.selected?.name ?? "" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Button {
                    radixNav.setInspector(.analysis)
                } label: {
                    Label(t(HarmonicOrbsKeys.backLabel), systemImage: "chevron.left")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Text(String(format: t(HarmonicOrbsKeys.title), chartName))
                    .font(.title2.weight(.semibold))

                if chartSession.selected == nil {
                    Text(t(HarmonicOrbsKeys.noChart))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                GroupBox(label: Text(t(HarmonicOrbsKeys.orbSection)).font(.headline)) {
                    LabeledContent(t(HarmonicOrbsKeys.orbLabel)) {
                        HStack(spacing: 8) {
                            Text("\(harmonicOrbsModel.orbDegrees)°")
                                .frame(width: 36, alignment: .trailing)
                                .monospacedDigit()
                            Stepper("", value: $harmonicOrbsModel.orbDegrees, in: 0...30)
                                .labelsHidden()
                                .fixedSize()
                            Text("\(String(format: "%02d", harmonicOrbsModel.orbMinutes))'")
                                .frame(width: 40, alignment: .trailing)
                                .monospacedDigit()
                            Stepper("", value: $harmonicOrbsModel.orbMinutes, in: 0...59)
                                .labelsHidden()
                                .fixedSize()
                        }
                    }
                    .padding(.vertical, 4)
                }

                Text(t(HarmonicOrbsKeys.aspectsSection))
                    .font(.headline)

                aspectsList
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
            WheelHelpSheet(helpText: t(HarmonicOrbsKeys.helpInput))
        }
    }

    // MARK: - Aspect list

    private let checkboxW: CGFloat = 24
    private let glyphW: CGFloat = 22
    private let nameW: CGFloat = 108
    private let orbW: CGFloat = 84

    @ViewBuilder
    private var aspectsList: some View {
        GroupBox {
            VStack(spacing: 0) {
                HStack(spacing: 6) {
                    Spacer().frame(width: checkboxW)
                    Spacer().frame(width: glyphW)
                    Text(t(HarmonicOrbsKeys.colAspect))
                        .frame(width: nameW, alignment: .leading)
                    Spacer()
                    Text(t(HarmonicOrbsKeys.colEffectiveOrb))
                        .frame(width: orbW, alignment: .trailing)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)

                Divider()

                ForEach(Array(harmonicOrbsModel.settings.enumerated()), id: \.element.id) { index, setting in
                    HStack(spacing: 6) {
                        Toggle(isOn: Binding(
                            get: { harmonicOrbsModel.settings[index].isSelected },
                            set: { harmonicOrbsModel.settings[index].isSelected = $0 }
                        )) {
                            EmptyView()
                        }
                        .labelsHidden()
                        .frame(width: checkboxW, alignment: .leading)

                        Text(GlyphSelector.getGlyphForAspect(setting.aspect))
                            .font(.custom("EnigmaAstrology3", size: 15))
                            .frame(width: glyphW, alignment: .leading)

                        Text(NSLocalizedString(setting.aspect.rbKey, comment: ""))
                            .font(.callout)
                            .frame(width: nameW, alignment: .leading)
                            .lineLimit(1)

                        Spacer()

                        Text(orbText(harmonicOrbsModel.actualOrbDegrees(for: setting)))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                            .frame(width: orbW, alignment: .trailing)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                }
            }
        }
    }

    // MARK: - Helpers

    /// Degrees, minutes and seconds, e.g. "0°24'00\"".
    private func orbText(_ degrees: Double) -> String {
        let totalSeconds = Int((abs(degrees) * 3600).rounded())
        let deg = totalSeconds / 3600
        let min = (totalSeconds % 3600) / 60
        let sec = totalSeconds % 60
        return "\(deg)°\(String(format: "%02d", min))'\(String(format: "%02d", sec))\""
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "HarmonicOrbs", bundle: .main, comment: "")
    }
}
