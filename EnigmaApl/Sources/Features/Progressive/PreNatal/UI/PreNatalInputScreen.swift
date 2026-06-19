// PreNatalInputScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "PreNatal", bundle: .main, comment: "")
}

struct PreNatalInputScreen: View {
    @EnvironmentObject private var chartSession: ChartSession
    @EnvironmentObject private var model: PreNatalModel
    @Environment(\.modelContext) private var modelContext

    @State private var showFactorSheet = false
    @State private var showAspectSheet = false
    @State private var showHelp = false
    @State private var showNewEventSheet = false

    // Events + combine state
    @State private var selectedEventID: UUID? = nil
    @State private var combineDate: String = ""
    @State private var combineTime: String = "12:00:00"
    @State private var combineError: String? = nil
    @State private var currentHoroscope: HoroscopeModel? = nil
    @State private var displayEvents: [EventDisplay] = []

    private var hasChart: Bool { chartSession.selectedChart != nil }

    var body: some View {
        Group {
            if !hasChart {
                ContentUnavailableView(
                    t(PreNatalKeys.title),
                    systemImage: "figure.2.and.child.holdinghands",
                    description: Text(t(PreNatalKeys.noChart))
                )
            } else {
                form
            }
        }
        .navigationTitle(t(PreNatalKeys.title))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(PreNatalKeys.help))
        }
        .sheet(isPresented: $showFactorSheet) {
            PreNatalFactorSelectionSheet(currentSelection: model.selectedFactors)
                .environmentObject(model)
        }
        .sheet(isPresented: $showAspectSheet) {
            PreNatalAspectSelectionSheet(currentSelection: model.selectedAspects)
                .environmentObject(model)
        }
        .sheet(isPresented: $showNewEventSheet) {
            if let horoscope = currentHoroscope {
                EventInputScreen(horoscope: horoscope) { reloadEvents() }
            }
        }
        .onAppear {
            updateConceptionDate()
            loadHoroscope()
        }
        .onChange(of: chartSession.selected?.name) { _, _ in
            updateConceptionDate()
            loadHoroscope()
            resetCombineState()
        }
    }

    // MARK: - Form

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(t(PreNatalKeys.title))
                    .font(.title2.weight(.semibold))

                if let name = chartSession.selected?.name {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                typesSection
                conceptionSection
                selectionButtons
                calculateButton

                if let err = model.errorMessage {
                    Text(err)
                        .font(.callout)
                        .foregroundStyle(.red)
                }

                Divider()

                eventsSection
                combineSection
            }
            .frame(maxWidth: 600, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Types

    private var typesSection: some View {
        GroupBox(t(PreNatalKeys.typesHeader)) {
            VStack(alignment: .leading, spacing: 6) {
                Toggle(t(PreNatalKeys.useAspects),    isOn: $model.useAspects)
                Toggle(t(PreNatalKeys.useEclipses),   isOn: $model.useEclipses)
                Toggle(t(PreNatalKeys.useIngresses),  isOn: $model.useIngresses)
                Toggle(t(PreNatalKeys.useRetroDirect),isOn: $model.useRetroDirect)
            }
            .padding(.vertical, 4)
            .font(.callout)
        }
        .frame(maxWidth: 380)
    }

    // MARK: - Conception

    private var conceptionSection: some View {
        GroupBox(t(PreNatalKeys.conceptionHeader)) {
            VStack(alignment: .leading, spacing: 4) {
                LabeledContent(t(PreNatalKeys.conceptionStandard)) {
                    Text(model.standardConceptionTxt.isEmpty ? "—" : model.standardConceptionTxt)
                        .font(.body.monospacedDigit())
                }
                LabeledContent(t(PreNatalKeys.conceptionActual)) {
                    Text(model.actualConceptionTxt.isEmpty ? "—" : model.actualConceptionTxt)
                        .font(.body.monospacedDigit())
                        .foregroundStyle(model.isResetEnabled ? Color.accentColor : Color.primary)
                }
            }
            .padding(.vertical, 4)
            .font(.callout)
        }
        .frame(maxWidth: 380)
    }

    // MARK: - Factor / Aspect buttons

    private var selectionButtons: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Button(t(PreNatalKeys.factorsButton)) { showFactorSheet = true }
                    .buttonStyle(.bordered)
                Text(factorGlyphs)
                    .font(.custom("EnigmaAstrology3", size: 18))
                    .lineLimit(2)
            }
            VStack(alignment: .leading, spacing: 4) {
                Button(t(PreNatalKeys.aspectsButton)) { showAspectSheet = true }
                    .buttonStyle(.bordered)
                Text(aspectGlyphs)
                    .font(.custom("EnigmaAstrology3", size: 18))
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Calculate

    private var calculateButton: some View {
        Button(t(PreNatalKeys.calculate)) {
            guard let namedChart = chartSession.selected else { return }
            model.calculate(natalJD: namedChart.baseRequest.JulianDay)
        }
        .buttonStyle(.borderedProminent)
        .disabled(model.isCalculating || !hasChart)
    }

    // MARK: - Events section

    private var eventsSection: some View {
        GroupBox(t(PreNatalKeys.eventsHeader)) {
            if displayEvents.isEmpty {
                Text(currentHoroscope == nil
                     ? t(PreNatalKeys.eventsNoSave)
                     : t(PreNatalKeys.eventsEmpty))
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .padding(.vertical, 6)
            } else {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text(t(PreNatalKeys.eventsDescription))
                            .frame(minWidth: 120, alignment: .leading)
                        Text(t(PreNatalKeys.eventsDate))
                            .frame(width: 100, alignment: .leading)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    Divider()
                    ForEach(Array(displayEvents.enumerated()), id: \.element.id) { idx, event in
                        eventRow(event, index: idx)
                    }
                }
            }
        }
        .frame(maxWidth: 380)
    }

    private func eventRow(_ event: EventDisplay, index: Int) -> some View {
        let isSelected = selectedEventID == event.id
        return HStack(spacing: 4) {
            Text(event.title)
                .frame(minWidth: 120, alignment: .leading)
                .lineLimit(1)
            Text(event.dateTxt)
                .frame(width: 100, alignment: .leading)
                .font(.body.monospacedDigit())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isSelected
            ? Color.accentColor.opacity(0.2)
            : (index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06)))
        .contentShape(Rectangle())
        .onTapGesture {
            if selectedEventID == event.id {
                selectedEventID = nil
            } else {
                selectedEventID = event.id
                populateFromEvent(event)
            }
        }
    }

    // MARK: - Combine section

    private var combineSection: some View {
        GroupBox(t(PreNatalKeys.combineHeader)) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(t(PreNatalKeys.combineDateLabel)).font(.caption).foregroundStyle(.secondary)
                    TextField("yyyy/mm/dd", text: $combineDate)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 160)
                        .font(.body.monospacedDigit())
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(t(PreNatalKeys.combineTimeLabel)).font(.caption).foregroundStyle(.secondary)
                    TextField("hh:mm:ss", text: $combineTime)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 160)
                        .font(.body.monospacedDigit())
                }
                if let err = combineError {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
                HStack(spacing: 8) {
                    Button(t(PreNatalKeys.combineButton)) { performCombine() }
                        .buttonStyle(.borderedProminent)
                        .disabled(!model.isCombineEnabled || model.isCalculating || model.selectedMomentJD == nil)
                    Button(t(PreNatalKeys.resetButton)) { performReset() }
                        .buttonStyle(.bordered)
                        .disabled(!model.isResetEnabled || model.isCalculating)
                }
                Button(t(PreNatalKeys.newEventButton)) { showNewEventSheet = true }
                    .buttonStyle(.bordered)
                    .disabled(currentHoroscope == nil)
            }
            .padding(.vertical, 4)
            .font(.callout)
        }
        .frame(maxWidth: 380)
    }

    // MARK: - Actions

    private func performCombine() {
        combineError = nil
        guard let momentJD = model.selectedMomentJD else {
            combineError = t(PreNatalKeys.combineNoMoment)
            return
        }
        guard let eventJD = parseToJD(date: combineDate, time: combineTime) else {
            combineError = t(PreNatalKeys.combineInvalidDate)
            return
        }
        guard let namedChart = chartSession.selected else { return }
        model.combine(natalJD: namedChart.baseRequest.JulianDay, momentJD: momentJD, eventJD: eventJD)
    }

    private func performReset() {
        combineError = nil
        combineDate = ""
        combineTime = "12:00:00"
        selectedEventID = nil
        guard let namedChart = chartSession.selected else { return }
        model.resetConception(natalJD: namedChart.baseRequest.JulianDay)
    }

    private func parseToJD(date: String, time: String) -> Double? {
        func trim(_ s: String) -> String { s.trimmingCharacters(in: .whitespacesAndNewlines) }

        let dp = trim(date).split(separator: "/", omittingEmptySubsequences: true).map { trim(String($0)) }
        guard dp.count == 3,
              let year  = Int(dp[0]),
              let month = Int(dp[1]),
              let day   = Int(dp[2]),
              month >= 1, month <= 12,
              day   >= 1, day   <= 31 else { return nil }

        let tp = trim(time).split(separator: ":", omittingEmptySubsequences: true).map { trim(String($0)) }
        guard tp.count >= 2,
              let hour   = Int(tp[0]), hour   >= 0, hour   <= 23,
              let minute = Int(tp[1]), minute >= 0, minute <= 59 else { return nil }
        // Clamp seconds: lround() in AstronomicalTime can produce 60 due to floating-point rounding.
        let second = min(tp.count > 2 ? (Int(tp[2]) ?? 0) : 0, 59)

        let astroDate = AstronomicalDate(Year: year, Month: month, Day: day)
        let astroTime = AstronomicalTime(Hour: hour, Minute: minute, Second: second)
        return SEWrapper().julianDay(date: astroDate, time: astroTime)
    }

    private func populateFromEvent(_ event: EventDisplay) {
        let se = SEWrapper()
        let dt = se.dateFromJulianDay(event.julianDate)
        combineDate = String(format: "%04d/%02d/%02d", dt.Date.Year, dt.Date.Month, dt.Date.Day)
        combineTime = String(format: "%02d:%02d:%02d", dt.Time.Hour, dt.Time.Minute, dt.Time.Second)
    }

    // MARK: - SwiftData events loading

    private func loadHoroscope() {
        guard let name = chartSession.selected?.name else {
            currentHoroscope = nil
            displayEvents = []
            return
        }
        let desc = FetchDescriptor<HoroscopeModel>(predicate: #Predicate { $0.name == name })
        currentHoroscope = (try? modelContext.fetch(desc))?.first
        reloadEvents()
    }

    private func reloadEvents() {
        guard let horoscope = currentHoroscope else {
            displayEvents = []
            return
        }
        let se = SEWrapper()
        displayEvents = horoscope.events
            .sorted { $0.julianDate < $1.julianDate }
            .map { event in
                let dt = se.dateFromJulianDay(event.julianDate)
                let dateTxt = String(format: "%04d/%02d/%02d", dt.Date.Year, dt.Date.Month, dt.Date.Day)
                return EventDisplay(id: event.id, title: event.title, dateTxt: dateTxt, julianDate: event.julianDate)
            }
    }

    private func resetCombineState() {
        selectedEventID = nil
        combineDate = ""
        combineTime = "12:00:00"
        combineError = nil
    }

    // MARK: - Helpers

    private func updateConceptionDate() {
        guard let jd = chartSession.selected?.baseRequest.JulianDay else { return }
        model.updateConceptionDate(natalJD: jd)
    }

    private var factorGlyphs: String {
        model.selectedFactors.map { GlyphSelector.getGlyphForFactor($0) }.joined()
    }

    private var aspectGlyphs: String {
        model.selectedAspects.map { GlyphSelector.getGlyphForAspect($0) }.joined()
    }
}

// MARK: - Supporting type

private struct EventDisplay: Identifiable {
    let id: UUID
    let title: String
    let dateTxt: String
    let julianDate: Double
}
