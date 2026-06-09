// EnneagramDetailsView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct EnneagramDetailsView: View {
    let detailLines: [EnneagramDetailLine]

    @State private var showHelp = false

    private let factorW:   CGFloat = 36
    private let posW:      CGFloat = 46
    private let inSignsW:  CGFloat = 60
    private let typeW:     CGFloat = 52

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Enneagram", bundle: .main, comment: "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(EnneagramKeys.detailsTitle))
                    .font(.title2.weight(.semibold))

                if detailLines.isEmpty {
                    Text(t(EnneagramKeys.noChart))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    detailsTable
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(EnneagramKeys.detailsHelp))
        }
    }

    @ViewBuilder
    private var detailsTable: some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    columnHeaders
                    Divider()
                    ForEach(Array(detailLines.enumerated()), id: \.element.id) { index, line in
                        detailRow(line, index: index)
                    }
                }
            }
        }
    }

    private var columnHeaders: some View {
        HStack(spacing: 6) {
            Text(t(EnneagramKeys.colFactor))
                .frame(width: factorW, alignment: .center)
            Text(t(EnneagramKeys.colPosition))
                .frame(width: posW, alignment: .center)
            Text(t(EnneagramKeys.colInSigns))
                .frame(width: inSignsW, alignment: .center)
            ForEach(1...9, id: \.self) { n in
                Text("\(n)")
                    .frame(width: typeW, alignment: .trailing)
            }
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func detailRow(_ line: EnneagramDetailLine, index: Int) -> some View {
        HStack(spacing: 6) {
            factorCell(line)
                .frame(width: factorW, alignment: .center)
            Text("\(line.positionIndex)")
                .frame(width: posW, alignment: .center)
                .foregroundStyle(.secondary)
            Image(systemName: line.inSigns ? "checkmark" : "minus")
                .frame(width: inSignsW, alignment: .center)
                .foregroundStyle(.secondary)
            ForEach(0..<min(9, line.typeValues.count), id: \.self) { i in
                Text(String(format: "%.2f", line.typeValues[i]))
                    .frame(width: typeW, alignment: .trailing)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }

    @ViewBuilder
    private func factorCell(_ line: EnneagramDetailLine) -> some View {
        if let factor = line.factor {
            Text(GlyphSelector.getGlyphForFactor(factor))
                .font(.custom("EnigmaAstrology2", size: 16))
                .accessibilityLabel(factor.localizedName)
        } else {
            Text(line.specialLabel)
                .font(.caption.weight(.semibold))
        }
    }
}
