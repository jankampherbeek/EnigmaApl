// BlaSchemaTableBlock.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

/// A single column spec for `BlaTableBlock`.
struct BlaTableColumn {
    let title: String
    let width: CGFloat
    let alignment: Alignment

    init(_ title: String, width: CGFloat, alignment: Alignment = .leading) {
        self.title = title
        self.width = width
        self.alignment = alignment
    }
}

/// A single table cell. Glyph cells render with the astrology glyph font.
struct BlaCell {
    enum Kind { case body, glyph }
    let text: String
    let kind: Kind

    init(_ text: String, kind: Kind = .body) {
        self.text = text
        self.kind = kind
    }
}

/// A titled block containing a small fixed-column table, used for every BLA schema
/// count/detail/reinforcement/reception block. Mirrors the Windows BlaSchemaWindow's
/// bordered `<StackPanel>` + `<DataGrid>` blocks, one Swift view instead of ~20 XAML copies.
struct BlaTableBlock: View {
    let title: String
    let columns: [BlaTableColumn]
    let rows: [[BlaCell]]
    var emptyText: String? = nil

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)

                if rows.isEmpty {
                    if let emptyText {
                        Text(emptyText)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        if columns.contains(where: { !$0.title.isEmpty }) {
                            HStack(spacing: 8) {
                                ForEach(columns.indices, id: \.self) { index in
                                    Text(columns[index].title)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                        .frame(width: columns[index].width, alignment: columns[index].alignment)
                                }
                            }
                            Divider()
                        }
                        ForEach(rows.indices, id: \.self) { rowIndex in
                            HStack(spacing: 8) {
                                ForEach(rows[rowIndex].indices, id: \.self) { columnIndex in
                                    cellView(rows[rowIndex][columnIndex], column: columns[columnIndex])
                                }
                            }
                            .padding(.vertical, 3)
                            .background(rowIndex.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
                        }
                    }
                }
            }
            .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private func cellView(_ cell: BlaCell, column: BlaTableColumn) -> some View {
        switch cell.kind {
        case .body:
            Text(cell.text)
                .font(.body)
                .frame(width: column.width, alignment: column.alignment)
        case .glyph:
            Text(cell.text)
                .font(.custom("EnigmaAstrology3", size: 16))
                .frame(width: column.width, alignment: column.alignment)
        }
    }
}
