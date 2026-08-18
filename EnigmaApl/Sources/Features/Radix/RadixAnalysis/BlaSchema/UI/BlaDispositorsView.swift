// BlaDispositorsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Charts

struct BlaDispositorsView: View {
    @ObservedObject var model: BlaSchemaModel

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "BlaSchema", bundle: .main, comment: "")
    }

    private func rulerPairLabel(_ d: PresentableDispositorCounts) -> String {
        "\(NSLocalizedString(d.mainRuler.localizedName, bundle: .main, comment: ""))/\(NSLocalizedString(d.subRuler.localizedName, bundle: .main, comment: ""))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BlaTableBlock(
                title: t(BlaSchemaKeys.dispositorsTitle),
                columns: [
                    BlaTableColumn(t(BlaSchemaKeys.colRulers), width: 50),
                    BlaTableColumn(t(BlaSchemaKeys.colSplit), width: 60, alignment: .trailing),
                    BlaTableColumn(t(BlaSchemaKeys.colSign), width: 44, alignment: .trailing),
                    BlaTableColumn(t(BlaSchemaKeys.colIndirect), width: 60, alignment: .trailing),
                    BlaTableColumn(t(BlaSchemaKeys.colSum), width: 44, alignment: .trailing),
                    BlaTableColumn(t(BlaSchemaKeys.colHouse), width: 44, alignment: .trailing),
                    BlaTableColumn(t(BlaSchemaKeys.colIndirect), width: 60, alignment: .trailing),
                    BlaTableColumn(t(BlaSchemaKeys.colSum), width: 44, alignment: .trailing),
                    BlaTableColumn(t(BlaSchemaKeys.colDecanate), width: 60, alignment: .trailing),
                    BlaTableColumn(t(BlaSchemaKeys.colTotal), width: 50, alignment: .trailing)
                ],
                rows: model.dispositorCounts.map { d in
                    [
                        BlaCell(d.rulers, kind: .glyph),
                        BlaCell(d.signSplitted),
                        BlaCell("\(d.signMain)"),
                        BlaCell("\(d.signIndirect)"),
                        BlaCell("\(d.signSum)"),
                        BlaCell("\(d.houseMain)"),
                        BlaCell("\(d.houseIndirect)"),
                        BlaCell("\(d.houseSum)"),
                        BlaCell("\(d.decanateDirect)"),
                        BlaCell("\(d.total)")
                    ]
                }
            )
            dispositorsPieChartBlock
        }
    }

    @ViewBuilder
    private var dispositorsPieChartBlock: some View {
        let nonZero = model.dispositorCounts.filter { $0.total > 0 }
        GroupBox {
            VStack(alignment: .leading, spacing: 6) {
                Text(t(BlaSchemaKeys.dispositorsChartTitle)).font(.headline)
                if nonZero.isEmpty {
                    Text("—").foregroundStyle(.secondary)
                } else {
                    Chart(nonZero) { d in
                        SectorMark(
                            angle: .value(t(BlaSchemaKeys.colTotal), d.total),
                            innerRadius: .ratio(0.55),
                            angularInset: 1.5
                        )
                        .foregroundStyle(BlaSchemaLabels.decanateRulerColor(d.mainRuler))
                        .cornerRadius(3)
                    }
                    .chartLegend(position: .bottom, alignment: .leading, spacing: 8)
                    .chartForegroundStyleScale(
                        domain: nonZero.map { rulerPairLabel($0) },
                        range: nonZero.map { BlaSchemaLabels.decanateRulerColor($0.mainRuler) }
                    )
                    .frame(height: 220)
                }
            }
        }
    }
}
