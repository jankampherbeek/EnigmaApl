//
//  RadixSearchScreen.swift
//  EnigmaApl
//

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
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var radixNav: RadixNavigator
    @Environment(\.modelContext) private var modelContext
    @StateObject private var searchModel = RadixSearchModel()

    @State private var query = ""
    @State private var showHelp = false

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
    }

    @ViewBuilder
    private func resultsTable(_ results: [HoroscopeModel]) -> some View {
        GroupBox {
            VStack(spacing: 0) {
                HStack {
                    Text(rs("view.radixsearchscreen.column.name")).frame(maxWidth: .infinity, alignment: .leading)
                    Text(rs("view.radixsearchscreen.column.datetime")).frame(width: 240, alignment: .leading)
                    Text(rs("view.radixsearchscreen.column.location")).frame(width: 160, alignment: .leading)
                    Spacer().frame(width: 80)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)

                Divider()

                ForEach(Array(results.enumerated()), id: \.element.id) { index, horoscope in
                    HStack {
                        Text(horoscope.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(preferredDateTimeLabel(for: horoscope))
                            .frame(width: 240, alignment: .leading)
                            .foregroundStyle(.secondary)
                        Text(horoscope.placeName ?? "–")
                            .frame(width: 160, alignment: .leading)
                            .foregroundStyle(.secondary)
                        Button(rs("view.radixsearchscreen.select")) { select(horoscope) }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .frame(width: 80)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                }
            }
        }
    }

    private func preferredDateTimeLabel(for horoscope: HoroscopeModel) -> String {
        let dt = horoscope.dateTimes.first(where: { $0.isPreferred }) ?? horoscope.dateTimes.first
        return dt?.originalInput ?? "–"
    }

    private func performSearch() {
        searchModel.search(query: query, context: modelContext)
    }

    private func select(_ horoscope: HoroscopeModel) {
        guard let chart = searchModel.calculateChart(for: horoscope) else { return }
        app.latestRadixChart = chart
        radixNav.setInspector(.positions)
    }
}
