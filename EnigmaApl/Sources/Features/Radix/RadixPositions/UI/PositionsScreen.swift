// PositionsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026
import SwiftUI

struct PositionsScreen: View {
    @EnvironmentObject private var chartSession: ChartSession

    @State private var selectedSystem: CoordinateSystems = .ecliptical
    @State private var showHelp = false

    private static let compactWidthThreshold: CGFloat = 700

    private let planetOrder: [Factors] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto
    ]

    // Full column widths (iPad / regular size class)
    private let planetColumnWidths: [CGFloat] = [50, 120, 40, 120, 140, 120, 120, 120, 120]
    private let cuspColumnWidths: [CGFloat] = [70, 120, 140, 120, 120, 120]

    // Compact column widths (iPhone / compact size class)
    private let compactGlyphWidth: CGFloat = 44
    private let compactSpeedWidth: CGFloat = 36
    private let compactLengthWidth: CGFloat = 140
    private let compactLatitudeWidth: CGFloat = 100
    private let compactRAWidth: CGFloat = 110
    private let compactDeclWidth: CGFloat = 95
    private let compactDistWidth: CGFloat = 95
    private let compactAzimuthWidth: CGFloat = 100
    private let compactAltitudeWidth: CGFloat = 100
    private let compactCuspNumWidth: CGFloat = 44

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "RadixPositions", bundle: .main, comment: "")
    }

    private func dms(_ number: Double) -> String {
        PositionInDegreesConversion.DoubleToDms(number)
    }

    private func decimal(_ number: Double) -> String {
        String(format: "%.4f", number)
    }

    @ViewBuilder
    private func glyphCell(_ factor: Factors, width: CGFloat) -> some View {
        Text(GlyphSelector.getGlyphForFactor(factor))
            .font(.custom("EnigmaAstrology2", size: 18))
            .frame(width: width, alignment: .leading)
            .accessibilityLabel(factor.localizedName)
    }

    private func lengthAttributedString(dmsString: String, sign: Signs) -> AttributedString {
        var dmsAttr = AttributedString(dmsString + " ")
        dmsAttr.font = .body
        var glyphAttr = AttributedString(GlyphSelector.getGlyphForSign(sign))
        glyphAttr.font = .custom("EnigmaAstrology2", size: 18)
        return dmsAttr + glyphAttr
    }

    @ViewBuilder
    private func lengthCell(_ value: Double, width: CGFloat) -> some View {
        let (dmsString, sign, success) = PositionInDegreesConversion.DoubleToDmsSign(value)
        if success, let sign {
            Text(lengthAttributedString(dmsString: dmsString, sign: sign))
                .frame(width: width, alignment: .trailing)
        } else {
            tableCell(dms(value), width: width, alignment: .trailing)
        }
    }

    @ViewBuilder
    private func tableCell(_ text: String, width: CGFloat, alignment: Alignment, bold: Bool = false) -> some View {
        Text(text)
            .font(bold ? .body.weight(.semibold) : .body)
            .frame(width: width, alignment: alignment)
    }

    // MARK: - Full tables (iPad / regular size class)

    @ViewBuilder
    private func planetsTable(for chart: FullChart) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    tableCell("", width: planetColumnWidths[0], alignment: .leading, bold: true)
                    tableCell(t(PositionsKeys.length), width: planetColumnWidths[1], alignment: .trailing, bold: true)
                    tableCell(t(PositionsKeys.speed), width: planetColumnWidths[2], alignment: .trailing, bold: true)
                    tableCell(t(PositionsKeys.latitude), width: planetColumnWidths[3], alignment: .trailing, bold: true)
                    tableCell(t(PositionsKeys.rightAscension), width: planetColumnWidths[4], alignment: .trailing, bold: true)
                    tableCell(t(PositionsKeys.declination), width: planetColumnWidths[5], alignment: .trailing, bold: true)
                    tableCell(t(PositionsKeys.distance), width: planetColumnWidths[6], alignment: .trailing, bold: true)
                    tableCell(t(PositionsKeys.azimuth), width: planetColumnWidths[7], alignment: .trailing, bold: true)
                    tableCell(t(PositionsKeys.altitude), width: planetColumnWidths[8], alignment: .trailing, bold: true)
                }
                .padding(.vertical, 6)

                Divider()

                let planetRows = planetOrder.compactMap { factor -> (Factors, FullFactorPosition)? in
                    guard let position = chart.Coordinates[factor],
                          !position.ecliptical.isEmpty,
                          !position.equatorial.isEmpty,
                          !position.horizontal.isEmpty else {
                        return nil
                    }
                    return (factor, position)
                }

                ForEach(planetRows.indices, id: \.self) { index in
                    let factor = planetRows[index].0
                    let position = planetRows[index].1
                    let ecliptical = position.ecliptical[0]
                    let equatorial = position.equatorial[0]
                    let horizontal = position.horizontal[0]

                    let speedType = SpeedOrchestrator().determine(speed: ecliptical.mainPosSpeed, for: factor, config: CalculationConfig())
                    HStack(spacing: 12) {
                        glyphCell(factor, width: planetColumnWidths[0])
                        lengthCell(ecliptical.mainPos, width: planetColumnWidths[1])
                        tableCell(speedType == .direct ? "" : speedType.abbreviation, width: planetColumnWidths[2], alignment: .trailing)
                        tableCell(dms(ecliptical.deviation), width: planetColumnWidths[3], alignment: .trailing)
                        tableCell(dms(equatorial.mainPos), width: planetColumnWidths[4], alignment: .trailing)
                        tableCell(dms(equatorial.deviation), width: planetColumnWidths[5], alignment: .trailing)
                        tableCell(decimal(ecliptical.distance), width: planetColumnWidths[6], alignment: .trailing)
                        tableCell(dms(horizontal.azimuth), width: planetColumnWidths[7], alignment: .trailing)
                        tableCell(dms(horizontal.altitude), width: planetColumnWidths[8], alignment: .trailing)
                    }
                    .padding(.vertical, 6)
                    .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                }
            }
            .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private func cuspsTable(for chart: FullChart) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    tableCell(t(PositionsKeys.cusp), width: cuspColumnWidths[0], alignment: .leading, bold: true)
                    tableCell(t(PositionsKeys.length), width: cuspColumnWidths[1], alignment: .trailing, bold: true)
                    tableCell(t(PositionsKeys.rightAscension), width: cuspColumnWidths[2], alignment: .trailing, bold: true)
                    tableCell(t(PositionsKeys.declination), width: cuspColumnWidths[3], alignment: .trailing, bold: true)
                    tableCell(t(PositionsKeys.azimuth), width: cuspColumnWidths[4], alignment: .trailing, bold: true)
                    tableCell(t(PositionsKeys.altitude), width: cuspColumnWidths[5], alignment: .trailing, bold: true)
                }
                .padding(.vertical, 6)

                Divider()

                ForEach(Array(chart.HousePositions.cusps.enumerated()), id: \.offset) { index, cusp in
                    HStack(spacing: 12) {
                        tableCell(String(index + 1), width: cuspColumnWidths[0], alignment: .leading)
                        lengthCell(cusp.longitude, width: cuspColumnWidths[1])
                        tableCell(dms(cusp.rightAscension), width: cuspColumnWidths[2], alignment: .trailing)
                        tableCell(dms(cusp.declination), width: cuspColumnWidths[3], alignment: .trailing)
                        tableCell(dms(cusp.horizontal.azimuth), width: cuspColumnWidths[4], alignment: .trailing)
                        tableCell(dms(cusp.horizontal.altitude), width: cuspColumnWidths[5], alignment: .trailing)
                    }
                    .padding(.vertical, 6)
                    .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                }
            }
            .textSelection(.enabled)
        }
    }

    // MARK: - Compact tables (iPhone / compact size class)

    @ViewBuilder
    private func compactPlanetsHeader() -> some View {
        HStack(spacing: 12) {
            tableCell("", width: compactGlyphWidth, alignment: .leading, bold: true)
            if selectedSystem == .ecliptical {
                tableCell(t(PositionsKeys.length), width: compactLengthWidth, alignment: .trailing, bold: true)
                tableCell(t(PositionsKeys.speed), width: compactSpeedWidth, alignment: .trailing, bold: true)
                tableCell(t(PositionsKeys.declination), width: compactLatitudeWidth, alignment: .trailing, bold: true)
            } else if selectedSystem == .equatorial {
                tableCell(t(PositionsKeys.ra), width: compactRAWidth, alignment: .trailing, bold: true)
                tableCell(t(PositionsKeys.decl), width: compactDeclWidth, alignment: .trailing, bold: true)
                tableCell(t(PositionsKeys.dist), width: compactDistWidth, alignment: .trailing, bold: true)
            } else {
                tableCell(t(PositionsKeys.azimuth), width: compactAzimuthWidth, alignment: .trailing, bold: true)
                tableCell(t(PositionsKeys.altitude), width: compactAltitudeWidth, alignment: .trailing, bold: true)
            }
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private func compactPlanetRow(factor: Factors, position: FullFactorPosition, index: Int) -> some View {
        let ecliptical = position.ecliptical[0]
        let equatorial = position.equatorial[0]
        let horizontal = position.horizontal[0]

        let speedType = SpeedOrchestrator().determine(speed: ecliptical.mainPosSpeed, for: factor, config: CalculationConfig())
        HStack(spacing: 12) {
            glyphCell(factor, width: compactGlyphWidth)
            if selectedSystem == .ecliptical {
                lengthCell(ecliptical.mainPos, width: compactLengthWidth)
                tableCell(speedType == .direct ? "" : speedType.abbreviation, width: compactSpeedWidth, alignment: .trailing)
                tableCell(dms(equatorial.deviation), width: compactLatitudeWidth, alignment: .trailing)
            } else if selectedSystem == .equatorial {
                tableCell(dms(equatorial.mainPos), width: compactRAWidth, alignment: .trailing)
                tableCell(dms(equatorial.deviation), width: compactDeclWidth, alignment: .trailing)
                tableCell(decimal(ecliptical.distance), width: compactDistWidth, alignment: .trailing)
            } else {
                tableCell(dms(horizontal.azimuth), width: compactAzimuthWidth, alignment: .trailing)
                tableCell(dms(horizontal.altitude), width: compactAltitudeWidth, alignment: .trailing)
            }
        }
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    @ViewBuilder
    private func planetsTableCompact(for chart: FullChart) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 0) {
                compactPlanetsHeader()
                Divider()

                let planetRows = planetOrder.compactMap { factor -> (Factors, FullFactorPosition)? in
                    guard let position = chart.Coordinates[factor],
                          !position.ecliptical.isEmpty,
                          !position.equatorial.isEmpty,
                          !position.horizontal.isEmpty else {
                        return nil
                    }
                    return (factor, position)
                }

                ForEach(planetRows.indices, id: \.self) { index in
                    compactPlanetRow(factor: planetRows[index].0, position: planetRows[index].1, index: index)
                }
            }
            .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private func compactCuspsHeader() -> some View {
        HStack(spacing: 12) {
            tableCell(t(PositionsKeys.cuspNumber), width: compactCuspNumWidth, alignment: .leading, bold: true)
            if selectedSystem == .ecliptical {
                tableCell(t(PositionsKeys.length), width: compactLengthWidth, alignment: .trailing, bold: true)
                tableCell(t(PositionsKeys.declination), width: compactDeclWidth, alignment: .trailing, bold: true)
            } else if selectedSystem == .equatorial {
                tableCell(t(PositionsKeys.ra), width: compactRAWidth, alignment: .trailing, bold: true)
                tableCell(t(PositionsKeys.decl), width: compactDeclWidth, alignment: .trailing, bold: true)
            } else {
                tableCell(t(PositionsKeys.azimuth), width: compactAzimuthWidth, alignment: .trailing, bold: true)
                tableCell(t(PositionsKeys.altitude), width: compactAltitudeWidth, alignment: .trailing, bold: true)
            }
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private func compactCuspRow(index: Int, cusp: FullCuspPosition) -> some View {
        HStack(spacing: 12) {
            tableCell(String(index + 1), width: compactCuspNumWidth, alignment: .leading)
            if selectedSystem == .ecliptical {
                lengthCell(cusp.longitude, width: compactLengthWidth)
                tableCell(dms(cusp.declination), width: compactDeclWidth, alignment: .trailing)
            } else if selectedSystem == .equatorial {
                tableCell(dms(cusp.rightAscension), width: compactRAWidth, alignment: .trailing)
                tableCell(dms(cusp.declination), width: compactDeclWidth, alignment: .trailing)
            } else {
                tableCell(dms(cusp.horizontal.azimuth), width: compactAzimuthWidth, alignment: .trailing)
                tableCell(dms(cusp.horizontal.altitude), width: compactAltitudeWidth, alignment: .trailing)
            }
        }
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    @ViewBuilder
    private func cuspsTableCompact(for chart: FullChart) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 0) {
                compactCuspsHeader()
                Divider()

                ForEach(Array(chart.HousePositions.cusps.enumerated()), id: \.offset) { index, cusp in
                    compactCuspRow(index: index, cusp: cusp)
                }
            }
            .textSelection(.enabled)
        }
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width < Self.compactWidthThreshold
            Group {
                if let chart = chartSession.selectedChart {
                    if isCompact {
                        VStack(spacing: 0) {
                            Picker("", selection: $selectedSystem) {
                                ForEach(CoordinateSystems.allCases, id: \.self) { system in
                                    Text(LocalizedStringKey(system.rbKey))
                                        .tag(system)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding()

                            ScrollView(.vertical) {
                                VStack(alignment: .leading, spacing: 12) {
                                    planetsTableCompact(for: chart)
                                    cuspsTableCompact(for: chart)
                                }
                                .padding()
                            }
                        }
                    } else {
                        ScrollView([.horizontal, .vertical]) {
                            VStack(alignment: .leading, spacing: 12) {
                                planetsTable(for: chart)
                                cuspsTable(for: chart)
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding()
                        }
                    }
                } else {
                    Text(t(PositionsKeys.empty))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .accessibilityLabel("Help")
                }
            }
            .sheet(isPresented: $showHelp) {
                NavigationStack {
                    ScrollView {
                        Text(t(PositionsKeys.help))
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
    }
}
