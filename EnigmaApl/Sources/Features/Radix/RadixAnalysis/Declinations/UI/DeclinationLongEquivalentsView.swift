// DeclinationLongEquivalentsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import SwiftData

struct DeclinationLongEquivalentsView: View {
    @Binding var activeTab: DeclinationsTab

    @EnvironmentObject private var chartSession: ChartSession
    @Query(filter: #Predicate<UserConfiguration> { $0.isActive == true })
    private var activeConfigs: [UserConfiguration]

    @State private var blackWhite    = false
    @State private var hideAspects   = false
    @State private var hideTime      = false
    @State private var showExport    = false
    @State private var showFactsheet = false
    @State private var showHelp      = false

    // Column widths
    private let glyphW: CGFloat = 28
    private let longW:  CGFloat = 130

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Declinations", bundle: .main, comment: "")
    }

    private func tw(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ChartWheel", bundle: .main, comment: "")
    }

    // MARK: - Derived data

    private var equivalents: [LongEquivalentResult] {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return [] }
        return DeclinationsOrchestrator.longitudeEquivalents(
            chart: chart,
            factorConfig: config.factorConfig
        )
    }

    private var drawingType: DrawingType {
        activeConfigs.first?.displayConfig.drawingType ?? .signBased
    }

    private var isDial: Bool {
        drawingType == .dial360 || drawingType == .dial90 || drawingType == .dial45
    }

    private var dialTypeBinding: Binding<DrawingType> {
        Binding(
            get: { activeConfigs.first?.displayConfig.drawingType ?? .dial360 },
            set: { newType in
                guard let config = activeConfigs.first else { return }
                config.displayConfig = DisplayConfig(
                    drawingType: newType,
                    signColors:  config.displayConfig.signColors
                )
            }
        )
    }

    /// WheelPlotData with factor positions replaced by their longitude equivalents.
    private var equivalentPlotData: WheelPlotData {
        guard let chart = chartSession.selectedChart,
              let config = activeConfigs.first else { return .empty }
        let ascLong = chart.HousePositions.ascendant.longitude
        let mcLong  = chart.HousePositions.midheaven.longitude
        let cusps   = chart.HousePositions.cusps.map { $0.longitude }

        let items: [WheelPlotItem] = equivalents.compactMap { result in
            let equiv   = result.longitudeEquivalent
            let mundane = WheelGeometry.mundaneAngle(longitude: equiv, ascendantLongitude: ascLong)
            let glyph   = GlyphSelector.getGlyphForFactor(result.factor)
            let text    = positionText(longitude: equiv)
            return WheelPlotItem(
                factor:            result.factor,
                glyph:             glyph,
                eclipticLongitude: equiv,
                mundaneAngle:      mundane,
                plotAngle:         mundane,
                positionText:      text,
                speedType:         .direct
            )
        }
        let resolved = GlyphOverlapResolver.resolve(items.filter { $0.factor != .ascendant && $0.factor != .mc })
        let aspectItems = buildAspectItems(planetItems: resolved, config: config)

        return WheelPlotData(
            ascendantLongitude: ascLong,
            mcLongitude:        mcLong,
            cuspLongitudes:     cusps,
            planetItems:        resolved,
            hasTime:            true,
            aspectItems:        aspectItems
        )
    }

    /// Builds aspect items from the equivalent longitudes using the configured aspect/orb settings.
    /// Mirrors the algorithm in AspectsOrchestrator.calculate().
    private func buildAspectItems(planetItems: [WheelPlotItem], config: UserConfiguration) -> [WheelAspectItem] {
        let positions = planetItems.map { ($0.factor, $0.eclipticLongitude) }
        guard positions.count >= 2 else { return [] }

        let usedAspects = config.aspectConfig.aspectSettings.filter { $0.isUsed }
        guard !usedAspects.isEmpty else { return [] }

        let factorOrbPct: [Factors: Int] = Dictionary(uniqueKeysWithValues:
            config.factorConfig.factorSettings.map { ($0.factor, $0.orbPercentage) }
        )
        let colorMap: [Aspects: Color] = Dictionary(uniqueKeysWithValues:
            config.aspectConfig.aspectSettings.map { ($0.aspect, Color($0.color)) }
        )
        let angleMap: [Factors: Double] = Dictionary(uniqueKeysWithValues:
            planetItems.map { ($0.factor, $0.mundaneAngle) }
        )

        var result: [WheelAspectItem] = []
        for i in 0 ..< positions.count {
            let (f1, long1) = positions[i]
            for j in (i + 1) ..< positions.count {
                let (f2, long2) = positions[j]
                let distance = shortestDistance(long1, long2)
                let orbFraction1 = Double(factorOrbPct[f1] ?? 100) / 100.0
                let orbFraction2 = Double(factorOrbPct[f2] ?? 100) / 100.0
                let maxFactorFraction = max(orbFraction1, orbFraction2)
                for setting in usedAspects {
                    let maxOrb    = maxFactorFraction * (Double(setting.orbPercentage) / 100.0) * config.orbConfig.aspectBaseOrb
                    let deviation = abs(distance - setting.aspect.angle)
                    guard deviation <= maxOrb else { continue }
                    guard let angle1 = angleMap[f1], let angle2 = angleMap[f2] else { continue }
                    let exactness = maxOrb > 0 ? max(0, 1.0 - deviation / maxOrb) : 1.0
                    let color = colorMap[setting.aspect] ?? .gray
                    result.append(WheelAspectItem(angle1: angle1, angle2: angle2,
                                                  color: color, exactness: exactness,
                                                  aspect: setting.aspect))
                }
            }
        }
        return result
    }

    private func shortestDistance(_ long1: Double, _ long2: Double) -> Double {
        let diff = abs(long1 - long2).truncatingRemainder(dividingBy: 360.0)
        return diff > 180.0 ? 360.0 - diff : diff
    }

    /// Apply hideTime remapping (mirrors ZodiacTypeWheel.effectiveData).
    private var effectivePlotData: WheelPlotData {
        let data = equivalentPlotData
        guard hideTime else { return data }
        let remapped = data.planetItems.map { item -> WheelPlotItem in
            let angle = WheelGeometry.mundaneAngle(longitude: item.eclipticLongitude,
                                                   ascendantLongitude: 0)
            return WheelPlotItem(factor: item.factor, glyph: item.glyph,
                                 eclipticLongitude: item.eclipticLongitude,
                                 mundaneAngle: angle, plotAngle: angle,
                                 positionText: item.positionText,
                                 speedType: item.speedType)
        }
        return WheelPlotData(
            ascendantLongitude: 0,
            mcLongitude:        data.mcLongitude,
            cuspLongitudes:     data.cuspLongitudes,
            planetItems:        GlyphOverlapResolver.resolve(remapped),
            hasTime:            false,
            aspectItems:        []
        )
    }

    private var theme: WheelTheme { blackWhite ? .blackWhite : .color }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(DeclinationsKeys.equivalentsTitle))
                    .font(.title2.weight(.semibold))

                if equivalents.isEmpty {
                    Text(t(DeclinationsKeys.equivalentsNoData))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    wheelCanvas
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(.vertical, 8)

                    Divider()

                    equivalentsTable
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
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
                Button { hideAspects.toggle() } label: {
                    Image(systemName: "angle")
                }
                .foregroundStyle(hideAspects ? .secondary : .primary)
                .accessibilityLabel(hideAspects ? "Show aspects" : "Hide aspects")
            }
            ToolbarItem(placement: .automatic) {
                Button { hideTime.toggle() } label: {
                    Image(systemName: "clock")
                }
                .foregroundStyle(hideTime ? .secondary : .primary)
                .accessibilityLabel(hideTime ? "Show time" : "Hide time")
            }
            if isDial {
                ToolbarItem(placement: .automatic) {
                    Picker("", selection: dialTypeBinding) {
                        Text(tw(ChartWheelKeys.dialType360)).tag(DrawingType.dial360)
                        Text(tw(ChartWheelKeys.dialType90)).tag(DrawingType.dial90)
                        Text(tw(ChartWheelKeys.dialType45)).tag(DrawingType.dial45)
                    }
                    .pickerStyle(.segmented)
                }
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
            WheelExportSheet(wheelView: exportCanvas)
        }
        .sheet(isPresented: $showHelp) {
            NavigationStack {
                ScrollView {
                    Text(t(DeclinationsKeys.equivalentsHelp))
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

    // MARK: - Wheel canvas

    @ViewBuilder
    private var wheelCanvas: some View {
        switch drawingType {
        case .signBased:
            ZodiacTypeWheelCanvas(plotData: effectivePlotData, theme: theme, showAspects: !hideAspects)
        case .houseBased:
            HouseTypeWheelCanvas(plotData: effectivePlotData, theme: theme)
        case .french:
            FrenchTypeWheelCanvas(plotData: effectivePlotData, theme: theme, showAspects: !hideAspects)
        case .ring:
            RingTypeWheelCanvas(plotData: effectivePlotData, theme: theme, showAspects: !hideAspects)
        case .dial360:
            Dial360TypeWheelCanvas(plotData: effectivePlotData, theme: theme)
        case .dial90:
            Dial90TypeWheelCanvas(plotData: effectivePlotData, theme: theme)
        case .dial45:
            Dial45TypeWheelCanvas(plotData: effectivePlotData, theme: theme)
        }
    }

    @ViewBuilder
    private var exportCanvas: some View {
        switch drawingType {
        case .signBased:
            ZodiacTypeWheelCanvas(plotData: effectivePlotData, theme: theme, showAspects: !hideAspects)
        case .houseBased:
            HouseTypeWheelCanvas(plotData: effectivePlotData, theme: theme)
        case .french:
            FrenchTypeWheelCanvas(plotData: effectivePlotData, theme: theme, showAspects: !hideAspects)
        case .ring:
            RingTypeWheelCanvas(plotData: effectivePlotData, theme: theme, showAspects: !hideAspects)
        case .dial360:
            Dial360TypeWheelCanvas(plotData: effectivePlotData, theme: theme)
        case .dial90:
            Dial90TypeWheelCanvas(plotData: effectivePlotData, theme: theme)
        case .dial45:
            Dial45TypeWheelCanvas(plotData: effectivePlotData, theme: theme)
        }
    }

    // MARK: - Table

    @ViewBuilder
    private var equivalentsTable: some View {
        GroupBox {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Text(t(DeclinationsKeys.equivalentsColFactor))
                        .frame(width: glyphW, alignment: .center)
                    Text(t(DeclinationsKeys.equivalentsColLong))
                        .frame(width: longW, alignment: .trailing)
                    Text(t(DeclinationsKeys.equivalentsColEquiv))
                        .frame(width: longW, alignment: .trailing)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)

                Divider()

                ForEach(Array(equivalents.enumerated()), id: \.offset) { index, result in
                    equivalentRow(result, index: index)
                }
            }
        }
    }

    @ViewBuilder
    private func equivalentRow(_ result: LongEquivalentResult, index: Int) -> some View {
        let originalLong = chartSession.selectedChart.flatMap { DeclMidpointsCalculator.longAndDeclination(for: result.factor, in: $0)?.0 }
        HStack(spacing: 4) {
            Text(GlyphSelector.getGlyphForFactor(result.factor))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphW, alignment: .center)
                .accessibilityLabel(result.factor.localizedName)

            longitudeText(originalLong ?? 0)
                .frame(width: longW, alignment: .trailing)

            longitudeText(result.longitudeEquivalent)
                .frame(width: longW, alignment: .trailing)
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

    private func positionText(longitude: Double) -> String {
        let inSign   = longitude.truncatingRemainder(dividingBy: 30.0)
        let totalMin = Int(abs(inSign) * 60)
        return "\(totalMin / 60)°\(String(format: "%02d", totalMin % 60))'"
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
