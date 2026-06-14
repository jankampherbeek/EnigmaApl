// PrimDirResultsScreen.swift
// EnigmaApl is open source. For more information see se_license.html and License, both at the root of the application.
// Created by Jan Kampherbeek 2026

import SwiftUI

private func t(_ key: String) -> String {
    NSLocalizedString(key, tableName: "PrimDir", bundle: .main, comment: "")
}

struct PrimDirResultsScreen: View {
    @EnvironmentObject private var primDirModel: PrimDirModel
    @EnvironmentObject private var chartSession: ChartSession

    @State private var showHelp = false

    private let dateWidth:   CGFloat = 110
    private let glyphWidth:  CGFloat = 36
    private let aspectWidth: CGFloat = 36

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t(PrimDirKeys.resultsTitle))
                    .font(.title2.weight(.semibold))

                if let name = chartSession.selected?.name {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                if !primDirModel.methodDescription.isEmpty {
                    Text(primDirModel.methodDescription)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                if !primDirModel.period.isEmpty {
                    Text(primDirModel.period)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                if let error = primDirModel.errorMessage {
                    Text(error)
                        .font(.callout)
                        .foregroundStyle(.red)
                }

                if !primDirModel.hasResults {
                    Text(t(PrimDirKeys.noResults))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                } else {
                    hitsTable
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(t(PrimDirKeys.resultsTitle))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHelp = true } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Help")
            }
        }
        .sheet(isPresented: $showHelp) {
            WheelHelpSheet(helpText: t(PrimDirKeys.helpResults))
        }
    }

    // MARK: - Hits table

    private var hitsTable: some View {
        GroupBox {
            VStack(spacing: 0) {
                hitsHeader
                Divider()
                ForEach(Array(primDirModel.hits.enumerated()), id: \.offset) { index, hit in
                    hitRow(hit, index: index)
                }
            }
        }
    }

    private var hitsHeader: some View {
        HStack(spacing: 8) {
            Text(t(PrimDirKeys.colDate))
                .frame(width: dateWidth, alignment: .leading)
            Spacer().frame(width: glyphWidth)
            Spacer().frame(width: aspectWidth)
            Spacer().frame(width: glyphWidth)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func hitRow(_ hit: PrimDirHit, index: Int) -> some View {
        HStack(spacing: 8) {
            Text(hit.dateTxt)
                .frame(width: dateWidth, alignment: .leading)
                .font(.body.monospacedDigit())

            Text(GlyphSelector.getGlyphForFactor(hit.promissor))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphWidth, alignment: .center)
                .accessibilityLabel(hit.promissor.localizedName)

            Text(GlyphSelector.getGlyphForAspect(hit.aspect))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: aspectWidth, alignment: .center)

            Text(GlyphSelector.getGlyphForFactor(hit.significator))
                .font(.custom("EnigmaAstrology2", size: 18))
                .frame(width: glyphWidth, alignment: .center)
                .accessibilityLabel(hit.significator.localizedName)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(index.isMultiple(of: 2) ? Color.clear : Color.primary.opacity(0.06))
    }
}
