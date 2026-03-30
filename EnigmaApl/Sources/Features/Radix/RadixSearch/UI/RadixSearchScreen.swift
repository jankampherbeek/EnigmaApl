// RadixSearchScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func rs(_ key: String) -> String {
    NSLocalizedString(key, tableName: "RadixSearch", bundle: .main, comment: "")
}

private struct RadixSearchHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(rs("view.radixsearchscreen.help.text"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle(rs("view.radixsearchscreen.help.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(rs("view.radixsearchscreen.help.close")) { dismiss() }
                }
            }
        }
    }
}

struct RadixSearchScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var radixNav: RadixNavigator
    @Environment(\.modelContext) private var modelContext
    @StateObject private var searchModel = RadixSearchModel()
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var query = ""
    @State private var showHelp = false
    @State private var horoscopeToDelete: HoroscopeModel? = nil
    @State private var showDeleteConfirmation = false
    @State private var showDeleteError = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(rs("view.radixsearchscreen.title"))
                    .font(.title2.weight(.semibold))

                HStack(alignment: .bottom, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(rs("view.radixsearchscreen.partofname"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("", text: $query)
                            .textFieldStyle(.roundedBorder)
                            .frame(minWidth: 200, maxWidth: 400)
                            .onSubmit { performSearch() }
                    }
                    Button(rs("view.radixsearchscreen.search")) { performSearch() }
                        .buttonStyle(.borderedProminent)
                        .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                if let error = searchModel.searchError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                if showDeleteError {
                    Text(rs("view.radixsearchscreen.delete.failed"))
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                if !searchModel.results.isEmpty {
                    resultsTable(searchModel.results)
                } else if searchModel.searchError == nil && !query.isEmpty {
                    Text(rs("view.radixsearchscreen.noresults"))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(rs("view.radixsearchscreen.title"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showHelp = true
                } label: {
                    Label(rs("view.radixsearchscreen.help.title"), systemImage: "questionmark.circle")
                }
            }
        }
        .sheet(isPresented: $showHelp) {
            RadixSearchHelpView()
        }
        .alert(rs("view.radixsearchscreen.delete.title"), isPresented: $showDeleteConfirmation, presenting: horoscopeToDelete) { horoscope in
            Button(rs("view.radixsearchscreen.delete.confirm"), role: .destructive) {
                confirmDelete(horoscope)
            }
            Button(rs("view.radixsearchscreen.delete.cancel"), role: .cancel) { }
        } message: { horoscope in
            Text(String(format: rs("view.radixsearchscreen.delete.message"), horoscope.name))
        }
    }

    private let nameWidth: CGFloat = 200
    private let dateTimeWidth: CGFloat = 200
    private let locationWidth: CGFloat = 140
    private let selectWidth: CGFloat = 80
    private let editWidth: CGFloat = 70
    private let deleteWidth: CGFloat = 80

    @ViewBuilder
    private func resultsTable(_ results: [HoroscopeModel]) -> some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Text(rs("view.radixsearchscreen.column.name")).frame(width: nameWidth, alignment: .leading)
                        Text(rs("view.radixsearchscreen.column.datetime")).frame(width: dateTimeWidth, alignment: .leading)
                        Text(rs("view.radixsearchscreen.column.location")).frame(width: locationWidth, alignment: .leading)
                        Spacer().frame(width: selectWidth)
                        Spacer().frame(width: editWidth)
                        Spacer().frame(width: deleteWidth)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)

                    Divider()

                    ForEach(Array(results.enumerated()), id: \.element.id) { index, horoscope in
                        HStack(spacing: 12) {
                            Text(horoscope.name)
                                .frame(width: nameWidth, alignment: .leading)
                                .lineLimit(1)
                            Text(preferredDateTimeLabel(for: horoscope))
                                .frame(width: dateTimeWidth, alignment: .leading)
                                .foregroundStyle(.secondary)
                            Text(horoscope.placeName ?? "–")
                                .frame(width: locationWidth, alignment: .leading)
                                .foregroundStyle(.secondary)
                            Button(rs("view.radixsearchscreen.select")) { select(horoscope) }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .frame(width: selectWidth)
                            Button(rs("view.radixsearchscreen.edit")) { editHoroscope(horoscope) }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .frame(width: editWidth)
                            Button(rs("view.radixsearchscreen.delete")) { startDelete(horoscope) }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .frame(width: deleteWidth)
                                .tint(.red)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                    }
                }
            }
        }
    }

    private func preferredDateTimeLabel(for horoscope: HoroscopeModel) -> String {
        let dt = horoscope.dateTimes.first(where: { $0.isPreferred }) ?? horoscope.dateTimes.first
        return dt?.originalInput ?? "–"
    }

    private func performSearch() {
        showDeleteError = false
        searchModel.search(query: query, context: modelContext)
    }

    private var configFactors: [Factors] {
        guard let config = activeConfigs.first else { return [] }
        return config.factorConfig.factorSettings.filter { $0.isUsed }.map { $0.factor }
    }

    private func select(_ horoscope: HoroscopeModel) {
        let factors = configFactors.isEmpty ? [Factors.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto] : configFactors
        guard let (chart, request) = searchModel.calculateChart(for: horoscope, factorsToUse: factors) else { return }
        chartSession.add(name: horoscope.name, chart: chart, baseRequest: request)
        radixNav.setInspector(.positions)
    }

    private func startDelete(_ horoscope: HoroscopeModel) {
        horoscopeToDelete = horoscope
        showDeleteConfirmation = true
    }

    private func confirmDelete(_ horoscope: HoroscopeModel) {
        do {
            let repository = HoroscopeRepository(context: modelContext)
            try repository.delete(horoscope)
            chartSession.removeFromSession(horoscope: horoscope)
            performSearch()
        } catch {
            showDeleteError = true
        }
    }

    private func editHoroscope(_ horoscope: HoroscopeModel) {
        chartSession.editingHoroscope = horoscope
        chartSession.editingNamedChart = nil
        radixNav.setInspector(.editChart)
    }
}
