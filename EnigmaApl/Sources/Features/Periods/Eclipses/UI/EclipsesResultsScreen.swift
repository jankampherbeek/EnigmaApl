// EclipsesResultsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func ec(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Eclipses", bundle: .main, comment: "")
}

struct EclipsesResultsScreen: View {
    @EnvironmentObject private var eclipsesModel: EclipsesModel

    private let seWrapper = SEWrapper()

    @State private var showHelp = false
    @State private var showFactsheet = false

    var body: some View {
        Group {
            if eclipsesModel.hasResults {
                if eclipsesModel.hasLocation {
                    localTable
                } else {
                    globalTable
                }
            } else {
                emptyState
            }
        }
        .navigationTitle(ec(EclipsesKeys.resultsTitle))
        .toolbar {
            if eclipsesModel.hasResults {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: exportToPDF) {
                        Label(ec(EclipsesKeys.exportPDF), systemImage: "square.and.arrow.up")
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button { showFactsheet = true } label: {
                    Image(systemName: "book.pages")
                }
                .accessibilityLabel("Factsheet")
            }
            ToolbarItem(placement: .primaryAction) {
                Button { showHelp = true } label: {
                    Label("Help", systemImage: "questionmark.circle")
                }
            }
        }
        .sheet(isPresented: $showFactsheet) {
            FactsheetView(baseName: "eclipses")
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: ec(EclipsesKeys.helpResults))
        }
    }

    private func exportToPDF() {
        guard let data = EclipsesPDFExporter.export(
            events: eclipsesModel.results,
            hasLocation: eclipsesModel.hasLocation,
            seWrapper: seWrapper
        ) else { return }
        EclipsesPDFExporter.saveWithPanel(data: data)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack {
            Spacer()
            Text(ec(EclipsesKeys.noResults))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Global table (no location)

    private var globalTable: some View {
        Table(eclipsesModel.results) {
            TableColumn("") { event in
                Text(eclipseGlyph(event))
                    .font(.custom("EnigmaAstrology3", size: 16))
            }
            .width(28)

            TableColumn(ec(EclipsesKeys.colDate)) { event in
                Text(formatDateTime(event.displayJD))
                    .font(.system(.body, design: .monospaced))
            }
            .width(min: 130, ideal: 155)

            TableColumn(ec(EclipsesKeys.colPosition)) { event in
                positionCell(event.longitude)
            }
            .width(min: 95, ideal: 110)
        }
    }

    // MARK: - Local table (with location)

    private var localTable: some View {
        Table(eclipsesModel.results) {
            TableColumn("") { event in
                Text(eclipseGlyph(event))
                    .font(.custom("EnigmaAstrology3", size: 16))
            }
            .width(28)

            TableColumn(ec(EclipsesKeys.colDate)) { event in
                Text(formatDateTime(event.displayJD))
                    .font(.system(.body, design: .monospaced))
            }
            .width(min: 130, ideal: 155)

            TableColumn(ec(EclipsesKeys.colPosition)) { event in
                positionCell(event.longitude)
            }
            .width(min: 95, ideal: 110)

            TableColumn(ec(EclipsesKeys.colType)) { event in
                Text(typeLabel(event))
            }
            .width(min: 80, ideal: 95)

            TableColumn(ec(EclipsesKeys.colVisible)) { event in
                if event.hasLocalData {
                    Image(systemName: event.isVisible ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundStyle(event.isVisible ? .green : .secondary)
                } else {
                    Text("—").foregroundStyle(.secondary)
                }
            }
            .width(55)

            TableColumn(ec(EclipsesKeys.colSaros)) { event in
                if event.sarosNumber > -99999998 {
                    Text("\(Int(event.sarosNumber))-\(Int(event.sarosMemberNumber))")
                        .font(.system(.body, design: .monospaced))
                } else {
                    Text("—").foregroundStyle(.secondary)
                }
            }
            .width(min: 65, ideal: 80)
        }
    }

    // MARK: - Cell helpers

    @ViewBuilder
    private func positionCell(_ longitude: Double) -> some View {
        HStack(spacing: 3) {
            Text(formatDegrees(longitude))
                .font(.system(.body, design: .monospaced))
            Text(signGlyph(longitude))
                .font(.custom("EnigmaAstrology3", size: 14))
        }
    }

    // MARK: - Formatting helpers

    private func eclipseGlyph(_ event: EclipseEvent) -> String {
        event.kind == .solar ? "\u{F360}" : "\u{F361}"
    }

    private func formatDateTime(_ jd: Double) -> String {
        let dt = seWrapper.dateFromJulianDay(jd)
        let hour = Int(dt.Time.HourDecimal)
        let minute = Int((dt.Time.HourDecimal - Double(hour)) * 60)
        return String(format: "%d-%02d-%02d %02d:%02d",
                      dt.Date.Year, dt.Date.Month, dt.Date.Day, hour, minute)
    }

    private func signGlyph(_ longitude: Double) -> String {
        let index = Int(longitude / 30)
        let sign = Signs(rawValue: index + 1) ?? .Aries
        return GlyphSelector.getGlyphForSign(sign)
    }

    private func formatDegrees(_ longitude: Double) -> String {
        let posInSign = longitude - Double(Int(longitude / 30)) * 30
        let deg = Int(posInSign)
        let minFrac = (posInSign - Double(deg)) * 60
        let min = Int(minFrac)
        let sec = Int((minFrac - Double(min)) * 60)
        return String(format: "%2d\u{00B0}%02d'%02d\"", deg, min, sec)
    }

    private func typeLabel(_ event: EclipseEvent) -> String {
        if event.isTotal      { return ec(EclipsesKeys.typeTotal) }
        if event.isHybrid     { return ec(EclipsesKeys.typeHybrid) }
        if event.isAnnular    { return ec(EclipsesKeys.typeAnnular) }
        if event.isPenumbral  { return ec(EclipsesKeys.typePenumbral) }
        if event.isPartial    { return ec(EclipsesKeys.typePartial) }
        return "—"
    }
}
