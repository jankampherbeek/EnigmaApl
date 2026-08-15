// BlaReinforcementsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct BlaReinforcementsView: View {
    @ObservedObject var model: BlaSchemaModel

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "BlaSchema", bundle: .main, comment: "")
    }

    private var connector: String { t(BlaSchemaKeys.connectorIn) }

    /// Factor + " in " + sign glyph (used for sign-based reinforcements).
    private func rowsWithSignGlyph(_ factors: [PresentableReinforcementFactor]) -> [[BlaCell]] {
        factors.map { f in
            [BlaCell(f.factor, kind: .glyph), BlaCell(connector), BlaCell(f.positionGlyph, kind: .glyph)]
        }
    }

    /// Factor + " in " + house number (used for house-based reinforcements).
    private func rowsWithHouseNumber(_ factors: [PresentableReinforcementFactor]) -> [[BlaCell]] {
        factors.map { f in
            [BlaCell(f.factor, kind: .glyph), BlaCell(connector), BlaCell("\(f.position)")]
        }
    }

    private let threeColumns = [BlaTableColumn("", width: 30), BlaTableColumn("", width: 40), BlaTableColumn("", width: 40)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BlaTableBlock(title: t(BlaSchemaKeys.ownSignTitle), columns: threeColumns, rows: rowsWithSignGlyph(model.factorsInOwnSigns))
            BlaTableBlock(title: t(BlaSchemaKeys.ownHouseTitle), columns: threeColumns, rows: rowsWithHouseNumber(model.factorsInOwnHouses))
            BlaTableBlock(title: t(BlaSchemaKeys.ownMundaneHouseTitle), columns: threeColumns, rows: rowsWithHouseNumber(model.factorsInOwnMundaneHouses))
            BlaTableBlock(title: t(BlaSchemaKeys.lordAnalogSignTitle), columns: threeColumns, rows: rowsWithSignGlyph(model.houseLordsInAnalogSigns))

            BlaTableBlock(
                title: t(BlaSchemaKeys.pairsTitle),
                columns: [
                    BlaTableColumn("", width: 30), BlaTableColumn("", width: 30),
                    BlaTableColumn("", width: 30), BlaTableColumn("", width: 30),
                    BlaTableColumn("", width: 40), BlaTableColumn("", width: 30),
                    BlaTableColumn("", width: 30)
                ],
                rows: model.pairAnalogHouseSigns.map { p in
                    [
                        BlaCell(p.factor1, kind: .glyph), BlaCell(" + "), BlaCell(p.factor2, kind: .glyph),
                        BlaCell(" = "), BlaCell(p.house), BlaCell(" + "), BlaCell(p.sign, kind: .glyph)
                    ]
                }
            )
        }
    }
}
