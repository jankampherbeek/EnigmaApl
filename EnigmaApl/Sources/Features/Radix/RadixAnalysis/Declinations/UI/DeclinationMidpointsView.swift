// DeclinationMidpointsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct DeclinationMidpointsView: View {
    @Binding var activeTab: DeclinationsTab

    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var blackWhite    = false
    @State private var showFactsheet = false
    @State private var showHelp      = false

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Declinations", bundle: .main, comment: "")
    }

    // MARK: - Derived data

    private var arcItems: [DeclMidpointsArcItem] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        let raw: [DeclMidpointsArcItem] = config.factorConfig.factorSettings
            .filter { $0.isUsed }
            .compactMap { settings -> DeclMidpointsArcItem? in
                guard let decl = DeclMidpointsCalculator.declination(for: settings.factor, in: chart) else { return nil }
                return DeclMidpointsArcItem(
                    factor:      settings.factor,
                    glyph:       GlyphSelector.getGlyphForFactor(settings.factor),
                    declination: decl,
                    visualAngle: WheelGeometry.normalise(-decl * 4.0)
                )
            }
        // Resolve glyph overlaps: items that are very close in visual angle are nudged slightly.
        return resolveArcOverlaps(raw)
    }

    private var occupiedMidpoints: [DeclOccupiedMidpoint] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return DeclinationsOrchestrator.occupiedMidpoints(
            chart: chart,
            factorConfig: config.factorConfig,
            orbConfig: config.orbConfig
        )
    }

    private var orbConfig: OrbConfig {
        activeConfigs.first?.orbConfig ?? OrbConfig()
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let wideLayout = geo.size.width > 600
            Group {
                if wideLayout {
                    HStack(alignment: .top, spacing: 16) {
                        arcCanvas
                            .frame(maxWidth: 380)
                        midpointsTable
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            arcCanvas
                                .frame(maxWidth: .infinity)
                            midpointsTable
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
        .sheet(isPresented: $showHelp) {
            NavigationStack {
                ScrollView {
                    Text(t(DeclinationsKeys.decMidpointsHelp))
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

    // MARK: - Arc canvas + overlay

    private var arcCanvas: some View {
        ZStack {
            DeclMidpointsArcCanvas(
                items:      arcItems,
                northLabel: t(DeclinationsKeys.decMidpointsNorth),
                southLabel: t(DeclinationsKeys.decMidpointsSouth),
                theme:      blackWhite ? .blackWhite : .color
            )
            DeclMidpointsArcOverlay(
                items:     arcItems,
                orbConfig: orbConfig
            )
        }
    }

    // MARK: - Midpoints table

    @ViewBuilder
    private var midpointsTable: some View {
        let midpoints = occupiedMidpoints
        if midpoints.isEmpty {
            Text(t(DeclinationsKeys.decMidpointsNoData))
                .foregroundStyle(.secondary)
                .font(.callout)
        } else {
            GroupBox {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        tableHeader
                        Divider()
                        ScrollView(.vertical) {
                            VStack(spacing: 0) {
                                ForEach(Array(midpoints.enumerated()), id: \.offset) { index, item in
                                    tableRow(item, index: index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 8) {
            Text(t(DeclinationsKeys.decMidpointsColF1))
                .frame(width: 28, alignment: .center)
            Text(t(DeclinationsKeys.decMidpointsColF2))
                .frame(width: 28, alignment: .center)
            Text(t(DeclinationsKeys.decMidpointsColMidpoint))
                .frame(width: 90, alignment: .trailing)
            Text(t(DeclinationsKeys.decMidpointsColOccupant))
                .frame(width: 28, alignment: .center)
            Text(t(DeclinationsKeys.decMidpointsColOccDecl))
                .frame(width: 90, alignment: .trailing)
            Text(t(DeclinationsKeys.decMidpointsColOrb))
                .frame(width: 90, alignment: .trailing)
            Text(t(DeclinationsKeys.decMidpointsColExactness))
                .frame(width: 90, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func tableRow(_ item: DeclOccupiedMidpoint, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(GlyphSelector.getGlyphForFactor(item.midpoint.factor1))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: 28, alignment: .center)
                .accessibilityLabel(item.midpoint.factor1.localizedName)

            Text(GlyphSelector.getGlyphForFactor(item.midpoint.factor2))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: 28, alignment: .center)
                .accessibilityLabel(item.midpoint.factor2.localizedName)

            Text(PositionInDegreesConversion.DoubleToDms(item.midpoint.position))
                .frame(width: 90, alignment: .trailing)
                .monospacedDigit()
                .foregroundStyle(.secondary)

            Text(GlyphSelector.getGlyphForFactor(item.occupyingFactor))
                .font(.custom("EnigmaAstrology3", size: 18))
                .frame(width: 28, alignment: .center)
                .accessibilityLabel(item.occupyingFactor.localizedName)

            Text(PositionInDegreesConversion.DoubleToDms(item.occupyingPosition))
                .frame(width: 90, alignment: .trailing)
                .monospacedDigit()

            Text(orbText(item.actualOrb))
                .frame(width: 90, alignment: .trailing)
                .foregroundStyle(.secondary)

            Text("\(Int(item.exactness.rounded()))%")
                .frame(width: 90, alignment: .trailing)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    // MARK: - Helpers

    /// Formats an orb (in degrees) as d°mm'ss".
    private func orbText(_ orb: Double) -> String {
        let totalSec = Int(abs(orb) * 3600)
        let deg = totalSec / 3600
        let min = (totalSec % 3600) / 60
        let sec = totalSec % 60
        return "\(deg)°\(String(format: "%02d", min))'\(String(format: "%02d", sec))\""
    }

    /// Nudges arc items that are very close in visual angle so glyphs don't overlap.
    private func resolveArcOverlaps(_ items: [DeclMidpointsArcItem]) -> [DeclMidpointsArcItem] {
        var result = items.sorted { $0.visualAngle < $1.visualAngle }
        let minSep = 6.0   // minimum degrees of separation between plotAngles
        for i in 1 ..< result.count {
            let prev = result[i - 1].visualAngle
            var curr = result[i].visualAngle
            if curr - prev < minSep { curr = prev + minSep }
            result[i].visualAngle = curr
        }
        return result
    }

    // MARK: - Tab picker

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
