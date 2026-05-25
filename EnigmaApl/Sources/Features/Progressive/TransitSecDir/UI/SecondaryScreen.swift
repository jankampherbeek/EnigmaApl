// SecondaryScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Secondary", bundle: .main, comment: "")
}

struct SecondaryScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var secondaryModel: SecondaryModel
    @EnvironmentObject private var progressiveSession: ProgressiveSession
    @Environment(\.modelContext) private var modelContext

    @State private var selectedChartId: UUID?
    @State private var showCreateEvent = false

    private let titleWidth: CGFloat    = 200
    private let dateTimeWidth: CGFloat = 180
    private let locationWidth: CGFloat = 130
    private let selectWidth: CGFloat   = 90

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(SecondaryKeys.title))
                    .font(.title2.weight(.semibold))

                if let error = secondaryModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                chartPickerSection
                createEventButton
                eventsSection
                calculateButton
            }
            .frame(maxWidth: 700, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(SecondaryKeys.title))
        .sheet(isPresented: $showCreateEvent) {
            if let horoscope = secondaryModel.horoscope {
                NavigationStack {
                    EventInputScreen(horoscope: horoscope) {
                        secondaryModel.reload()
                    }
                }
            }
        }
        .onAppear {
            secondaryModel.setup(context: modelContext)
            secondaryModel.setSession(progressiveSession)
            if let chart = chartSession.selected {
                selectedChartId = chart.id
                secondaryModel.loadHoroscope(matching: chart)
            }
        }
        .onChange(of: selectedChartId) { _, newId in
            guard let id = newId,
                  let chart = chartSession.charts.first(where: { $0.id == id }) else { return }
            secondaryModel.loadHoroscope(matching: chart)
        }
    }

    // MARK: - Chart picker

    private var chartPickerSection: some View {
        Group {
            if chartSession.charts.isEmpty {
                Text(t(SecondaryKeys.noChart))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                HStack(spacing: 8) {
                    Text(t(SecondaryKeys.chartLabel))
                        .font(.subheadline.weight(.medium))
                    Picker("", selection: $selectedChartId) {
                        ForEach(chartSession.charts) { named in
                            Text(named.name).tag(Optional(named.id))
                        }
                    }
                    .labelsHidden()
                    .frame(maxWidth: 300)
                }
            }
        }
    }

    // MARK: - Create event button

    private var createEventButton: some View {
        Button(t(SecondaryKeys.createEvent)) {
            showCreateEvent = true
        }
        .buttonStyle(.bordered)
        .disabled(secondaryModel.horoscope == nil)
    }

    // MARK: - Events list

    @ViewBuilder
    private var eventsSection: some View {
        if secondaryModel.horoscope != nil && secondaryModel.events.isEmpty {
            Text(t(SecondaryKeys.noEvents))
                .foregroundStyle(.secondary)
                .font(.callout)
        } else if !secondaryModel.events.isEmpty {
            GroupBox(t(SecondaryKeys.eventsHeader)) {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        columnHeaders
                        Divider()
                        ForEach(Array(secondaryModel.events.enumerated()), id: \.element.id) { index, event in
                            eventRow(event, index: index)
                        }
                    }
                }
            }
        }
    }

    private var columnHeaders: some View {
        HStack(spacing: 12) {
            Text(t(SecondaryKeys.columnTitle))
                .frame(width: titleWidth, alignment: .leading)
            Text(t(SecondaryKeys.columnDateTime))
                .frame(width: dateTimeWidth, alignment: .leading)
            Text(t(SecondaryKeys.columnLocation))
                .frame(width: locationWidth, alignment: .leading)
            Spacer().frame(width: selectWidth)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func eventRow(_ event: EventModel, index: Int) -> some View {
        let isSelected = secondaryModel.selectedEvent?.id == event.id
        return HStack(spacing: 12) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                        .imageScale(.small)
                }
                Text(event.title)
                    .lineLimit(1)
            }
            .frame(width: titleWidth, alignment: .leading)

            Text(event.originalInput ?? String(format: "%.4f", event.julianDate))
                .frame(width: dateTimeWidth, alignment: .leading)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text(event.location ?? event.placeName ?? "–")
                .frame(width: locationWidth, alignment: .leading)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Button(t(SecondaryKeys.select)) {
                secondaryModel.select(event)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .frame(width: selectWidth)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Calculate button

    private var calculateButton: some View {
        Button(t(SecondaryKeys.calculate)) {
            secondaryModel.calculate()
        }
        .buttonStyle(.borderedProminent)
        .disabled(secondaryModel.selectedEvent == nil)
    }
}
