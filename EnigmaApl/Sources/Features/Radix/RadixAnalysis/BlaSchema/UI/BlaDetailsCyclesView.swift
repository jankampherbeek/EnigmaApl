// BlaDetailsCyclesView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct BlaDetailsCyclesView: View {
    @ObservedObject var model: BlaSchemaModel

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "BlaSchema", bundle: .main, comment: "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BlaTableBlock(
                title: t(BlaSchemaKeys.detailsTitle),
                columns: [
                    BlaTableColumn("", width: 150),
                    BlaTableColumn("", width: 140),
                    BlaTableColumn("", width: 60)
                ],
                rows: model.blaDetails.map { d in
                    [BlaCell(BlaSchemaLabels.detailLabel(d.kind)), BlaCell(d.text), BlaCell(d.glyphs, kind: .glyph)]
                }
            )

            BlaTableBlock(
                title: t(BlaSchemaKeys.cyclesTitle),
                columns: [BlaTableColumn("", width: 80), BlaTableColumn("", width: 220)],
                rows: model.blaCycles.map { c in
                    [BlaCell(BlaSchemaLabels.groupLabel(c.group)), BlaCell(c.description)]
                }
            )

            BlaTableBlock(
                title: t(BlaSchemaKeys.shortenedCyclesTitle),
                columns: [BlaTableColumn("", width: 80), BlaTableColumn("", width: 220)],
                rows: model.shortenedCycles.map { c in
                    [BlaCell(BlaSchemaLabels.groupLabel(c.group)), BlaCell(c.description)]
                }
            )
        }
    }
}
