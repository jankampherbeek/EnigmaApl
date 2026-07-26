// SynastryInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Synastry", bundle: .main, comment: "")
}

struct SynastryInputScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var synastryModel: SynastryModel
    @EnvironmentObject private var synastryNav: SynastryNavigator
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var query = ""
    @State private var showHelp = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(t(SynastryKeys.title))
                        .font(.title2.weight(.semibold))
                    Spacer()
                    Button { showHelp = true } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Help")
                }

                selectedSection
                sessionSection
                searchSection
                actionButtons
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(SynastryKeys.title))
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(SynastryKeys.helpInput))
        }
        .onChange(of: synastryModel.selectedCharts.map(\.id)) { _, _ in
            synastryNav.closeResult()
        }
    }

    // MARK: - Selected charts

    @ViewBuilder
    private var selectedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t(SynastryKeys.selectedHeader))
                .font(.headline)

            if synastryModel.selectedCharts.isEmpty {
                Text(t(SynastryKeys.selectedEmpty))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                GroupBox {
                    VStack(spacing: 0) {
                        ForEach(Array(synastryModel.selectedCharts.enumerated()), id: \.element.id) { index, named in
                            HStack {
                                Text(named.name)
                                Spacer()
                                Button(role: .destructive) {
                                    synastryModel.removeChart(id: named.id)
                                } label: {
                                    Label(t(SynastryKeys.remove), systemImage: "xmark.circle")
                                        .labelStyle(.iconOnly)
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                        }
                    }
                }
                if !synastryModel.canCombine {
                    Text(t(SynastryKeys.selectedMinHint))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Quick add from session

    @ViewBuilder
    private var sessionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t(SynastryKeys.sessionHeader))
                .font(.headline)

            if chartSession.charts.isEmpty {
                Text(t(SynastryKeys.sessionEmpty))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                GroupBox {
                    VStack(spacing: 0) {
                        ForEach(Array(chartSession.charts.enumerated()), id: \.element.id) { index, named in
                            let alreadySelected = synastryModel.isSelected(named)
                            HStack {
                                Text(named.name)
                                Spacer()
                                if alreadySelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                } else {
                                    Image(systemName: "plus.circle")
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                            .contentShape(Rectangle())
                            .opacity(alreadySelected ? 0.5 : 1.0)
                            .onTapGesture {
                                guard !alreadySelected else { return }
                                synastryModel.addFromSession(named)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Search

    @ViewBuilder
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t(SynastryKeys.searchHeader))
                .font(.headline)

            HStack(alignment: .bottom, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(t(SynastryKeys.searchPartOfName))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("", text: $query)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 200, maxWidth: 400)
                        .onSubmit { performSearch() }
                }
                Button(t(SynastryKeys.searchButton)) { performSearch() }
                    .buttonStyle(.borderedProminent)
                    .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if let error = synastryModel.searchError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if !synastryModel.searchResults.isEmpty {
                GroupBox {
                    VStack(spacing: 0) {
                        ForEach(Array(synastryModel.searchResults.enumerated()), id: \.element.id) { index, horoscope in
                            HStack {
                                Text(horoscope.name)
                                Spacer()
                                Text(horoscope.placeName ?? "–")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                            .contentShape(Rectangle())
                            .onTapGesture { addFromSearch(horoscope) }
                        }
                    }
                }
            } else if synastryModel.searchError == nil && !query.isEmpty {
                Text(t(SynastryKeys.searchNoResults))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
    }

    // MARK: - Action buttons

    @ViewBuilder
    private var actionButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Button(t(SynastryKeys.buttonCompare)) { synastryNav.showResult(.compare) }
                    .buttonStyle(.borderedProminent)
                    .disabled(!synastryModel.canCompare)
                Button(t(SynastryKeys.buttonComposite)) { synastryNav.showResult(.composite) }
                    .buttonStyle(.borderedProminent)
                    .disabled(!synastryModel.canComposite)
                Button(t(SynastryKeys.buttonCombine)) { synastryNav.showResult(.combine) }
                    .buttonStyle(.borderedProminent)
                    .disabled(!synastryModel.canCombine)
            }
            HStack(spacing: 12) {
                Button(t(SynastryKeys.buttonAspectComparison)) { synastryNav.showResult(.aspectComparison) }
                    .buttonStyle(.borderedProminent)
                    .disabled(!synastryModel.canCompare)
                Button(t(SynastryKeys.buttonMidpointComparison)) { synastryNav.showResult(.midpointComparison) }
                    .buttonStyle(.borderedProminent)
                    .disabled(!synastryModel.canCompare)
                Button(t(SynastryKeys.buttonDeclinationComparison)) { synastryNav.showResult(.declinationComparison) }
                    .buttonStyle(.borderedProminent)
                    .disabled(!synastryModel.canCompare)
            }
        }
    }

    // MARK: - Helpers

    private func performSearch() {
        synastryModel.search(query: query, context: modelContext)
    }

    private var configFactors: [Factors] {
        guard let config = activeConfigs.first else { return [] }
        return config.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor }
    }

    private func addFromSearch(_ horoscope: HoroscopeModel) {
        let factors = configFactors.isEmpty ? [Factors.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto] : configFactors
        synastryModel.addChart(from: horoscope, factorsToUse: factors, calculationConfig: activeConfigs.first?.calculationConfig ?? CalculationConfig())
    }
}
