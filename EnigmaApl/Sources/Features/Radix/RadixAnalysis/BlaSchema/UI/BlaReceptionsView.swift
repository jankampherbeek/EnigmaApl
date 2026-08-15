// BlaReceptionsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct BlaReceptionsView: View {
    @ObservedObject var model: BlaSchemaModel

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "BlaSchema", bundle: .main, comment: "")
    }

    private let columns = [
        BlaTableColumn("", width: 30), BlaTableColumn("", width: 24),
        BlaTableColumn("", width: 30), BlaTableColumn("", width: 24),
        BlaTableColumn("", width: 30), BlaTableColumn("", width: 24),
        BlaTableColumn("", width: 30)
    ]

    private func rows(_ receptions: [PresentableReception], positionsAreGlyphs: Bool) -> [[BlaCell]] {
        let positionKind: BlaCell.Kind = positionsAreGlyphs ? .glyph : .body
        return receptions.map { r in
            [
                BlaCell(r.factor1, kind: .glyph), BlaCell(" + "), BlaCell(r.factor2, kind: .glyph), BlaCell(" = "),
                BlaCell(r.position1, kind: positionKind), BlaCell(" + "), BlaCell(r.position2, kind: positionKind)
            ]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BlaTableBlock(title: t(BlaSchemaKeys.receptionsInSignsTitle), columns: columns, rows: rows(model.receptionsInSigns, positionsAreGlyphs: true))
            BlaTableBlock(title: t(BlaSchemaKeys.receptionsInHousesTitle), columns: columns, rows: rows(model.receptionsInHouses, positionsAreGlyphs: false))
            BlaTableBlock(title: t(BlaSchemaKeys.receptionsInMundaneHousesTitle), columns: columns, rows: rows(model.receptionsInMundaneHouses, positionsAreGlyphs: false))
        }
    }
}
