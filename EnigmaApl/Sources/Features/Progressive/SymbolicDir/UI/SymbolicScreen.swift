// SymbolicScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "SymbolicDir", bundle: .main, comment: "")
}

struct SymbolicScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var symbolicModel: SymbolicModel
    @EnvironmentObject private var progressiveSession: ProgressiveSession
    @Environment(\.modelContext) private var modelContext

    @State private var selectedChartId: UUID?
    @State private var showCreateEvent = false
    @State private var showFactsheet = false
    @State private var showHelp = false

    private let titleWidth: CGFloat    = 200
    private let dateTimeWidth: CGFloat = 180
    private let locationWidth: CGFloat = 130
    private let selectWidth: CGFloat   = 90

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(SymbolicDirKeys.title))
                    .font(.title2.weight(.semibold))

                if let error = symbolicModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                chartPickerSection
                arcMethodPicker
                createEventButton
                eventsSection
                calculateButton
            }
            .frame(maxWidth: 700, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(SymbolicDirKeys.title))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showFactsheet = true } label: {
                    Image(systemName: "book.pages")
                }
                .accessibilityLabel("Factsheet")
            }
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showFactsheet) {
            FactsheetView(baseName: "symbolic")
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(SymbolicDirKeys.help))
        }
        .sheet(isPresented: $showCreateEvent) {
            if let horoscope = symbolicModel.horoscope {
                NavigationStack {
                    EventInputScreen(horoscope: horoscope) {
                        symbolicModel.reload()
                    }
                }
            }
        }
        .onAppear {
            symbolicModel.setup(context: modelContext)
            symbolicModel.setSession(progressiveSession)
            if let chart = chartSession.selected {
                selectedChartId = chart.id
                symbolicModel.loadHoroscope(matching: chart)
            }
        }
        .onChange(of: selectedChartId) { _, newId in
            guard let id = newId,
                  let chart = chartSession.charts.first(where: { $0.id == id }) else { return }
            symbolicModel.loadHoroscope(matching: chart)
        }
    }

    // MARK: - Chart picker

    private var chartPickerSection: some View {
        Group {
            if chartSession.charts.isEmpty {
                Text(t(SymbolicDirKeys.noChart))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                HStack(spacing: 8) {
                    Text(t(SymbolicDirKeys.chartLabel))
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

    // MARK: - Arc method picker

    private var arcMethodPicker: some View {
        HStack(spacing: 8) {
            Text(t(SymbolicDirKeys.arcMethodLabel))
                .font(.subheadline.weight(.medium))
            Picker("", selection: $symbolicModel.selectedSymbolicKey) {
                ForEach(SymbolicKeys.allCases, id: \.self) { key in
                    Text(NSLocalizedString(key.rbKey, comment: "")).tag(key)
                }
            }
            .labelsHidden()
            .frame(maxWidth: 250)
        }
    }

    // MARK: - Create event button

    private var createEventButton: some View {
        Button(t(SymbolicDirKeys.createEvent)) {
            showCreateEvent = true
        }
        .buttonStyle(.bordered)
        .disabled(symbolicModel.horoscope == nil)
    }

    // MARK: - Events list

    @ViewBuilder
    private var eventsSection: some View {
        if symbolicModel.horoscope != nil && symbolicModel.events.isEmpty {
            Text(t(SymbolicDirKeys.noEvents))
                .foregroundStyle(.secondary)
                .font(.callout)
        } else if !symbolicModel.events.isEmpty {
            GroupBox(t(SymbolicDirKeys.eventsHeader)) {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        columnHeaders
                        Divider()
                        ForEach(Array(symbolicModel.events.enumerated()), id: \.element.id) { index, event in
                            eventRow(event, index: index)
                        }
                    }
                }
            }
        }
    }

    private var columnHeaders: some View {
        HStack(spacing: 12) {
            Text(t(SymbolicDirKeys.columnTitle))
                .frame(width: titleWidth, alignment: .leading)
            Text(t(SymbolicDirKeys.columnDateTime))
                .frame(width: dateTimeWidth, alignment: .leading)
            Text(t(SymbolicDirKeys.columnLocation))
                .frame(width: locationWidth, alignment: .leading)
            Spacer().frame(width: selectWidth)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func eventRow(_ event: EventModel, index: Int) -> some View {
        let isSelected = symbolicModel.selectedEvent?.id == event.id
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

            Button(t(SymbolicDirKeys.select)) {
                symbolicModel.select(event)
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
        Button(t(SymbolicDirKeys.calculate)) {
            symbolicModel.calculate()
        }
        .buttonStyle(.borderedProminent)
        .disabled(symbolicModel.selectedEvent == nil)
    }
}
