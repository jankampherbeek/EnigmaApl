// EphemerisInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func e(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Ephemeris", bundle: .main, comment: "")
}

struct EphemerisInputScreen: View {
    @EnvironmentObject private var model: EphemerisModel

    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    private let seWrapper = SEWrapper()

    @State private var yearText = ""
    @State private var showHelp = false

    private var availableFactors: [Factors] {
        EphemerisCalculator.availableFactors(for: model.observerPosition)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(e(EphemerisKeys.title))
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 16) {
                    FieldBlock(e(EphemerisKeys.month)) {
                        Picker(e(EphemerisKeys.month), selection: Binding(
                            get: { model.month },
                            set: { model.month = $0; recalculate() }
                        )) {
                            ForEach(1...12, id: \.self) { m in
                                Text(Calendar.current.monthSymbols[m - 1]).tag(m)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .focusable(true)
                        .frame(maxWidth: 140)
                    }

                    FieldBlock(e(EphemerisKeys.year)) {
                        TextField("", text: $yearText)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                            .adaptiveBorder()
                            .onChange(of: yearText) { _, newValue in
                                if let y = Int(newValue), y > 0, y < 10000 {
                                    model.year = y
                                    recalculate()
                                }
                            }
                    }
                }

                FieldBlock(e(EphemerisKeys.observerPosition)) {
                    Picker(e(EphemerisKeys.observerPosition), selection: Binding(
                        get: { model.observerPosition },
                        set: { model.observerPosition = $0; sanitizeFactors(); recalculate() }
                    )) {
                        ForEach(ObserverPositions.allCases.filter { $0 != .topoCentric }, id: \.self) { pos in
                            Text(LocalizedStringKey(pos.rbKey)).tag(pos)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .focusable(true)
                }

                FieldBlock(e(EphemerisKeys.ayanamsha)) {
                    Picker(e(EphemerisKeys.ayanamsha), selection: Binding(
                        get: { model.ayanamsha },
                        set: { model.ayanamsha = $0; recalculate() }
                    )) {
                        ForEach(Ayanamshas.allCases, id: \.self) { ayan in
                            Text(LocalizedStringKey(ayan.rbKey)).tag(ayan)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .focusable(true)
                }

                FieldBlock(e(EphemerisKeys.coordinate)) {
                    Picker(e(EphemerisKeys.coordinate), selection: Binding(
                        get: { model.selectedCoordinate },
                        set: { model.selectedCoordinate = $0; recalculate() }
                    )) {
                        ForEach(EphemerisCoordinate.allCases) { coord in
                            Text(e(coord.labelKey)).tag(coord)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .focusable(true)
                }

                FieldBlock(e(EphemerisKeys.factors)) {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 2
                        ) {
                            ForEach(availableFactors, id: \.rawValue) { factor in
                                EphemerisFactorRow(
                                    factor: factor,
                                    isSelected: model.selectedFactors.contains(factor)
                                ) {
                                    toggleFactor(factor)
                                }
                            }
                        }
                        .padding(4)
                    }
                    .frame(height: 320)
                    .background(Color.primary.opacity(0.04))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.15), lineWidth: 1))
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .controlSize(.small)
        .navigationTitle(e(EphemerisKeys.title))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: e(EphemerisKeys.help))
        }
        .onAppear {
            yearText = String(model.year)
            if model.selectedFactors.isEmpty, let config = activeConfigs.first {
                model.selectedFactors = config.factorConfig.factorSettings
                    .filter(\.isUsed)
                    .map(\.factor)
                    .filter { availableFactors.contains($0) }
                recalculate()
            }
        }
    }

    private func toggleFactor(_ factor: Factors) {
        if model.selectedFactors.contains(factor) {
            model.selectedFactors.removeAll { $0 == factor }
        } else {
            model.selectedFactors.append(factor)
        }
        recalculate()
    }

    private func sanitizeFactors() {
        let available = availableFactors
        model.selectedFactors.removeAll { !available.contains($0) }
    }

    private func recalculate() {
        model.recalculate(seWrapper: seWrapper)
    }
}

private struct EphemerisFactorRow: View {
    let factor: Factors
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let iconName = isSelected ? "checkmark.square.fill" : "square"
        let iconColor: Color = isSelected ? .accentColor : .secondary
        let bgColor: Color = isSelected ? Color.accentColor.opacity(0.1) : .clear
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: iconName).foregroundStyle(iconColor)
                Text(NSLocalizedString(factor.localizedName, comment: "")).foregroundStyle(.primary)
                Spacer()
            }
            .padding(.vertical, 3)
            .padding(.horizontal, 6)
            .background(bgColor)
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}
