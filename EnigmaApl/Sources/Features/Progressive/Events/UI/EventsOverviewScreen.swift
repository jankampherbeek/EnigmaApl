// EventsOverviewScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "EventsOverview", bundle: .main, comment: "")
}

struct EventsOverviewScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @Environment(\.modelContext) private var modelContext
    @StateObject private var model = EventsOverviewModel()

    @State private var selectedChartId: UUID?
    @State private var eventToDelete: EventModel?
    @State private var showDeleteConfirmation = false
    @State private var showHelp = false
    @State private var showCreateEvent = false
    @State private var eventToEdit: EventModel?

    private let titleWidth: CGFloat    = 200
    private let dateTimeWidth: CGFloat = 180
    private let locationWidth: CGFloat = 130
    private let selectWidth: CGFloat   = 90
    private let editWidth: CGFloat     = 75
    private let deleteWidth: CGFloat   = 85

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(t(EventsOverviewKeys.title))
                    .font(.title2.weight(.semibold))

                if let errorMessage = model.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                chartPickerSection
                createButton
                eventsSection
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(EventsOverviewKeys.title))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(EventsOverviewKeys.help))
        }
        .alert(
            t(EventsOverviewKeys.deleteAlertTitle),
            isPresented: $showDeleteConfirmation,
            presenting: eventToDelete
        ) { event in
            Button(t(EventsOverviewKeys.deleteConfirm), role: .destructive) {
                model.delete(event)
            }
            Button(t(EventsOverviewKeys.deleteCancel), role: .cancel) {}
        } message: { event in
            Text(String(format: t(EventsOverviewKeys.deleteAlertMessage), event.title))
        }
        .sheet(isPresented: $showCreateEvent) {
            if let horoscope = model.horoscope {
                NavigationStack {
                    EventInputScreen(horoscope: horoscope) {
                        model.reload()
                    }
                }
            }
        }
        .onAppear {
            model.setup(context: modelContext)
            if let chart = chartSession.selected {
                selectedChartId = chart.id
                model.loadHoroscope(matching: chart)
            }
        }
        .onChange(of: selectedChartId) { _, newId in
            if let id = newId,
               let chart = chartSession.charts.first(where: { $0.id == id }) {
                model.loadHoroscope(matching: chart)
            }
        }
    }

    // MARK: - Chart picker

    private var chartPickerSection: some View {
        Group {
            if chartSession.charts.isEmpty {
                Text(t(EventsOverviewKeys.noSession))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                HStack(spacing: 8) {
                    Text(t(EventsOverviewKeys.chartSection))
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

    // MARK: - Create button

    private var createButton: some View {
        Button(t(EventsOverviewKeys.create)) {
            showCreateEvent = true
        }
        .buttonStyle(.borderedProminent)
        .disabled(model.horoscope == nil)
    }

    // MARK: - Events list

    @ViewBuilder
    private var eventsSection: some View {
        if model.horoscope == nil && !chartSession.charts.isEmpty {
            EmptyView()
        } else if model.events.isEmpty {
            Text(t(EventsOverviewKeys.empty))
                .foregroundStyle(.secondary)
                .font(.callout)
        } else {
            GroupBox(t(EventsOverviewKeys.eventsHeader)) {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        columnHeaders
                        Divider()
                        ForEach(Array(model.events.enumerated()), id: \.element.id) { index, event in
                            eventRow(event, index: index)
                        }
                    }
                }
            }
        }
    }

    private var columnHeaders: some View {
        HStack(spacing: 12) {
            Text(t(EventsOverviewKeys.columnTitle))
                .frame(width: titleWidth, alignment: .leading)
            Text(t(EventsOverviewKeys.columnDateTime))
                .frame(width: dateTimeWidth, alignment: .leading)
            Text(t(EventsOverviewKeys.columnLocation))
                .frame(width: locationWidth, alignment: .leading)
            Spacer().frame(width: selectWidth)
            Spacer().frame(width: editWidth)
            Spacer().frame(width: deleteWidth)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func eventRow(_ event: EventModel, index: Int) -> some View {
        let isSelected = model.selectedEvent?.id == event.id
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

            Text(event.placeName ?? "–")
                .frame(width: locationWidth, alignment: .leading)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Button(t(EventsOverviewKeys.select)) {
                model.select(event)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .frame(width: selectWidth)

            Button(t(EventsOverviewKeys.edit)) {
                eventToEdit = event
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .frame(width: editWidth)

            Button(t(EventsOverviewKeys.delete)) {
                eventToDelete = event
                showDeleteConfirmation = true
            }
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
