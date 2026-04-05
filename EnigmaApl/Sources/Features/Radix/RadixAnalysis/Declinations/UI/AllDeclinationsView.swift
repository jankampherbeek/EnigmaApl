// AllDeclinationsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct AllDeclinationsView: View {
    @Binding var activeTab: DeclinationsTab

    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var blackWhite    = false
    @State private var showExport    = false
    @State private var showFactsheet = false
    @State private var showHelp      = false

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Declinations", bundle: .main, comment: "")
    }

    // MARK: - Derived data

    private var stripItems: [DeclStripItem] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return config.factorConfig.factorSettings
            .filter { $0.isUsed }
            .compactMap { settings -> DeclStripItem? in
                guard let (longitude, declination) = DeclMidpointsCalculator.longAndDeclination(
                    for: settings.factor, in: chart
                ) else { return nil }
                return DeclStripItem(
                    factor:      settings.factor,
                    glyph:       GlyphSelector.getGlyphForFactor(settings.factor),
                    declination: declination,
                    longitude:   longitude
                )
            }
            .sorted { $0.factor.rawValue < $1.factor.rawValue }
    }

    private var obliquity: Double {
        chartSession.selectedChart?.Obliquity ?? 23.45
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let wideLayout = geo.size.width > 600
            Group {
                if wideLayout {
                    HStack(alignment: .top, spacing: 16) {
                        stripCanvas
                            .frame(maxWidth: 240)
                        declinationsTable
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            stripCanvas
                                .frame(maxWidth: .infinity)
                            declinationsTable
                        }
                        .padding()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                tabPicker
            }
            ToolbarItem(placement: .automatic) {
                Button { blackWhite.toggle() } label: {
                    Image(systemName: blackWhite ? "circle.lefthalf.filled" : "paintpalette")
                }
                .accessibilityLabel(blackWhite ? "Switch to color" : "Switch to black and white")
            }
            ToolbarItem(placement: .automatic) {
                Button { showExport = true } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Export")
            }
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
            FactsheetView(baseName: "declinations")
        }
        .sheet(isPresented: $showExport) {
            WheelExportSheet(
                wheelView: DeclStripCanvas(items: stripItems, obliquity: obliquity, blackWhite: blackWhite)
            )
        }
        .sheet(isPresented: $showHelp) {
            NavigationStack {
                ScrollView {
                    Text(t(DeclinationsKeys.allDeclinationsHelp))
                        .padding()
                }
                .navigationTitle("Help")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("OK") { showHelp = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Sub-views

    private var stripCanvas: some View {
        DeclStripCanvas(items: stripItems, obliquity: obliquity, blackWhite: blackWhite)
    }

    @ViewBuilder
    private var declinationsTable: some View {
        if stripItems.isEmpty {
            Text(t(DeclinationsKeys.allDeclinationsNoData))
                .foregroundStyle(.secondary)
                .font(.callout)
        } else {
            GroupBox {
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 4) {
                        Text(t(DeclinationsKeys.colFactor))
                            .frame(width: 28, alignment: .center)
                        Text(t(DeclinationsKeys.colLongitude))
                            .frame(width: 130, alignment: .trailing)
                        Text(t(DeclinationsKeys.colDeclination))
                            .frame(width: 100, alignment: .trailing)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)

                    Divider()

                    ForEach(Array(stripItems.enumerated()), id: \.offset) { index, item in
                        tableRow(item, index: index)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func tableRow(_ item: DeclStripItem, index: Int) -> some View {
        HStack(spacing: 4) {
            Text(item.glyph)
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: 28, alignment: .center)
                .accessibilityLabel(item.factor.localizedName)

            longitudeText(item.longitude)
                .frame(width: 130, alignment: .trailing)

            Text(PositionInDegreesConversion.DoubleToDms(item.declination))
                .frame(width: 100, alignment: .trailing)
                .monospacedDigit()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Helpers

    @ViewBuilder
    private func longitudeText(_ longitude: Double) -> some View {
        let (dmsString, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(longitude)
        if success, let sign {
            Text(longitudeAttributedString(dms: dmsString, sign: sign))
                .monospacedDigit()
        } else {
            Text(PositionInDegreesConversion.DoubleToDms(longitude))
                .monospacedDigit()
        }
    }

    private func longitudeAttributedString(dms: String, sign: Signs) -> AttributedString {
        var dmsAttr = AttributedString(dms + " ")
        dmsAttr.font = .body
        var glyphAttr = AttributedString(GlyphSelector.getGlyphForSign(sign))
        glyphAttr.font = .custom("EnigmaAstrology2", size: 18)
        return dmsAttr + glyphAttr
    }

    private var tabPicker: some View {
        Picker("", selection: $activeTab) {
            Text(t(DeclinationsKeys.btnAllDeclinations)).tag(DeclinationsTab.all)
            Text(t(DeclinationsKeys.btnParallels)).tag(DeclinationsTab.parallels)
            Text(t(DeclinationsKeys.btnEquivalents)).tag(DeclinationsTab.equivalents)
            Text(t(DeclinationsKeys.btnDiagram)).tag(DeclinationsTab.diagram)
            Text(t(DeclinationsKeys.btnMidpoints)).tag(DeclinationsTab.midpoints)
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
}
