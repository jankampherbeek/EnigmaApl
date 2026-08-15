// BlaDispositorsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct BlaDispositorsView: View {
    @ObservedObject var model: BlaSchemaModel

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "BlaSchema", bundle: .main, comment: "")
    }

    var body: some View {
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
    }
}
