// BlaCountsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI
import Charts

struct BlaCountsView: View {
    @ObservedObject var model: BlaSchemaModel

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "BlaSchema", bundle: .main, comment: "")
    }

    private var countsColumns: [BlaTableColumn] {
        [
            BlaTableColumn(t(BlaSchemaKeys.colName), width: 90),
            BlaTableColumn(t(BlaSchemaKeys.colSign), width: 50, alignment: .trailing),
            BlaTableColumn(t(BlaSchemaKeys.colHouse), width: 50, alignment: .trailing),
            BlaTableColumn(t(BlaSchemaKeys.colSum), width: 50, alignment: .trailing),
            BlaTableColumn(t(BlaSchemaKeys.colHCusp), width: 50, alignment: .trailing),
            BlaTableColumn(t(BlaSchemaKeys.colTotal), width: 50, alignment: .trailing)
        ]
    }

    private func countsRows(_ counts: [PresentableCrossElementsCount]) -> [[BlaCell]] {
        counts.map { c in
            [
                BlaCell(BlaSchemaLabels.groupLabel(c.group)),
                BlaCell("\(c.sign)"), BlaCell("\(c.house)"), BlaCell("\(c.sum)"),
                BlaCell("\(c.hCusp)"), BlaCell("\(c.total)")
            ]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BlaTableBlock(title: t(BlaSchemaKeys.elementsTitle), columns: countsColumns, rows: countsRows(model.elementsCounts))
            pieChartBlock(title: t(BlaSchemaKeys.elementsChartTitle), counts: model.elementsCounts)

            BlaTableBlock(title: t(BlaSchemaKeys.crossesTitle), columns: countsColumns, rows: countsRows(model.crossesCounts))
            pieChartBlock(title: t(BlaSchemaKeys.crossesChartTitle), counts: model.crossesCounts)

            BlaTableBlock(
                title: t(BlaSchemaKeys.quadrantsTitle),
                columns: [
                    BlaTableColumn("", width: 110),
                    BlaTableColumn(t(BlaSchemaKeys.colTotal), width: 50, alignment: .trailing)
                ],
                rows: model.quadrantCounts.map { q in
                    [BlaCell(String(format: t(BlaSchemaKeys.quadrantLabelFormat), q.quadrant)), BlaCell("\(q.count)")]
                }
            )
        }
    }

    @ViewBuilder
    private func pieChartBlock(title: String, counts: [PresentableCrossElementsCount]) -> some View {
        let nonZero = counts.filter { $0.total > 0 }
        GroupBox {
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)
                if nonZero.isEmpty {
                    Text("—").foregroundStyle(.secondary)
                } else {
                    Chart(nonZero) { count in
                        SectorMark(
                            angle: .value(t(BlaSchemaKeys.colTotal), count.total),
                            innerRadius: .ratio(0.55),
                            angularInset: 1.5
                        )
                        .foregroundStyle(BlaSchemaLabels.groupColor(count.group))
                        .cornerRadius(3)
                    }
                    .chartLegend(position: .bottom, alignment: .leading, spacing: 8)
                    .chartForegroundStyleScale(
                        domain: nonZero.map { BlaSchemaLabels.groupLabel($0.group) },
                        range: nonZero.map { BlaSchemaLabels.groupColor($0.group) }
                    )
                    .frame(height: 220)
                }
            }
        }
    }
}
