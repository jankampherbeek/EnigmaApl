// BlaConfigPositionsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct BlaConfigPositionsView: View {
    @ObservedObject var model: BlaSchemaModel

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "BlaSchema", bundle: .main, comment: "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    Text(t(BlaSchemaKeys.explanation))
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    Picker(t(BlaSchemaKeys.configHouseSystem), selection: $model.houseSystem) {
                        ForEach(HouseSystems.allCases, id: \.self) { system in
                            Text(LocalizedStringKey(system.localizedName)).tag(system)
                        }
                    }

                    Toggle(t(BlaSchemaKeys.configUseChiron), isOn: $model.useChiron)
                    Toggle(t(BlaSchemaKeys.configUseCeres), isOn: $model.useCeres)
                    Toggle(t(BlaSchemaKeys.configUseDecanates), isOn: $model.useDecanates)

                    Picker(t(BlaSchemaKeys.configBlackMoonCorrectionType), selection: $model.blackMoonCorrectionType) {
                        ForEach(BlackMoonCorrectionType.allCases, id: \.self) { type in
                            Text(LocalizedStringKey(type.rbKey)).tag(type)
                        }
                    }
                }
            }

            BlaTableBlock(
                title: t(BlaSchemaKeys.positionsTitle),
                columns: [
                    BlaTableColumn("", width: 30),
                    BlaTableColumn(t(BlaSchemaKeys.colPosition), width: 100, alignment: .trailing),
                    BlaTableColumn("", width: 24),
                    BlaTableColumn(t(BlaSchemaKeys.colHouse), width: 50, alignment: .trailing),
                    BlaTableColumn("", width: 24)
                ],
                rows: model.blaPositions.map { pos in
                    [
                        BlaCell(pos.factor, kind: .glyph),
                        BlaCell(pos.position),
                        BlaCell(pos.sign, kind: .glyph),
                        BlaCell(pos.house),
                        BlaCell(pos.decanate, kind: .glyph)
                    ]
                }
            )

            BlaTableBlock(
                title: t(BlaSchemaKeys.housePositionsTitle),
                columns: [
                    BlaTableColumn(t(BlaSchemaKeys.colCusp), width: 40),
                    BlaTableColumn(t(BlaSchemaKeys.colPosition), width: 100, alignment: .trailing),
                    BlaTableColumn("", width: 24),
                    BlaTableColumn("", width: 24)
                ],
                rows: model.housePositions.map { pos in
                    [
                        BlaCell("\(pos.number)"),
                        BlaCell(pos.position),
                        BlaCell(pos.sign, kind: .glyph),
                        BlaCell(pos.decanate, kind: .glyph)
                    ]
                }
            )
        }
    }
}
