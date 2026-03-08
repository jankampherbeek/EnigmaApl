import SwiftUI

struct PositionsScreen: View {
    @EnvironmentObject private var app: AppState

    private let planetOrder: [Factors] = [
        .sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto
    ]
    private let planetColumnWidths: [CGFloat] = [50, 120, 120, 140, 120, 120, 120, 120]
    private let cuspColumnWidths: [CGFloat] = [70, 120, 140, 120, 120, 120]

    private func dms(_ number: Double) -> String {
        PositionInDegreesConversion.DoubleToDms(number)
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

    @ViewBuilder
    private func planetsTable(for chart: FullChart) -> some View {
        GroupBox("Planets") {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    tableCell("", width: planetColumnWidths[0], alignment: .leading, bold: true)
                    tableCell("Length", width: planetColumnWidths[1], alignment: .trailing, bold: true)
                    tableCell("Width", width: planetColumnWidths[2], alignment: .trailing, bold: true)
                    tableCell("Right Ascension", width: planetColumnWidths[3], alignment: .trailing, bold: true)
                    tableCell("Declination", width: planetColumnWidths[4], alignment: .trailing, bold: true)
                    tableCell("Distance", width: planetColumnWidths[5], alignment: .trailing, bold: true)
                    tableCell("Azimuth", width: planetColumnWidths[6], alignment: .trailing, bold: true)
                    tableCell("Altitude", width: planetColumnWidths[7], alignment: .trailing, bold: true)
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

                    HStack(spacing: 12) {
                        glyphCell(factor, width: planetColumnWidths[0])
                        lengthCell(ecliptical.mainPos, width: planetColumnWidths[1])
                        tableCell(dms(ecliptical.deviation), width: planetColumnWidths[2], alignment: .trailing)
                        tableCell(dms(equatorial.mainPos), width: planetColumnWidths[3], alignment: .trailing)
                        tableCell(dms(equatorial.deviation), width: planetColumnWidths[4], alignment: .trailing)
                        tableCell(dms(ecliptical.distance), width: planetColumnWidths[5], alignment: .trailing)
                        tableCell(dms(horizontal.azimuth), width: planetColumnWidths[6], alignment: .trailing)
                        tableCell(dms(horizontal.altitude), width: planetColumnWidths[7], alignment: .trailing)
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
        GroupBox("Cusps") {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    tableCell("Cusp", width: cuspColumnWidths[0], alignment: .leading, bold: true)
                    tableCell("Length", width: cuspColumnWidths[1], alignment: .trailing, bold: true)
                    tableCell("Right Ascension", width: cuspColumnWidths[2], alignment: .trailing, bold: true)
                    tableCell("Declination", width: cuspColumnWidths[3], alignment: .trailing, bold: true)
                    tableCell("Azimuth", width: cuspColumnWidths[4], alignment: .trailing, bold: true)
                    tableCell("Altitude", width: cuspColumnWidths[5], alignment: .trailing, bold: true)
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

    var body: some View {
        Group {
            if let chart = app.latestRadixChart {
                ScrollView([.horizontal, .vertical]) {
                    VStack(alignment: .leading, spacing: 12) {
                        planetsTable(for: chart)
                        cuspsTable(for: chart)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
                }
            } else {
                Text("No calculated radix chart yet.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
            }
        }
    }
}
