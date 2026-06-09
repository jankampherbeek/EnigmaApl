// EnneagramOverviewView.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

struct EnneagramOverviewView: View {
    let results: [EnneagramTypeResult]
    let typeNames: [Int: String]

    @State private var showHelp = false

    private let typeW:     CGFloat = 50
    private let nameW:     CGFloat = 240
    private let strengthW: CGFloat = 100

    private func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Enneagram", bundle: .main, comment: "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(EnneagramKeys.overviewTitle))
                    .font(.title2.weight(.semibold))

                if results.isEmpty {
                    Text(t(EnneagramKeys.noChart))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    overviewTable
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
            WheelHelpSheet(helpText: t(EnneagramKeys.overviewHelp))
        }
    }

    @ViewBuilder
    private var overviewTable: some View {
        GroupBox {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text(t(EnneagramKeys.colType))
                        .frame(width: typeW, alignment: .center)
                    Text(t(EnneagramKeys.colName))
                        .frame(width: nameW, alignment: .leading)
                    Text(t(EnneagramKeys.colStrength))
                        .frame(width: strengthW, alignment: .trailing)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)

                Divider()

                ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                    row(result, index: index)
                }
            }
        }
    }

    @ViewBuilder
    private func row(_ result: EnneagramTypeResult, index: Int) -> some View {
        let isTop = index == 0
        HStack(spacing: 12) {
            Text("\(result.type)")
                .font(.headline)
                .foregroundStyle(isTop ? Color.red : .primary)
                .frame(width: typeW, alignment: .center)
            Text(typeNames[result.type] ?? "")
                .frame(width: nameW, alignment: .leading)
                .lineLimit(1)
            Text(String(format: "%.4f", result.strength))
                .frame(width: strengthW, alignment: .trailing)
                .foregroundStyle(.secondary)
                .font(.system(.body, design: .monospaced))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }
}
